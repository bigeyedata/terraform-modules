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
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  name = var.name
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
  role = aws_iam_role.this.id
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
      }
    ]
  })
}

resource "aws_security_group" "this" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Used for validating networking"
  tags = merge(var.tags, {
    Name = var.name
  })

  egress {
    description      = "Allow outbound"
    from_port        = 0
    to_port          = local.max_port
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "client" {
  name        = "${var.name}-client"
  vpc_id      = var.vpc_id
  description = "allows ingress on all ports from troubleshooting instance"
  tags = merge(var.tags, {
    Name = "${var.name}-client"
  })

  ingress {
    description     = "Allow all traffic"
    from_port       = 0
    to_port         = local.max_port
    protocol        = "TCP"
    security_groups = [aws_security_group.this.id]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = var.tags
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions = jsonencode([{
    name   = var.name
    cpu    = 1024
    memory = 2048
    image  = "debian:bookworm-slim"
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.cloudwatch_log_group_name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = var.name
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name                   = var.name
  cluster                = var.cluster_name
  task_definition        = aws_ecs_task_definition.this.arn
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
    security_groups  = [aws_security_group.this.id]
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
