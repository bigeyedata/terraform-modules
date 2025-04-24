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
  efs_volume_enabled          = var.efs_mount_point != "" && var.efs_access_point_id != ""
  centralized_lb_installed    = var.centralized_lb_arn != ""
  service_dns_name            = var.create_dns_records ? aws_route53_record.this[0].name : var.dns_name
}


#==============================================
# Load balancer resources
#==============================================
resource "aws_security_group" "lb" {
  count       = var.create_lb && var.create_security_groups ? 1 : 0
  name        = "${var.name}-lb"
  description = "Allows 80/443 from ${local.load_balancer_ingress_text}"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name}-lb"
  })
  ingress = []
  egress  = []
}

resource "aws_vpc_security_group_ingress_rule" "lb_http" {
  for_each          = var.create_lb && var.create_security_groups ? toset(local.load_balancer_ingress_cidrs) : []
  description       = "HTTP from ${each.value}"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.lb[0].id
}

resource "aws_vpc_security_group_ingress_rule" "lb_https" {
  for_each          = var.create_lb && var.create_security_groups ? toset(local.load_balancer_ingress_cidrs) : []
  description       = "HTTPS from ${each.value}"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.lb[0].id
}

resource "aws_vpc_security_group_egress_rule" "lb_ipv4" {
  count             = var.create_lb && var.create_security_groups ? 1 : 0
  from_port         = 0
  to_port           = local.max_port
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.lb[0].id
}

resource "aws_vpc_security_group_egress_rule" "lb_ipv6" {
  count             = var.create_lb && var.create_security_groups ? 1 : 0
  from_port         = 0
  to_port           = local.max_port
  ip_protocol       = "tcp"
  cidr_ipv6         = "::/0"
  security_group_id = aws_security_group.lb[0].id
}

resource "aws_lb" "this" {
  count              = var.create_lb ? 1 : 0
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
  count                         = var.create_lb ? 1 : 0
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

resource "aws_lb_target_group" "centralized_lb" {
  count = local.centralized_lb_installed ? 1 : 0
  # This hack is due to a 32 char limit for TGs and the overly long name of one of our internal test environments
  name                          = startswith(var.name, "release-candidate-") ? "rc-${var.instance}-${var.app}" : "${var.name}2"
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
  count      = var.create_lb ? 1 : 0
  depends_on = [aws_lb_target_group.this[0]]

  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_listener" "https" {
  count      = var.create_lb ? 1 : 0
  depends_on = [aws_lb_target_group.this[0]]

  load_balancer_arn = aws_lb.this[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_listener_rule" "centralized_lb" {
  count        = local.centralized_lb_installed ? 1 : 0
  listener_arn = var.centralized_lb_https_listener_rule_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.centralized_lb[0].arn
  }
  condition {
    host_header {
      values = [local.service_dns_name]
    }
  }
  tags = merge(var.tags, {
    Name = var.name
  })
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

  ingress = []
  egress  = []
}

resource "aws_vpc_security_group_ingress_rule" "this_lb_to_service" {
  count                        = var.create_lb ? 1 : 0
  description                  = "Allows port ${var.traffic_port} from service load balancer"
  from_port                    = var.traffic_port
  to_port                      = var.traffic_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.lb[0].id
  security_group_id            = aws_security_group.this[0].id
}

resource "aws_vpc_security_group_ingress_rule" "internal_lb_to_service" {
  for_each                     = var.create_security_groups ? toset(var.centralized_lb_security_group_ids) : []
  description                  = "Allows port ${var.traffic_port} from the internal load balancer"
  from_port                    = var.traffic_port
  to_port                      = var.traffic_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
  security_group_id            = aws_security_group.this[0].id
}

resource "aws_vpc_security_group_ingress_rule" "additional_to_service" {
  for_each          = var.create_security_groups ? toset(var.task_additional_ingress_cidrs) : []
  description       = "Allows port ${var.traffic_port} from ${each.value}"
  from_port         = var.traffic_port
  to_port           = var.traffic_port
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  security_group_id = aws_security_group.this[0].id
}

resource "aws_vpc_security_group_egress_rule" "this_ipv4" {
  count             = var.create_security_groups ? 1 : 0
  from_port         = 0
  to_port           = local.max_port
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.this[0].id
}

resource "aws_vpc_security_group_egress_rule" "this_ipv6" {
  count             = var.create_security_groups ? 1 : 0
  from_port         = 0
  to_port           = local.max_port
  ip_protocol       = "tcp"
  cidr_ipv6         = "::/0"
  security_group_id = aws_security_group.this[0].id
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
  dynamic "volume" {
    for_each = local.efs_volume_enabled ? ["this"] : []
    content {
      name = var.name
      efs_volume_configuration {
        file_system_id     = var.efs_volume_id
        transit_encryption = "ENABLED"
        authorization_config {
          access_point_id = var.efs_access_point_id
          iam             = "ENABLED"
        }
      }
    }
  }
}

# If the ECS service is autoscaling, then we will ignore changes to the desired_count field.
# These two resources should be identical otherwise
resource "aws_ecs_service" "uncontrolled_count" {
  lifecycle {
    ignore_changes = [desired_count]
  }
  count                  = var.control_desired_count ? 0 : 1
  name                   = var.name
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.this.arn
  enable_execute_command = var.enable_execute_command
  desired_count          = var.desired_count

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
  dynamic "load_balancer" {
    for_each = compact([
      var.create_lb ? aws_lb_target_group.this[0].arn : "",
      local.centralized_lb_installed ? aws_lb_target_group.centralized_lb[0].arn : "",
    ])
    content {
      container_name   = var.name
      container_port   = var.traffic_port
      target_group_arn = load_balancer.value
    }
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

resource "aws_ecs_service" "controlled_count" {
  count                  = var.control_desired_count ? 1 : 0
  name                   = var.name
  cluster                = var.ecs_cluster_id
  task_definition        = aws_ecs_task_definition.this.arn
  enable_execute_command = var.enable_execute_command
  desired_count          = var.desired_count

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
  dynamic "load_balancer" {
    for_each = compact([
      var.create_lb ? aws_lb_target_group.this[0].arn : "",
      local.centralized_lb_installed ? aws_lb_target_group.centralized_lb[0].arn : "",
    ])
    content {
      container_name   = var.name
      container_port   = var.traffic_port
      target_group_arn = load_balancer.value
    }
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

resource "aws_route53_record" "this" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.dns_name
  type    = "A"
  alias {
    name                   = var.use_centralized_lb ? data.aws_lb.external[0].dns_name : aws_lb.this[0].dns_name
    zone_id                = var.use_centralized_lb ? data.aws_lb.external[0].zone_id : aws_lb.this[0].zone_id
    evaluate_target_health = true
  }
}
