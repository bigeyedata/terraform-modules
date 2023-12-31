terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
}

data "aws_secretsmanager_secret_version" "auth_token" {
  secret_id = var.auth_token_secret_arn
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = var.name
  description                = "Bigeye datawatch redis"
  engine                     = "redis"
  engine_version             = var.engine_version
  auto_minor_version_upgrade = false
  multi_az_enabled           = var.instance_count > 1 ? true : false
  node_type                  = var.instance_type
  num_cache_clusters         = var.instance_count

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  auth_token                 = data.aws_secretsmanager_secret_version.auth_token.secret_string
  security_group_ids = concat(
    var.create_security_groups ? [aws_security_group.this[0].id] : [],
    var.extra_security_group_ids
  )
  subnet_group_name = var.subnet_group_name

  snapshot_retention_limit   = 0
  automatic_failover_enabled = var.instance_count > 1 ? true : false
  maintenance_window         = var.maintenance_window

  log_delivery_configuration {
    destination      = var.cloudwatch_loggroup_name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = var.tags
}

resource "aws_security_group" "client" {
  count  = var.create_security_groups ? 1 : 0
  name   = "${var.name}-redis-client"
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Duty = "redisclient"
    Name = "${var.name}-redis-client"
  })
}

resource "aws_security_group" "this" {
  count  = var.create_security_groups ? 1 : 0
  name   = "${var.name}-redis-cache"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "TCP"
    security_groups = [aws_security_group.client[0].id]
  }

  tags = merge(var.tags, {
    Duty = "redis"
    Name = "${var.name}-redis-cache"
  })
}
