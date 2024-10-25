terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
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
  auth_token                 = var.auth_token
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
  tags = merge(var.tags, {
    Duty = "redis"
    Name = "${var.name}-redis-cache"
  })
}

resource "aws_vpc_security_group_ingress_rule" "client_sg" {
  count             = var.create_security_groups ? 1 : 0
  security_group_id = aws_security_group.this[0].id

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "TCP"
  description                  = "Allows redis port from client sg"
  referenced_security_group_id = aws_security_group.client[0].id
}

resource "aws_vpc_security_group_ingress_rule" "other_sgs" {
  for_each          = var.create_security_groups ? toset(var.allowed_client_security_group_ids) : []
  security_group_id = aws_security_group.this[0].id

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "TCP"
  description                  = "Allows redis port from ${each.value}"
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_ingress_rule" "additional_cidrs" {
  for_each          = var.create_security_groups ? toset(var.additional_ingress_cidrs) : []
  security_group_id = aws_security_group.this[0].id

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "TCP"
  description = "Allows redis port from ${each.value}"
  cidr_ipv4   = each.value
}
