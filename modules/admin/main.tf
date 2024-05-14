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
  max_port = 65535
  name     = "${var.stack_name}-bigeye-admin"
  environment_variables = {
    STACK_NAME = var.stack_name

    # These two are required by the CLI, but not used anymore.
    # Subsequent release will remove these env vars
    PARENT_DOMAIN_NAME = "deprecated"
    BASE_DNS_ALIAS     = "deprecated"

    HAPROXY_DOMAIN_NAME     = var.haproxy_domain_name
    WEB_DOMAIN_NAME         = var.web_domain_name
    MONOCLE_DOMAIN_NAME     = var.monocle_domain_name
    TORETTO_DOMAIN_NAME     = var.toretto_domain_name
    TEMPORAL_DOMAIN_NAME    = var.temporal_domain_name
    TEMPORALUI_DOMAIN_NAME  = var.temporalui_domain_name
    DATAWATCH_DOMAIN_NAME   = var.datawatch_domain_name
    DATAWORK_DOMAIN_NAME    = var.datawork_domain_name
    LINEAGEWORK_DOMAIN_NAME = var.lineagework_domain_name
    METRICWORK_DOMAIN_NAME  = var.metricwork_domain_name
    SCHEDULER_DOMAIN_NAME   = var.scheduler_domain_name

    HAPROXY_ELB_NAME     = var.haproxy_resource_name
    WEB_ELB_NAME         = var.web_resource_name
    MONOCLE_ELB_NAME     = var.monocle_resource_name
    TORETTO_ELB_NAME     = var.toretto_resource_name
    TEMPORAL_ELB_NAME    = var.temporal_resource_name
    TEMPORALUI_ELB_NAME  = var.temporalui_resource_name
    DATAWATCH_ELB_NAME   = var.datawatch_resource_name
    DATAWORK_ELB_NAME    = var.datawork_resource_name
    LINEAGEWORK_ELB_NAME = var.lineagework_resource_name
    METRICWORK_ELB_NAME  = var.metricwork_resource_name
    SCHEDULER_ELB_NAME   = var.scheduler_resource_name

    HAPROXY_ECS_NAME     = var.haproxy_resource_name
    WEB_ECS_NAME         = var.web_resource_name
    MONOCLE_ECS_NAME     = var.monocle_resource_name
    TORETTO_ECS_NAME     = var.toretto_resource_name
    TEMPORAL_ECS_NAME    = var.temporal_resource_name
    TEMPORALUI_ECS_NAME  = var.temporalui_resource_name
    DATAWATCH_ECS_NAME   = var.datawatch_resource_name
    DATAWORK_ECS_NAME    = var.datawork_resource_name
    LINEAGEWORK_ECS_NAME = var.lineagework_resource_name
    METRICWORK_ECS_NAME  = var.metricwork_resource_name
    SCHEDULER_ECS_NAME   = var.scheduler_resource_name

    DATAWATCH_RDS_IDENTIFIER = var.datawatch_rds_identifier
    DATAWATCH_RDS_HOST       = var.datawatch_rds_hostname
    DATAWATCH_RDS_USERNAME   = var.datawatch_rds_username
    DATAWATCH_RDS_DB_NAME    = var.datawatch_rds_db_name

    TEMPORAL_RDS_IDENTIFIER = var.temporal_rds_identifier
    TEMPORAL_RDS_HOST       = var.temporal_rds_hostname
    TEMPORAL_RDS_USERNAME   = var.temporal_rds_username
    TEMPORAL_RDS_DB_NAME    = var.temporal_rds_db_name

    REDIS_DOMAIN_NAME = var.redis_domain_name

    TEMPORAL_PORT = tostring(var.temporal_port)

    RABBITMQ_ENDPOINT    = var.rabbitmq_endpoint
    RABBITMQ_USERNAME    = var.rabbitmq_username
    RABBITMQ_TLS_ENABLED = "true"
  }

  secret_arns = {
    DATAWATCH_RDS_PASSWORD = var.datawatch_rds_password_secret_arn
    TEMPORAL_RDS_PASSWORD  = var.temporal_rds_password_secret_arn
    REDIS_PASSWORD         = var.redis_password_secret_arn
    RABBITMQ_PASSWORD      = var.rabbitmq_password_secret_arn
  }

  create_iam_role = var.task_iam_role_arn == ""
  ecs_iam_role    = local.create_iam_role ? aws_iam_role.this[0].arn : var.task_iam_role_arn
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  count = local.create_iam_role ? 1 : 0
  name  = local.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  count = local.create_iam_role ? 1 : 0
  role  = aws_iam_role.this[0].id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.cloudwatch_log_group_name}:*"
      },
      {
        "Sid" : "GrantGlobalAccess",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeSecurityGroups",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "GrantSpecificAccess",
        "Effect" : "Allow",
        "Action" : [
          "rds:DescribeDBInstances",
          "ecs:DescribeServices",
          "elasticache:DescribeReplicationGroups",
          "elasticache:DescribeCacheClusters",
        ],
        "Resource" : [
          "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:${var.stack_name}*",
          "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/${var.stack_name}/*",
          "arn:aws:elasticache:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:replicationgroup:${var.stack_name}",
          "arn:aws:elasticache:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster:${var.stack_name}*",
        ]
      }
    ]
  })
}

resource "aws_security_group" "this" {
  count       = var.enabled ? 1 : 0
  name        = local.name
  vpc_id      = var.vpc_id
  description = "Used for validating networking"
  tags = merge(var.tags, {
    Name = local.name
  })
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count             = var.enabled ? 1 : 0
  security_group_id = aws_security_group.this[0].id
  description       = "Allow outbound"
  from_port         = 0
  to_port           = local.max_port
  ip_protocol       = "TCP"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "client" {
  name        = "${local.name}-client"
  vpc_id      = var.vpc_id
  description = "allows ingress on all ports from bigeye-admin"
  tags = merge(var.tags, {
    Name = "${local.name}-client"
  })
}

resource "aws_vpc_security_group_ingress_rule" "client_from_main" {
  count                        = var.enabled ? 1 : 0
  security_group_id            = aws_security_group.client.id
  description                  = "Allow all traffic"
  from_port                    = 0
  to_port                      = local.max_port
  ip_protocol                  = "TCP"
  referenced_security_group_id = aws_security_group.this[0].id
}

resource "aws_ecs_task_definition" "this" {
  count                    = var.enabled ? 1 : 0
  family                   = local.name
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = var.tags
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = local.ecs_iam_role
  container_definitions = jsonencode([{
    name         = local.name
    cpu          = 1024
    memory       = 2048
    image        = var.image
    essential    = true
    mountPoints  = []
    portMappings = []
    volumesFrom  = []
    environment  = [for k, v in local.environment_variables : { Name = k, Value = v }]
    secrets      = [for k, v in local.secret_arns : { Name = k, ValueFrom = v }]
    command      = ["tail", "-f", "/dev/null"]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.cloudwatch_log_group_name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = local.name
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  count                  = var.enabled ? 1 : 0
  name                   = local.name
  cluster                = var.cluster_name
  task_definition        = aws_ecs_task_definition.this[0].arn
  enable_execute_command = true
  desired_count          = 1
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 1
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.this[0].id]
  }

  platform_version = var.fargate_version

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  tags = var.tags
}
