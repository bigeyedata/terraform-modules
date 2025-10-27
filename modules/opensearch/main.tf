locals {
  max_port            = 65535
  relevant_subnet_ids = var.instance_count < length(var.subnet_ids) ? slice(var.subnet_ids, 0, var.instance_count) : var.subnet_ids
  # Burstable class hardware is not supported for auto tune.
  auto_tune_enabled      = !can(regex("^t", var.master_node_instance_type))
  zone_awareness_enabled = var.instance_count > 1
  app                    = "temporal"
}

resource "aws_security_group" "this" {
  count       = var.create_security_groups ? 1 : 0
  name        = format("%s-opensearch", var.name)
  description = "Allows access to opensearch"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name}-opensearch"
    app  = local.app
  })
}

resource "aws_vpc_security_group_ingress_rule" "temporal_http" {
  count                        = var.create_security_groups ? length(var.ingress_security_group_ids) : 0
  security_group_id            = aws_security_group.this[0].id
  from_port                    = 80
  to_port                      = 80
  description                  = "Allows port 80 traffic"
  ip_protocol                  = "TCP"
  referenced_security_group_id = var.ingress_security_group_ids[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "temporal_https" {
  count                        = var.create_security_groups ? length(var.ingress_security_group_ids) : 0
  security_group_id            = aws_security_group.this[0].id
  from_port                    = 443
  to_port                      = 443
  description                  = "Allows port 443 traffic"
  ip_protocol                  = "TCP"
  referenced_security_group_id = var.ingress_security_group_ids[count.index]
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  count             = var.create_security_groups ? 1 : 0
  security_group_id = aws_security_group.this[0].id
  description       = "Allow outbound"
  from_port         = 0
  to_port           = local.max_port
  ip_protocol       = "TCP"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "temporal_http_additional_cidrs" {
  count             = var.create_security_groups ? length(var.additional_ingress_cidrs) : 0
  security_group_id = aws_security_group.this[0].id
  from_port         = 80
  to_port           = 80
  description       = "Allows port 80 traffic from ${var.additional_ingress_cidrs[count.index]}"
  ip_protocol       = "TCP"
  cidr_ipv4         = var.additional_ingress_cidrs[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "temporal_https_additional_cidrs" {
  count             = var.create_security_groups ? length(var.additional_ingress_cidrs) : 0
  security_group_id = aws_security_group.this[0].id
  from_port         = 443
  to_port           = 443
  description       = "Allows port 443 traffic from ${var.additional_ingress_cidrs[count.index]}"
  ip_protocol       = "TCP"
  cidr_ipv4         = var.additional_ingress_cidrs[count.index]
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.name
  engine_version = var.engine_version

  cluster_config {
    zone_awareness_enabled = local.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = local.zone_awareness_enabled == true ? toset([1]) : toset([])
      content {
        availability_zone_count = 3
      }
    }

    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.master_nodes_enabled
    dedicated_master_count   = var.master_nodes_enabled ? 3 : null
    dedicated_master_type    = var.master_node_instance_type
  }
  vpc_options {
    subnet_ids = local.relevant_subnet_ids
    security_group_ids = concat(
      var.create_security_groups ? [aws_security_group.this[0].id] : [],
      var.extra_security_group_ids
    )
  }

  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }
  node_to_node_encryption {
    enabled = true
  }
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }
  encrypt_at_rest {
    enabled = true
  }
  ebs_options {
    ebs_enabled = true
    throughput  = var.ebs_throughput
    iops        = var.ebs_iops
    volume_size = var.ebs_size
    volume_type = "gp3"
  }
  auto_tune_options {
    desired_state       = local.auto_tune_enabled ? "ENABLED" : "DISABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }
  tags = merge(var.tags, {
    app = local.app
  })
}

resource "aws_opensearch_domain_policy" "this" {
  domain_name = aws_opensearch_domain.this.domain_name
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "es:*"
        Resource = format("%s/*", aws_opensearch_domain.this.arn)
      }
    ]
  })
}
