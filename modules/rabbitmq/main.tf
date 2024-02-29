terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
}

resource "aws_mq_broker" "queue" {
  broker_name                = var.name
  auto_minor_version_upgrade = false
  deployment_mode            = var.deployment_mode
  engine_type                = "RabbitMQ"
  engine_version             = var.engine_version
  host_instance_type         = var.instance_type
  publicly_accessible        = false
  storage_type               = "ebs"
  authentication_strategy    = "simple"
  maintenance_window_start_time {
    day_of_week = var.maintenance_day
    time_of_day = var.maintenance_time
    time_zone   = "UTC"
  }

  logs {
    audit   = false
    general = true
  }

  subnet_ids = var.deployment_mode == "SINGLE_INSTANCE" ? [var.subnet_ids[0]] : var.subnet_ids

  security_groups = concat(
    var.create_security_groups ? [aws_security_group.this[0].id] : [],
    var.extra_security_groups,
  )

  user {
    console_access = true
    username       = var.user_name
    password       = var.user_password
  }

  tags = var.tags
}

resource "aws_security_group" "client" {
  count  = var.create_security_groups ? 1 : 0
  name   = "${var.name}-rabbitmq-client"
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Duty = "rabbitmqclient"
    Name = "${var.name}-rabbitmq-client"
  })
}

resource "aws_security_group" "this" {
  count  = var.create_security_groups ? 1 : 0
  name   = "${var.name}-rabbitmq"
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Duty = "rabbitmq"
    Name = "${var.name}-rabbitmq"
  })
}

resource "aws_vpc_security_group_ingress_rule" "amqps_bigeye" {
  count                        = var.create_security_groups ? 1 : 0
  description                  = "AMPQS connections from Bigeye"
  security_group_id            = aws_security_group.this[0].id
  from_port                    = 5671
  to_port                      = 5671
  ip_protocol                  = "TCP"
  referenced_security_group_id = aws_security_group.client[0].id
}

resource "aws_vpc_security_group_ingress_rule" "amqps_extra_cidr_blocks" {
  for_each          = toset(var.extra_ingress_cidr_blocks)
  description       = "AMPQS connections from custom cidr blocks"
  security_group_id = aws_security_group.this[0].id
  from_port         = 5671
  to_port           = 5671
  ip_protocol       = "TCP"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "https_extra_cidr_blocks" {
  for_each          = toset(var.extra_ingress_cidr_blocks)
  description       = "RabbitMQ admin console from custom cidr blocks"
  security_group_id = aws_security_group.this[0].id
  from_port         = 433
  to_port           = 433
  ip_protocol       = "TCP"
  cidr_ipv4         = each.value
}
