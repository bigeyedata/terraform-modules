terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
}

locals {
  max_port                    = 65535
  load_balancer_ingress_text  = var.internet_facing ? "anywhere" : "internal"
  load_balancer_ingress_cidrs = var.internet_facing ? ["0.0.0.0/0"] : concat([var.vpc_cidr_block], var.lb_additional_ingress_cidrs)
}


#==============================================
# Load balancer resources
#==============================================
resource "aws_security_group" "lb" {
  count       = var.create_security_groups ? 1 : 0
  name        = "${var.name}-lb"
  description = "Allows 80/443 from ${local.load_balancer_ingress_text}"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name}-lb"
  })

  ingress {
    description = "HTTPS from ${local.load_balancer_ingress_text}"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = local.load_balancer_ingress_cidrs
  }

  ingress {
    description = "HTTP from internal"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = local.load_balancer_ingress_cidrs
  }

  egress {
    description      = "Allow outbound"
    from_port        = 0
    to_port          = local.max_port
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internet_facing ? false : true
  load_balancer_type = "application"
  subnets            = var.lb_subnet_ids
  security_groups    = concat(aws_security_group.lb[*].id, var.lb_additional_security_group_ids)
  idle_timeout       = var.lb_idle_timeout
  tags               = var.tags

  access_logs {
    enabled = var.lb_access_logs_enabled
    bucket  = var.lb_access_logs_bucket_name
    prefix  = var.lb_access_logs_bucket_prefix
  }
}

resource "aws_lb_target_group" "this" {
  name                          = var.name
  port                          = var.traffic_port
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  target_type                   = "ip"
  deregistration_delay          = var.lb_deregistration_delay
  load_balancing_algorithm_type = "least_outstanding_requests"
  stickiness {
    enabled = var.lb_stickiness_enabled
    type    = "lb_cookie"
  }
  tags = var.tags

  health_check {
    enabled             = true
    protocol            = "HTTP"
    healthy_threshold   = var.healthcheck_healthy_threshold
    unhealthy_threshold = var.healthcheck_unhealthy_threshold
    interval            = var.healthcheck_interval
    timeout             = var.healthcheck_timeout
    path                = var.healthcheck_path
  }
}

resource "aws_lb_listener" "http" {
  depends_on        = [aws_lb.this]
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      query       = "#{query}"
      host        = "#{host}"
      path        = "/#{path}"
    }
  }
}

resource "aws_lb_listener" "https" {
  depends_on = [
    aws_lb.this,
    aws_lb_target_group.this
  ]

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}


#==============================================
# Application resources
#==============================================
resource "aws_security_group" "this" {
  count       = var.create_security_groups ? 1 : 0
  name        = var.name
  description = "Allows traffic for ${var.name}"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = var.name
  })

  ingress {
    description     = "allows port ${var.traffic_port} from the load balancer"
    from_port       = var.traffic_port
    to_port         = var.traffic_port
    protocol        = "TCP"
    security_groups = [aws_security_group.lb[0].id]
  }

  # TODO split these out into their own resources
  dynamic "ingress" {
    for_each = toset(var.task_additional_ingress_cidrs)

    content {
      from_port   = var.traffic_port
      to_port     = var.traffic_port
      protocol    = "TCP"
      description = "Allows port ${var.traffic_port} from ${ingress.key}"
      cidr_blocks = [ingress.key]
    }
  }

  egress {
    description      = "Allow outbound"
    from_port        = 0
    to_port          = local.max_port
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = var.tags
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = jsonencode(local.container_definitions)
}

resource "aws_ecs_service" "this" {
  name            = var.name
  depends_on      = [aws_lb.this]
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = var.on_demand_base_count
    weight            = var.on_demand_weight
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = var.spot_base_count
    weight            = var.spot_weight
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = var.healthcheck_grace_period
  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups = concat(
      aws_security_group.this[*].id,
      var.additional_security_group_ids
    )
  }
  load_balancer {
    container_name   = var.name
    container_port   = var.traffic_port
    target_group_arn = aws_lb_target_group.this.arn
  }
  platform_version = var.fargate_version

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  propagate_tags = "SERVICE"

  tags = var.tags
}

