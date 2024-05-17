locals {
  rabbitmq_subnet_ids         = ["<subnet_id>"]
  rabbitmq_security_group_ids = ["<security_group_id>"]
}

resource "random_password" "rabbitmq_user_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rabbitmq_user_password" {
  name                    = format("bigeye/%s/datawatch/rabbitmq/password", local.name)
  recovery_window_in_days = 7
  tags = {
    stack = local.name
  }
}

resource "aws_secretsmanager_secret_version" "rabbitmq_user_password" {
  secret_id      = aws_secretsmanager_secret.rabbitmq_user_password.id
  secret_string  = random_password.rabbitmq_user_password.result
  version_stages = ["AWSCURRENT"]
}

resource "aws_mq_broker" "queue" {
  broker_name                = "test-bigeye"
  auto_minor_version_upgrade = false
  deployment_mode            = "SINGLE_INSTANCE"
  engine_type                = "RabbitMQ"
  engine_version             = "3.11.20"
  host_instance_type         = "mq.t3.micro"
  publicly_accessible        = false
  storage_type               = "ebs"
  authentication_strategy    = "simple"
  subnet_ids                 = local.rabbitmq_subnet_ids

  security_groups = local.rabbitmq_security_group_ids

  user {
    console_access = true
    username       = local.rabbitmq_bigeye_user
    password       = random_password.rabbitmq_user_password.result
  }
}

