terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

#==============================================
# VPC
#==============================================
module "vpc" {
  count = local.create_vpc ? 1 : 0
  # https://github.com/terraform-aws-modules/terraform-aws-vpc
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = local.name
  azs  = local.vpc_availability_zones

  cidr               = var.vpc_cidr_block
  enable_nat_gateway = true
  single_nat_gateway = var.vpc_single_nat_gateway

  enable_ipv6 = false

  tags = local.tags

  # Public subnets
  public_subnets = [
    "${local.vpc_cidr_prefix}.1.0/24",
    "${local.vpc_cidr_prefix}.3.0/24",
    "${local.vpc_cidr_prefix}.5.0/24",
  ]
  public_subnet_suffix = "dmz"
  public_subnet_tags = merge(local.tags, {
    Duty   = "public"
    Public = "true"
  })

  # Internal subnets
  intra_subnets = [
    "${local.vpc_cidr_prefix}.2.0/24",
    "${local.vpc_cidr_prefix}.4.0/24",
    "${local.vpc_cidr_prefix}.6.0/24",
  ]
  intra_subnet_suffix = "internal"
  intra_subnet_tags = merge(local.tags, {
    Duty   = "internal"
    Public = "false"
  })

  # Private subnets
  private_subnets = [
    "${local.vpc_cidr_prefix}.64.0/18",
    "${local.vpc_cidr_prefix}.128.0/18",
    "${local.vpc_cidr_prefix}.192.0/18",
  ]
  private_subnet_suffix = "application"
  private_subnet_tags = merge(local.tags, {
    Duty   = "application"
    Public = "false"
  })

  # Database subnets
  create_database_subnet_route_table = true
  database_subnets = [
    "${local.vpc_cidr_prefix}.8.0/24",
    "${local.vpc_cidr_prefix}.10.0/24",
    "${local.vpc_cidr_prefix}.12.0/24",
  ]
  database_subnet_suffix = "database"
  database_subnet_tags = merge(local.tags, {
    Duty   = "database"
    Public = "false"
  })

  # Cache subnets
  create_elasticache_subnet_route_table = true
  elasticache_subnets = [
    "${local.vpc_cidr_prefix}.14.0/24",
    "${local.vpc_cidr_prefix}.16.0/24",
    "${local.vpc_cidr_prefix}.18.0/24",
  ]
  elasticache_subnet_suffix = "misc"
  elasticache_subnet_tags = merge(local.tags, {
    Duty   = "misc"
    Public = "false"
  })

  enable_flow_log           = var.vpc_flow_logs_bucket_arn != ""
  flow_log_destination_type = var.vpc_flow_logs_bucket_arn == "" ? null : "s3"
  flow_log_destination_arn  = var.vpc_flow_logs_bucket_arn
}

# VPC input validation
data "aws_vpc" "this" {
  id = local.create_vpc ? module.vpc[0].vpc_id : var.byovpc_vpc_id
  lifecycle {
    postcondition {
      condition     = (!local.create_vpc && length(var.byovpc_rabbitmq_subnet_ids) > 0) || (local.create_vpc && length(var.byovpc_rabbitmq_subnet_ids) == 0)
      error_message = "if byovpc_vpc_id is specified, byovpc_rabbitmq_subnet_ids must not be empty, otherwise it must be empty"
    }

    postcondition {
      condition     = (!local.create_vpc && length(var.byovpc_internal_subnet_ids) > 0) || (local.create_vpc && length(var.byovpc_internal_subnet_ids) == 0)
      error_message = "if byovpc_vpc_id is specified, byovpc_internal_subnet_ids must not be empty, otherwise it must be empty"
    }

    postcondition {
      condition     = (!local.create_vpc && length(var.byovpc_application_subnet_ids) > 0) || (local.create_vpc && length(var.byovpc_application_subnet_ids) == 0)
      error_message = "if byovpc_vpc_id is specified, byovpc_application_subnet_ids must not be empty, otherwise it must be empty"
    }

    postcondition {
      condition     = (length(var.byovpc_public_subnet_ids) == 0 && local.create_vpc) || (length(var.byovpc_public_subnet_ids) == 0 && !var.internet_facing) || (length(var.byovpc_public_subnet_ids) > 0 && !local.create_vpc && var.internet_facing)
      error_message = "byovpc_public_subnet_ids must not be empty if byovpc_vpc_id is specified and internet_facing is true, otherwise it must be empty"
    }

    postcondition {
      condition     = (!local.create_vpc && length(var.byovpc_redis_subnet_group_name) > 0) || (local.create_vpc && length(var.byovpc_redis_subnet_group_name) == 0)
      error_message = "if byovpc_vpc_id is specified, byovpc_redis_subnet_group_name must be specified, otherwise it must be empty"
    }

    postcondition {
      condition     = (!local.create_vpc && length(var.byovpc_database_subnet_group_name) > 0) || (local.create_vpc && length(var.byovpc_database_subnet_group_name) == 0)
      error_message = "if byovpc_vpc_id is specified, byovpc_database_subnet_group_name must be specified, otherwise it must be empty"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.rabbitmq_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide RabbitMQ a security group using rabbitmq_extra_security_group_ids (port 5671)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.redis_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide Redis a security group using redis_extra_security_group_ids (port 6379)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.datawatch_rds_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide the Datawatch RDS instance a security group using datawatch_rds_extra_security_group_ids (port 3306)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.temporal_rds_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide the Temporal RDS instance a security group using temporal_rds_extra_security_group_ids (port 3306)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.haproxy_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the HAProxy lb using haproxy_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.web_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the web lb using web_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.monocle_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the monocle lb using monocle_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.toretto_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the toretto lb using toretto_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.temporalui_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the temporalui lb using temporalui_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.temporal_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the temporal lb using temporal_lb_extra_security_group_ids (port 443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.scheduler_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the scheduler lb using scheduler_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.datawatch_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the datawatch lb using datawatch_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.datawork_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the datawork lb using datawork_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.metricwork_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the metricwork lb using metricwork_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.haproxy_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the HAProxy ECS tasks using haproxy_extra_security_group_ids (ports ${var.haproxy_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.web_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the web ECS tasks using web_extra_security_group_ids (ports ${var.web_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.monocle_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the monocle ECS tasks using monocle_extra_security_group_ids (ports ${var.monocle_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.toretto_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the toretto ECS tasks using toretto_extra_security_group_ids (ports ${var.toretto_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.temporalui_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the temporalui ECS tasks using temporalui_extra_security_group_ids (ports ${var.temporalui_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.temporal_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the temporal ECS tasks using temporal_extra_security_group_ids (port 7233)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.scheduler_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the scheduler ECS tasks using scheduler_extra_security_group_ids (ports ${var.scheduler_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.datawatch_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the datawatch ECS tasks using datawatch_extra_security_group_ids (ports ${var.datawatch_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.datawork_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the datawork ECS tasks using datawork_extra_security_group_ids (port ${var.datawork_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.metricwork_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the metricwork ECS tasks using metricwork_extra_security_group_ids (port ${var.metricwork_port})"
    }

    postcondition {
      condition     = (var.create_dns_records == false && var.acm_certificate_arn != "") || var.create_dns_records == true
      error_message = "If create_dns_records is false, then you must specify acm_certificate_arn, this should be a wildcard certificate for '*.${var.top_level_dns_name}'"
    }
  }
}

resource "aws_security_group" "vpc_endpoint" {
  count = local.create_vpc ? 1 : 0

  name        = "${local.name}-vpc-endpoints"
  description = "Allows traffic through VPC endpoint"
  vpc_id      = local.vpc_id
  tags = merge(local.tags, {
    Name = "${local.name}-vpc-endpoints"
  })

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "Allow HTTP traffic"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "Allow HTTPS traffic"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = local.max_port
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all egress"
  }
}

module "vpc_endpoints" {
  count   = local.create_vpc ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.1.2"

  vpc_id             = local.vpc_id
  security_group_ids = [aws_security_group.vpc_endpoint[0].id]
  tags               = local.tags

  endpoints = {
    s3 = {
      service      = "s3"
      tags         = merge(local.tags, { Name = "${local.name}-s3endpoint" })
      service_type = "Gateway"
      route_table_ids = concat(
        module.vpc[0].database_route_table_ids,
        module.vpc[0].elasticache_route_table_ids,
        module.vpc[0].intra_route_table_ids,
        module.vpc[0].private_route_table_ids,
        module.vpc[0].public_route_table_ids
      )
    }
    ecr_api = {
      service             = "ecr.api"
      service_type        = "Interface"
      subnet_ids          = local.application_subnet_ids
      private_dns_enabled = true
      tags = merge(local.tags, {
        Name = "${local.name}-ecrapi-endpoint"
      })
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      subnet_ids          = local.application_subnet_ids
      private_dns_enabled = true
      tags = merge(local.tags, {
        Name = "${local.name}-ecrdkr-endpoint"
      })
    }
    logs = {
      service             = "logs"
      service_type        = "Interface"
      subnet_ids          = local.application_subnet_ids
      private_dns_enabled = true
      tags = merge(local.tags, {
        Name = "${local.name}-logs-endpoint"
      })
    }
    secretsmanager = {
      service             = "secretsmanager"
      service_type        = "Interface"
      subnet_ids          = local.application_subnet_ids
      private_dns_enabled = true
      tags = merge(local.tags, {
        Name = "${local.name}-secretsmanager-endpoint"
      })
    }
  }
}

#======================================================
# DNS
#======================================================
data "aws_route53_zone" "this" {
  name = "${var.top_level_dns_name}."
}

resource "aws_route53_record" "apex" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.vanity_dns_name
  type    = "A"
  alias {
    name                   = module.haproxy.dns_name
    zone_id                = module.haproxy.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "datawatch" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.datawatch_dns_name
  type    = "CNAME"
  ttl     = 3600
  records = [module.datawatch.dns_name]
}

resource "aws_route53_record" "datawatch_mysql" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.datawatch_mysql_vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.datawatch_rds.primary_dns_name]
}

resource "aws_route53_record" "datawatch_mysql_replica" {
  count   = var.create_dns_records && var.datawatch_rds_replica_enabled ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.datawatch_mysql_replica_vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.datawatch_rds.replica_dns_name]
}

resource "aws_route53_record" "datawork" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.datawork_dns_name
  type    = "CNAME"
  ttl     = 3600
  records = [module.datawork.dns_name]
}

resource "aws_route53_record" "metricwork" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.metricwork_dns_name
  type    = "CNAME"
  ttl     = 3600
  records = [module.metricwork.dns_name]
}

resource "aws_route53_record" "monocle" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.monocle_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.monocle.dns_name]
}

resource "aws_route53_record" "web" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.web_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.web.dns_name]
}

resource "aws_route53_record" "toretto" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.toretto_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.toretto.dns_name]
}

resource "aws_route53_record" "scheduler" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.scheduler_dns_name
  type    = "CNAME"
  ttl     = 3600
  records = [module.scheduler.dns_name]
}

resource "aws_route53_record" "temporalui" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.temporalui_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.temporalui.dns_name]
}

resource "aws_route53_record" "temporal" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.temporal_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.temporal.dns_name]
}

resource "aws_route53_record" "temporal_mysql" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.temporal_mysql_vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.temporal_rds.primary_dns_name]
}

#======================================================
# Certificate Manager
#======================================================
resource "aws_acm_certificate" "wildcard" {
  count             = local.create_acm_cert ? 1 : 0
  domain_name       = "*.${var.top_level_dns_name}"
  validation_method = "DNS"
  tags              = local.tags
}

resource "aws_route53_record" "wildcard" {
  for_each = {
    for dvo in local.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}
#======================================================
# ECS
#======================================================
resource "aws_ecs_cluster" "this" {
  name = local.name
  setting {
    name  = "containerInsights"
    value = var.ecs_enable_container_insights ? "enabled" : "disabled"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "ecs" {
  name = "${local.name}-service-role"
  tags = local.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution" {
  role = aws_iam_role.ecs.id
  name = "ECSTaskExecution"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatch"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.bigeye.arn}:log-stream:*",
          "${aws_cloudwatch_log_group.temporal.arn}:log-stream:*",
        ]
      }
    ]
  })

}

resource "aws_iam_role_policy" "ecs_secrets" {
  role = aws_iam_role.ecs.id
  name = "AllowAccessSecrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowGetSecrets"
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/stack" = local.name
          }
        }
      }
    ]
  })
}

#======================================================
# Cloudwatch Logs
#======================================================
resource "aws_cloudwatch_log_group" "bigeye" {
  name              = local.name
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "temporal" {
  name              = "${local.name}-temporal"
  retention_in_days = 365
  tags              = local.tags
}

#======================================================
# Admin container
#======================================================
module "bigeye_admin" {
  enabled                   = var.enable_bigeye_admin_module
  source                    = "../admin"
  image                     = format("%s/%s%s:%s", local.image_registry, "bigeye-admin", var.image_repository_suffix, local.bigeye_admin_image_tag)
  vpc_id                    = local.vpc_id
  subnet_ids                = local.application_subnet_ids
  tags                      = merge(local.tags, { app = "bigeye-admin" })
  cluster_name              = local.name
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  execution_role_arn        = aws_iam_role.ecs.arn
  fargate_version           = var.fargate_version

  stack_name = local.name

  haproxy_domain_name    = local.vanity_dns_name
  web_domain_name        = local.web_dns_name
  monocle_domain_name    = local.monocle_dns_name
  toretto_domain_name    = local.toretto_dns_name
  temporal_domain_name   = local.temporal_dns_name
  temporalui_domain_name = local.temporalui_dns_name
  datawatch_domain_name  = local.datawatch_dns_name
  datawork_domain_name   = local.datawork_dns_name
  metricwork_domain_name = local.metricwork_dns_name
  scheduler_domain_name  = local.scheduler_dns_name

  haproxy_resource_name    = "${local.name}-haproxy"
  web_resource_name        = "${local.name}-web"
  monocle_resource_name    = "${local.name}-monocle"
  toretto_resource_name    = "${local.name}-toretto"
  temporal_resource_name   = "${local.name}-temporal"
  temporalui_resource_name = "${local.name}-temporalui"
  datawatch_resource_name  = "${local.name}-datawatch"
  datawork_resource_name   = "${local.name}-datawork"
  metricwork_resource_name = "${local.name}-metricwork"
  scheduler_resource_name  = "${local.name}-scheduler"

  datawatch_rds_identifier          = module.datawatch_rds.identifier
  datawatch_rds_hostname            = module.datawatch_rds.primary_dns_name
  datawatch_rds_username            = module.datawatch_rds.master_user_name
  datawatch_rds_password_secret_arn = local.datawatch_rds_password_secret_arn
  datawatch_rds_db_name             = module.datawatch_rds.database_name

  temporal_rds_identifier          = module.temporal_rds.identifier
  temporal_rds_hostname            = module.temporal_rds.primary_dns_name
  temporal_rds_username            = module.temporal_rds.master_user_name
  temporal_rds_password_secret_arn = local.temporal_rds_password_secret_arn
  temporal_rds_db_name             = module.temporal_rds.database_name

  redis_domain_name         = module.redis.primary_endpoint_dns_name
  redis_password_secret_arn = local.redis_auth_token_secret_arn

  temporal_port = local.temporal_lb_port

  rabbitmq_endpoint            = module.rabbitmq.endpoint
  rabbitmq_username            = var.rabbitmq_user_name
  rabbitmq_password_secret_arn = local.rabbitmq_user_password_secret_arn
}

#======================================================
# RabbitMQ
#======================================================
resource "random_password" "rabbitmq_user_password" {
  count   = local.create_rabbitmq_user_password_secret ? 1 : 0
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rabbitmq_user_password" {
  count                   = local.create_rabbitmq_user_password_secret ? 1 : 0
  name                    = format("bigeye/%s/datawatch/rabbitmq/password", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "rabbitmq_user_password" {
  count         = local.create_rabbitmq_user_password_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.rabbitmq_user_password[0].id
  secret_string = random_password.rabbitmq_user_password[0].result
}

data "aws_secretsmanager_secret_version" "byo_rabbitmq_user_password" {
  count     = local.create_rabbitmq_user_password_secret ? 0 : 1
  secret_id = var.rabbitmq_user_password_secret_arn
}

module "rabbitmq" {
  depends_on                = [aws_secretsmanager_secret_version.rabbitmq_user_password]
  source                    = "../rabbitmq"
  name                      = local.name
  vpc_id                    = local.vpc_id
  deployment_mode           = local.rabbitmq_cluster_mode_enabled ? "CLUSTER_MULTI_AZ" : "SINGLE_INSTANCE"
  create_security_groups    = var.create_security_groups
  extra_security_groups     = concat(var.rabbitmq_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  extra_ingress_cidr_blocks = var.rabbitmq_extra_ingress_cidr_blocks
  subnet_ids                = local.rabbitmq_subnet_group_ids
  instance_type             = var.rabbitmq_instance_type
  engine_version            = var.rabbitmq_engine_version
  maintenance_day           = var.rabbitmq_maintenance_day
  maintenance_time          = var.rabbitmq_maintenance_time
  user_name                 = var.rabbitmq_user_name
  user_password             = local.create_rabbitmq_user_password_secret ? aws_secretsmanager_secret_version.rabbitmq_user_password[0].secret_string : data.aws_secretsmanager_secret_version.byo_rabbitmq_user_password[0].secret_string
  tags                      = merge(local.tags, { app = "datawatch" })
}

#======================================================
# S3
#======================================================
resource "random_string" "models_bucket_suffix" {
  length  = 8
  special = false
  numeric = false
  upper   = false
}

resource "aws_s3_bucket" "models" {
  bucket = local.models_bucket_has_name_override ? var.ml_models_s3_bucket_name_override : "${local.name}-models-${random_string.models_bucket_suffix.result}"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "models" {
  bucket = aws_s3_bucket.models.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "models" {
  bucket = aws_s3_bucket.models.id
  rule {
    id     = "ExpireOldModels"
    status = "Enabled"
    expiration {
      days = 30
    }
  }
}

resource "random_string" "large_payload" {
  length  = 8
  special = false
  numeric = false
  upper   = false
}

resource "aws_s3_bucket" "large_payload" {
  bucket = "${local.name}-large-payload-${random_string.large_payload.result}"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "large_payload" {
  bucket = aws_s3_bucket.large_payload.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "large_payload" {
  bucket = aws_s3_bucket.large_payload.id
  rule {
    id     = "ExpireOldPayloads"
    status = "Enabled"
    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_policy" "large_payload" {
  bucket = aws_s3_bucket.large_payload.id
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.large_payload.arn,
          format("%s/*", aws_s3_bucket.large_payload.arn)
        ]
        Principal = {
          AWS = aws_iam_role.datawatch.arn
        }
      }
    ]
  })
}

#======================================================
# HA Proxy
#======================================================
resource "random_password" "adminpages_password" {
  count   = local.create_adminpages_password_secret ? 1 : 0
  length  = 16
  special = false
}
resource "aws_secretsmanager_secret" "adminpages_password" {
  count                   = local.create_adminpages_password_secret ? 1 : 0
  name                    = format("bigeye/%s/bigeye/adminpages/password", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "adminpages_password" {
  count         = local.create_adminpages_password_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.adminpages_password[0].id
  secret_string = random_password.adminpages_password[0].result
}

module "haproxy" {
  depends_on = [aws_secretsmanager_secret_version.adminpages_password]
  source     = "../simpleservice"
  app        = "haproxy"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-haproxy"
  tags       = merge(local.tags, { app = "haproxy" })

  internet_facing               = var.internet_facing
  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = concat(var.haproxy_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  traffic_port                  = var.haproxy_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/haproxy-health"
  healthcheck_interval             = 15
  healthcheck_timeout              = 5
  healthcheck_unhealthy_threshold  = 3
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = var.internet_facing ? local.public_alb_subnet_ids : local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.haproxy_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_stickiness_enabled            = true
  lb_deregistration_delay          = 900

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "haproxy")

  # Task settings
  desired_count             = var.haproxy_desired_count
  cpu                       = var.haproxy_cpu
  memory                    = var.haproxy_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "haproxy", var.image_repository_suffix)
  image_tag                 = local.haproxy_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn
  datadog_additional_docker_labels = {
    "com.datadoghq.ad.check_names"  = "[\"haproxy\"]"
    "com.datadoghq.ad.init_configs" = "[{\"service\":\"haproxy\"}]"
    "com.datadoghq.ad.instances"    = "[{\"url\":\"http://%%host%%:${var.haproxy_port}/haproxy-status;csv;norefresh\", \"username\":\"bigeyesupport\", \"password\":\"%%env_BIGEYE_ADMIN_PAGES_PASSWORD%%\", \"tags\":[\"app:haproxy\", \"env:${local.name}\", \"instance:${var.instance}\", \"stack:${local.name}\"]}]"
  }
  datadog_agent_additional_secret_arns = {
    BIGEYE_ADMIN_PAGES_PASSWORD = local.adminpages_password_secret_arn
  }


  environment_variables = merge(
    {
      ENVIRONMENT      = var.environment
      INSTANCE         = var.instance
      DW_HOST          = local.datawatch_dns_name
      DW_PORT          = "443"
      SCHEDULER_HOST   = local.scheduler_dns_name
      SCHEDULER_PORT   = "443"
      TORETTO_HOST     = local.toretto_dns_name
      TORETTO_PORT     = "443"
      MONOCLE_HOST     = local.monocle_dns_name
      MONOCLE_PORT     = "443"
      WEB_HOST         = local.web_dns_name
      WEB_PORT         = "443"
      REDIRECT_ADDRESS = "https://${local.vanity_dns_name}"
      PORT             = var.haproxy_port
      HAPROXY_PORT     = var.haproxy_port
    },
    var.haproxy_additional_environment_vars,
  )

  secret_arns = merge(
    {
      BIGEYE_ADMIN_PAGES_PASSWORD = local.adminpages_password_secret_arn
    },
    var.haproxy_additional_secret_arns,
  )
}

#======================================================
# Web
#======================================================
module "web" {
  source   = "../simpleservice"
  app      = "web"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-web"
  tags     = merge(local.tags, { app = "web" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = concat(var.web_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  traffic_port                  = var.web_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/next-status"
  healthcheck_interval             = 15
  healthcheck_unhealthy_threshold  = 3
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 180
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.web_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_stickiness_enabled            = true
  lb_deregistration_delay          = 120

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "web")

  # Task settings
  desired_count             = var.web_desired_count
  cpu                       = var.web_cpu
  memory                    = var.web_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "web", var.image_repository_suffix)
  image_tag                 = local.web_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn


  environment_variables = merge(
    local.web_dd_env_vars,
    {
      ENVIRONMENT       = var.environment
      INSTANCE          = var.instance
      DOCKER_ENV        = var.environment
      APP_ENVIRONMENT   = var.environment
      NODE_ENV          = "production"
      PORT              = var.web_port
      DROPWIZARD_HOST   = "https://${local.datawatch_dns_name}"
      DATAWATCH_ADDRESS = "https://${local.datawatch_dns_name}"
      MAX_NODE_MEM_MB   = "4096"
    },
    var.web_additional_environment_vars,
  )

  secret_arns = var.web_additional_secret_arns
}

#======================================================
# Temporal
#======================================================
resource "random_password" "temporal_rds_password" {
  count   = local.create_temporal_rds_password_secret ? 1 : 0
  length  = 16
  special = false
}
resource "aws_secretsmanager_secret" "temporal_rds_password" {
  count                   = local.create_temporal_rds_password_secret ? 1 : 0
  name                    = format("bigeye/%s/temporal/rds/password", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "temporal_rds_password" {
  count         = local.create_temporal_rds_password_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.temporal_rds_password[0].id
  secret_string = random_password.temporal_rds_password[0].result
}
data "aws_secretsmanager_secret_version" "byo_temporal_rds_password" {
  count     = local.create_temporal_rds_password_secret ? 0 : 1
  secret_id = var.temporal_rds_root_user_password_secret_arn
}

module "temporal_rds" {
  depends_on                            = [aws_secretsmanager_secret_version.temporal_rds_password]
  source                                = "../rds"
  name                                  = "${local.name}-temporal"
  db_name                               = var.temporal_rds_db_name
  root_user_name                        = "bigeye"
  root_user_password                    = local.create_temporal_rds_password_secret ? aws_secretsmanager_secret_version.temporal_rds_password[0].secret_string : data.aws_secretsmanager_secret_version.byo_temporal_rds_password[0].secret_string
  deletion_protection                   = var.deletion_protection
  apply_immediately                     = var.rds_apply_immediately
  snapshot_identifier                   = var.temporal_rds_snapshot_identifier
  vpc_id                                = local.vpc_id
  engine_version                        = var.temporal_rds_engine_version
  allocated_storage                     = var.temporal_rds_allocated_storage
  max_allocated_storage                 = var.temporal_rds_max_allocated_storage
  storage_type                          = "gp3"
  db_subnet_group_name                  = local.database_subnet_group_name
  create_security_groups                = var.create_security_groups
  extra_security_group_ids              = concat(var.temporal_rds_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  allowed_client_security_group_ids     = var.create_security_groups ? [aws_security_group.temporal[0].id] : []
  instance_class                        = var.temporal_rds_instance_type
  backup_window                         = var.rds_backup_window
  backup_retention_period               = var.temporal_rds_backup_retention_period
  maintenance_window                    = var.rds_maintenance_window
  enable_performance_insights           = local.temporal_rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  enable_multi_az                       = var.redundant_infrastructure ? true : false
  create_option_group                   = false
  create_parameter_group                = local.temporal_rds_create_parameter_group
  parameter_group_name                  = local.temporal_rds_create_parameter_group ? "${local.name}-temporal" : null
  parameters                            = local.temporal_rds_create_parameter_group ? var.temporal_rds_parameters : null
  tags                                  = merge(local.tags, { app = "temporal" }, var.temporal_rds_additional_tags)
  primary_additional_tags               = var.temporal_rds_primary_additional_tags
  replica_additional_tags               = var.temporal_rds_primary_additional_tags
}

resource "aws_security_group" "temporal_lb" {
  count       = var.create_security_groups ? 1 : 0
  name        = "${local.name}-temporal-lb"
  description = "Allows traffic to the temporal load balancer"
  vpc_id      = local.vpc_id
  tags = merge(local.tags, {
    Name = "${local.name}-temporal-lb"
  })

  ingress {
    description = "Traffic port open to anywhere"
    from_port   = local.temporal_lb_port
    to_port     = local.temporal_lb_port
    protocol    = "TCP"
    cidr_blocks = var.temporal_internet_facing ? ["0.0.0.0/0"] : [var.vpc_cidr_block]
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

resource "aws_lb" "temporal" {
  name                             = "${local.name}-temporal"
  internal                         = var.temporal_internet_facing ? false : true
  load_balancer_type               = "network"
  subnets                          = var.temporal_internet_facing ? local.public_alb_subnet_ids : local.internal_service_alb_subnet_ids
  enable_cross_zone_load_balancing = true
  security_groups                  = concat(aws_security_group.temporal_lb[*].id, var.temporal_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  tags                             = merge(local.tags, { app = "temporal" })

  access_logs {
    enabled = var.elb_access_logs_enabled
    bucket  = var.elb_access_logs_bucket
    prefix  = format("%s-%s", local.elb_access_logs_prefix, "temporal")
  }
}

resource "aws_lb_target_group" "temporal" {
  name                 = "${local.name}-temporal"
  port                 = 7233
  protocol             = "TCP"
  vpc_id               = local.vpc_id
  target_type          = "ip"
  deregistration_delay = 300
  tags                 = merge(local.tags, { app = "temporal" })

  health_check {
    enabled             = true
    protocol            = "TCP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 10
  }
}

resource "aws_lb_listener" "temporal" {
  depends_on        = [aws_lb.temporal, aws_lb_target_group.temporal]
  load_balancer_arn = aws_lb.temporal.arn
  port              = tostring(local.temporal_lb_port)
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.temporal.arn
  }
}

locals {
  temporal_datadog_container_def = {
    name   = "datadog-agent"
    image  = var.datadog_agent_image
    cpu    = var.datadog_agent_cpu
    memory = var.datadog_agent_memory
    dockerLabels = {
      "com.datadoghq.ad.check_names" : "[\"temporal\"]",
      "com.datadoghq.ad.init_configs" : "[{}]",
      "com.datadoghq.ad.instances" : "[\n    {\n      \"openmetrics_endpoint\": \"http://localhost:9091/metrics\",\n      \"collect_histogram_buckets\": true,\n      \"histogram_buckets_as_distributions\": true,\n      \"collect_counters_with_distributions\": true,\n      \"tags\": [\n        \"app:temporal\",\n        \"instance:${var.instance}\",\n        \"stack:${local.name}\"\n      ]\n    }\n  ]\n",
      "com.datadoghq.tags.app" : "temporal",
      "com.datadoghq.tags.env" : local.name
      "com.datadoghq.tags.instance" : var.instance
      "com.datadoghq.tags.service" : "temporal"
      "com.datadoghq.tags.stack" : local.name
    }
    essential   = true
    mountPoints = []
    volumesFrom = []
    portMappings = [
      {
        containerPort = 8126
        hostPort      = 8126
        protocol      = "tcp"
      },
      {
        containerPort = 8125
        hostPort      = 8125
        protocol      = "tcp"
      }
    ]
    environment = [for k, v in local.temporal_datadog_environment_variables : { name = k, value = v }]
    secrets     = [for k, v in local.temporal_datadog_secret_arns : { Name = k, ValueFrom = v }]
  }
  temporal_datadog_secret_arns = {
    DD_API_KEY = var.datadog_agent_api_key_secret_arn
  }
  temporal_datadog_environment_variables = {
    DD_APM_ENABLED                 = "true"
    DD_DOGSTATSD_NON_LOCAL_TRAFFIC = "true"
    DD_DOGSTATSD_TAG_CARDINALITY   = "orchestrator"
    ECS_FARGATE                    = "true"
  }
  temporal_datadog_docker_labels = var.datadog_agent_enabled ? {
    "com.datadoghq.tags.app"      = "temporal"
    "com.datadoghq.tags.env"      = local.name
    "com.datadoghq.tags.instance" = var.instance
    "com.datadoghq.tags.service"  = "temporal"
    "com.datadoghq.tags.stack"    = local.name
  } : {}

  temporal_environment_variables = merge(
    local.temporal_dd_env_vars,
    {
      ENVIRONMENT                                          = var.environment
      INSTANCE                                             = var.instance
      DB                                                   = "mysql8"
      DB_PORT                                              = "3306"
      DBNAME                                               = "temporal"
      MYSQL_SEEDS                                          = local.temporal_mysql_dns_name
      MYSQL_USER                                           = "bigeye"
      NUM_HISTORY_SHARDS                                   = tostring(var.temporal_num_history_shards)
      PROMETHEUS_ENDPOINT                                  = "0.0.0.0:9091"
      TEMPORAL_TLS_REQUIRE_CLIENT_AUTH                     = "true"
      TEMPORAL_TLS_FRONTEND_DISABLE_HOST_VERIFICATION      = var.temporal_use_default_certificates ? "true" : "false"
      TEMPORAL_TLS_INTERNODE_DISABLE_HOST_VERIFICATION     = var.temporal_use_default_certificates ? "true" : "false"
      TEMPORAL_TLS_INTERNODE_SERVER_NAME                   = local.temporal_dns_name
      TEMPORAL_TLS_FRONTEND_SERVER_NAME                    = local.temporal_dns_name
      TEMPORAL_PER_NAMESPACE_WORKER_COUNT                  = local.temporal_per_namespace_worker_count
      TEMPORAL_MAX_CONCURRENT_WORKFLOW_TASK_POLLERS        = local.temporal_max_concurrent_workflow_task_pollers
      TEMPORAL_FRONTEND_PERSISTENCE_MAX_QPS                = local.temporal_frontend_persistence_max_qps
      TEMPORAL_HISTORY_PERSISTENCE_MAX_QPS                 = local.temporal_history_persistence_max_qps
      TEMPORAL_MATCHING_PERSISTENCE_MAX_QPS                = local.temporal_matching_persistence_max_qps
      TEMPORAL_WORKER_PERSISTENCE_MAX_QPS                  = local.temporal_worker_persistence_max_qps
      TEMPORAL_SYSTEM_VISIBILITY_PERSISTENCE_MAX_READ_QPS  = local.temporal_system_visibility_persistence_max_read_qps
      TEMPORAL_SYSTEM_VISIBILITY_PERSISTENCE_MAX_WRITE_QPS = local.temporal_system_visibility_persistence_max_write_qps

      TEMPORAL_TLS_DISABLE_HOST_VERIFICATION = var.temporal_use_default_certificates ? "true" : "false"
      TEMPORAL_TLS_SERVER_NAME               = local.temporal_dns_name
      SQL_MAX_IDLE_CONNS                     = "10"
    },
    var.temporal_additional_environment_vars,
  )

  temporal_secret_arns = merge(
    {
      "MYSQL_PWD" = local.temporal_rds_password_secret_arn
    },
    var.temporal_additional_secret_arns,
  )

  log_configuration_def = var.temporal_logging_enabled ? {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = aws_cloudwatch_log_group.temporal.name
      "awslogs-region"        = local.aws_region
      "awslogs-stream-prefix" = "${local.name}-temporal"
    }
  } : null

  temporal_container_def = {
    name             = "${local.name}-temporal"
    cpu              = var.datadog_agent_enabled ? var.temporal_cpu - var.datadog_agent_cpu : var.temporal_cpu
    memory           = var.datadog_agent_enabled ? var.temporal_memory - var.datadog_agent_memory : var.temporal_memory
    dockerLabels     = local.temporal_datadog_docker_labels
    image            = format("%s/%s%s:%s", local.image_registry, "temporal", var.image_repository_suffix, local.temporal_image_tag)
    environment      = [for k, v in local.temporal_environment_variables : { Name = k, Value = v }]
    secrets          = [for k, v in local.temporal_secret_arns : { Name = k, ValueFrom = v }]
    logConfiguration = local.log_configuration_def
    portMappings = [
      # Frontend service membership
      {
        containerPort = 6933
        hostPort      = 6933
        protocol      = "tcp"
      },
      # History service membership
      {
        containerPort = 6934
        hostPort      = 6934
        protocol      = "tcp"
      },
      # Matching service membership
      {
        containerPort = 6935
        hostPort      = 6935
        protocol      = "tcp"
      },
      # Worker service membership
      {
        containerPort = 6939
        hostPort      = 6939
        protocol      = "tcp"
      },
      # Frontend service handler (API)
      {
        containerPort = 7233
        hostPort      = 7233
        protocol      = "tcp"
      },
      # History service handler
      {
        containerPort = 7234
        hostPort      = 7234
        protocol      = "tcp"
      },
      # Matching service handler
      {
        containerPort = 7235
        hostPort      = 7235
        protocol      = "tcp"
      },
      # Worker service handler
      {
        containerPort = 7239
        hostPort      = 7239
        protocol      = "tcp"
      },
      # Prometheus
      {
        containerPort = 9091
        hostPort      = 9091
        protocol      = "tcp"
      },
    ]
  }
}

resource "aws_ecs_task_definition" "temporal" {
  family                   = "${local.name}-temporal"
  cpu                      = var.temporal_cpu
  memory                   = var.temporal_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = merge(local.tags, { app = "temporal" })
  execution_role_arn       = aws_iam_role.ecs.arn
  container_definitions    = var.datadog_agent_enabled ? jsonencode([local.temporal_container_def, local.temporal_datadog_container_def]) : jsonencode([local.temporal_container_def])
}

resource "aws_ecs_service" "temporal" {
  depends_on      = [aws_lb.temporal]
  name            = "${local.name}-temporal"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.temporal.arn
  desired_count   = var.temporal_desired_count

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 1
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 0
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  enable_ecs_managed_tags            = true
  network_configuration {
    subnets          = local.application_subnet_ids
    assign_public_ip = false
    security_groups = concat(
      aws_security_group.temporal[*].id,
      [
        module.bigeye_admin.client_security_group_id,
      ],
      var.temporal_extra_security_group_ids
    )
  }

  load_balancer {
    container_name   = "${local.name}-temporal"
    container_port   = 7233
    target_group_arn = aws_lb_target_group.temporal.arn
  }

  platform_version = "1.4.0"

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  propagate_tags = "SERVICE"

  tags = merge(local.tags, { app = "temporal" })
}

resource "aws_security_group" "temporal" {
  count       = var.create_security_groups ? 1 : 0
  name        = "${local.name}-temporal"
  description = "Allows traffic for temporal"
  vpc_id      = local.vpc_id
  tags = merge(local.tags, {
    Name = "${local.name}-temporal"
  })

  ingress {
    from_port   = 0
    to_port     = local.max_port
    protocol    = "TCP"
    description = "Allow traffic from self"
    self        = true
  }

  ingress {
    from_port       = 7233
    to_port         = 7233
    protocol        = "TCP"
    description     = "Allow traffic from anywhere on traffic port"
    security_groups = [aws_security_group.temporal_lb[0].id]
  }

  egress {
    from_port        = 0
    to_port          = local.max_port
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all egress"
  }
}

#======================================================
# Temporal-UI
#======================================================
module "temporalui" {
  source   = "../simpleservice"
  app      = "temporalui"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-temporalui"
  tags     = merge(local.tags, { app = "temporalui" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = concat(var.temporalui_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  traffic_port                  = var.temporalui_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/"
  healthcheck_interval             = 15
  healthcheck_unhealthy_threshold  = 3
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.temporalui_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_deregistration_delay          = 120

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "temporalui")

  # Task settings
  desired_count             = var.temporalui_desired_count
  cpu                       = var.temporalui_cpu
  memory                    = var.temporalui_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "temporalui", var.image_repository_suffix)
  image_tag                 = local.temporalui_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.temporal.name

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn


  environment_variables = merge(
    local.temporalui_dd_env_vars,
    {
      ENVIRONMENT                           = var.environment
      INSTANCE                              = var.instance
      TEMPORAL_ADDRESS                      = "${local.temporal_dns_name}:${local.temporal_lb_port}"
      TEMPORAL_UI_PORT                      = var.temporalui_port
      TEMPORAL_CORS_ORIGINS                 = "https://${local.temporal_dns_name}:${local.temporal_lb_port}"
      TEMPORAL_TLS_ENABLE_HOST_VERIFICATION = var.temporal_use_default_certificates ? "false" : "true"
      TEMPORAL_TLS_SERVER_NAME              = local.temporal_dns_name
    },
    var.temporalui_additional_environment_vars,
  )

  secret_arns = var.temporalui_additional_secret_arns
}

#======================================================
# Monocle
#======================================================
resource "aws_iam_role" "monocle" {
  name = "${local.name}-monocle"
  tags = local.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "monocle" {
  role = aws_iam_role.monocle.id
  name = "AllowAccessModelsBucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = aws_s3_bucket.models.arn
      },
      {
        Sid    = "AllowGetPutObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = format("%s/*", aws_s3_bucket.models.arn)
      }
    ]
  })
}

module "monocle" {
  source   = "../simpleservice"
  app      = "monocle"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-monocle"
  tags     = merge(local.tags, { app = "monocle" })

  vpc_id                 = local.vpc_id
  vpc_cidr_block         = var.vpc_cidr_block
  subnet_ids             = local.application_subnet_ids
  create_security_groups = var.create_security_groups
  additional_security_group_ids = concat(
    var.monocle_extra_security_group_ids,
    [module.bigeye_admin.client_security_group_id],
    var.create_security_groups ? [module.rabbitmq.client_security_group_id] : [],

  )
  traffic_port    = var.monocle_port
  ecs_cluster_id  = aws_ecs_cluster.this.id
  fargate_version = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  healthcheck_interval             = 60
  healthcheck_timeout              = 20
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.monocle_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_deregistration_delay          = 300

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "monocle")

  # Task settings
  desired_count             = var.monocle_desired_count
  cpu                       = var.monocle_cpu
  memory                    = var.monocle_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.monocle.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "monocle", var.image_repository_suffix)
  image_tag                 = local.monocle_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn


  environment_variables = merge(
    {
      ENVIRONMENT                = var.environment
      INSTANCE                   = var.instance
      PORT                       = var.monocle_port
      MQ_BROKER_HOST             = module.rabbitmq.endpoint
      MQ_BROKER_USERNAME         = var.rabbitmq_user_name
      ML_MODELS_S3_BUCKET        = aws_s3_bucket.models.id
      DEPLOY_TYPE                = "AWS"
      QUEUE_CONNECTION_HEARTBEAT = "1000"
      BACKLOG                    = "512"
      WORKERS                    = "2"
      TIMEOUT                    = "900"
      DATAWATCH_ADDRESS          = "https://${local.datawatch_dns_name}"
    },
    local.sentry_event_level_env_variable,
    var.datadog_agent_enabled ? {
      DD_PROFILING_ENABLED     = "true"
      DD_PROFILING_CAPTURE_PCT = "2"
      DD_CALL_BASIC_CONFIG     = "false"
      DD_TRACE_STARTUP_LOGS    = "true"
      DD_TRACE_DEBUG           = "false"
      DD_LOGS_INJECTION        = "true"
    } : {},
    var.monocle_additional_environment_vars,
  )

  secret_arns = merge(
    local.sentry_dsn_secret_map,
    local.stitch_secrets_map,
    {
      MQ_BROKER_PASSWORD = local.rabbitmq_user_password_secret_arn
      ROBOT_PASSWORD     = local.robot_password_secret_arn
    },
    var.datadog_agent_enabled ? {
      DATADOG_API_KEY = var.datadog_agent_api_key_secret_arn
    } : {},
    var.monocle_additional_secret_arns,
  )
}

resource "aws_appautoscaling_target" "monocle" {
  count              = var.monocle_autoscaling_enabled ? 1 : 0
  depends_on         = [module.monocle]
  min_capacity       = var.monocle_desired_count
  max_capacity       = var.monocle_max_count
  resource_id        = format("service/%s/%s-monocle", local.name, local.name)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "monocle" {
  count              = var.monocle_autoscaling_enabled ? 1 : 0
  depends_on         = [aws_appautoscaling_target.monocle]
  name               = format("%s-monocle-autoscaling", local.name)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.monocle[0].resource_id
  scalable_dimension = aws_appautoscaling_target.monocle[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.monocle[0].service_namespace
  target_tracking_scaling_policy_configuration {
    target_value       = var.monocle_autoscaling_request_count_target
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = format("%s/%s", module.monocle.load_balancer_full_name, module.monocle.target_group_full_name)
    }
  }
}

#======================================================
# Toretto
#======================================================
module "toretto" {
  source   = "../simpleservice"
  app      = "toretto"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-toretto"
  tags     = merge(local.tags, { app = "toretto" })

  vpc_id                 = local.vpc_id
  vpc_cidr_block         = var.vpc_cidr_block
  subnet_ids             = local.application_subnet_ids
  create_security_groups = var.create_security_groups
  additional_security_group_ids = concat(
    var.toretto_extra_security_group_ids,
    [module.bigeye_admin.client_security_group_id],
    var.create_security_groups ? [module.rabbitmq.client_security_group_id] : [],
  )
  traffic_port    = var.toretto_port
  ecs_cluster_id  = aws_ecs_cluster.this.id
  fargate_version = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.toretto_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "toretto")

  # Task settings
  desired_count             = var.toretto_desired_count
  cpu                       = var.toretto_cpu
  memory                    = var.toretto_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.monocle.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "toretto", var.image_repository_suffix)
  image_tag                 = local.toretto_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # This can be removed when toretto handles sigterm better 
  stop_timeout = 10

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn


  environment_variables = merge(
    {
      ENVIRONMENT                = var.environment
      INSTANCE                   = var.instance
      MQ_BROKER_HOST             = module.rabbitmq.endpoint
      MQ_BROKER_USERNAME         = var.rabbitmq_user_name
      ML_MODELS_S3_BUCKET        = aws_s3_bucket.models.id
      DEPLOY_TYPE                = "AWS"
      QUEUE_CONNECTION_HEARTBEAT = "1000"
      PORT                       = var.toretto_port
      BACKLOG                    = "512"
      WORKERS                    = "1"
      TIMEOUT                    = "900"
      DATAWATCH_ADDRESS          = "https://${local.datawatch_dns_name}"
    },
    local.sentry_event_level_env_variable,
    var.toretto_additional_environment_vars,
  )

  secret_arns = merge(
    local.sentry_dsn_secret_map,
    local.stitch_secrets_map,
    {
      MQ_BROKER_PASSWORD = local.rabbitmq_user_password_secret_arn
      ROBOT_PASSWORD     = local.robot_password_secret_arn
    },
    var.datadog_agent_enabled ? { DATADOG_API_KEY = var.datadog_agent_api_key_secret_arn } : {},
    var.toretto_additional_secret_arns,
  )
}

resource "aws_appautoscaling_target" "toretto" {
  count              = var.toretto_autoscaling_enabled ? 1 : 0
  depends_on         = [module.toretto]
  min_capacity       = 1
  max_capacity       = 100
  resource_id        = format("service/%s/%s-toretto", local.name, local.name)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

locals {
  toretto_desired_count_step1 = coalesce(var.toretto_desired_count_step1, var.datawatch_desired_count * 2)
  toretto_desired_count_step2 = coalesce(var.toretto_desired_count_step2, var.datawatch_desired_count * 3)
  toretto_desired_count_step3 = coalesce(var.toretto_desired_count_step3, var.datawatch_desired_count * 4)
}

resource "aws_appautoscaling_policy" "toretto" {
  count              = var.toretto_autoscaling_enabled ? 1 : 0
  depends_on         = [aws_appautoscaling_target.toretto]
  name               = format("%s-toretto-autoscaling", local.name)
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.toretto[0].resource_id
  scalable_dimension = aws_appautoscaling_target.toretto[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.toretto[0].service_namespace
  step_scaling_policy_configuration {
    adjustment_type         = "ExactCapacity"
    cooldown                = 600
    metric_aggregation_type = "Average"

    step_adjustment {
      scaling_adjustment          = var.toretto_desired_count
      metric_interval_upper_bound = var.toretto_autoscaling_threshold_step1
    }

    step_adjustment {
      scaling_adjustment          = local.toretto_desired_count_step1
      metric_interval_lower_bound = var.toretto_autoscaling_threshold_step1
      metric_interval_upper_bound = var.toretto_autoscaling_threshold_step2
    }

    step_adjustment {
      scaling_adjustment          = local.toretto_desired_count_step2
      metric_interval_lower_bound = var.toretto_autoscaling_threshold_step2
      metric_interval_upper_bound = var.toretto_autoscaling_threshold_step3
    }

    step_adjustment {
      scaling_adjustment          = local.toretto_desired_count_step3
      metric_interval_lower_bound = var.toretto_autoscaling_threshold_step3
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "toretto" {
  count           = var.toretto_autoscaling_enabled ? 1 : 0
  alarm_name      = format("%s-toretto autoscaling", local.name)
  actions_enabled = true
  alarm_actions   = [aws_appautoscaling_policy.toretto[0].arn]
  metric_name     = "MessageCount"
  namespace       = "AWS/AmazonMQ"
  statistic       = "Average"
  dimensions = {
    Broker      = module.rabbitmq.name
    VirtualHost = "/"
    Queue       = "ml_training_task_queue"
  }
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 0
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"
}

#======================================================
# Scheduler
#======================================================
module "scheduler" {
  source   = "../simpleservice"
  app      = "scheduler"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-scheduler"
  tags     = merge(local.tags, { app = "scheduler" })

  vpc_id                 = local.vpc_id
  vpc_cidr_block         = var.vpc_cidr_block
  subnet_ids             = local.application_subnet_ids
  create_security_groups = var.create_security_groups
  additional_security_group_ids = concat(
    var.scheduler_extra_security_group_ids,
    [module.bigeye_admin.client_security_group_id],
  )
  traffic_port    = var.scheduler_port
  ecs_cluster_id  = aws_ecs_cluster.this.id
  fargate_version = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.scheduler_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "scheduler")

  # Task settings
  desired_count             = var.scheduler_desired_count
  cpu                       = var.scheduler_cpu
  memory                    = var.scheduler_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "scheduler", var.image_repository_suffix)
  image_tag                 = local.scheduler_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn


  environment_variables = merge(
    {
      ENVIRONMENT           = var.environment
      INSTANCE              = var.instance
      PORT                  = var.scheduler_port
      DEPLOY_TYPE           = "AWS"
      DATAWATCH_ADDRESS     = "https://${local.datawork_dns_name}"
      MAX_RAM_PERCENTAGE    = "85"
      SCHEDULER_ADDRESS     = "http://localhost:${var.scheduler_port}"
      SCHEDULER_THREADS     = var.scheduler_threads
      REDIS_PRIMARY_ADDRESS = module.redis.primary_endpoint_dns_name
      REDIS_PRIMARY_PORT    = module.redis.port
    },
    var.scheduler_additional_environment_vars,
  )

  secret_arns = merge(
    {
      REDIS_PRIMARY_PASSWORD = local.redis_auth_token_secret_arn
      ROBOT_PASSWORD         = local.robot_password_secret_arn
    },
    local.sentry_dsn_secret_map,
    var.scheduler_additional_secret_arns,
  )
}

#======================================================
# Datawatch - IAM
#======================================================
resource "aws_iam_role" "datawatch" {
  name = "${local.name}-datawatch"
  tags = local.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_s3" {
  role = aws_iam_role.datawatch.id
  name = "AllowAccessLargePayloadBucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.large_payload.arn
      },
      {
        Sid    = "AllowGetPutObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = format("%s/*", aws_s3_bucket.large_payload.arn)
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_temporalsecrets" {
  role = aws_iam_role.datawatch.id
  name = "AllowTemporalSecretsAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteNewSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:TagResource"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/temporal/client/public/*"
        ]
      },
      {
        Sid    = "AllowReadSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/temporal/client/public/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/temporal/*/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/datawatch-temporal/*"
        ]

      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_listsecrets" {
  role = aws_iam_role.datawatch.id
  name = "AllowListSecrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:ListSecrets"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_secrets" {
  role = aws_iam_role.datawatch.id
  name = "AllowSecretsAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowWriteNewSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:TagResource"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/agent/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/datawatch/*"
        ]
      },
      {
        Sid    = "AllowReadSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/agent/*",
          "arn:aws:secretsmanager:${local.aws_region}:${local.aws_account_id}:secret:bigeye/${local.name}/datawatch/*"
        ]

      }
    ]
  })
}

#======================================================
# Datawatch - Redis
#======================================================
resource "random_password" "redis_auth_token" {
  count   = local.create_redis_auth_token_secret ? 1 : 0
  length  = 16
  special = false
}
resource "aws_secretsmanager_secret" "redis_auth_token" {
  count                   = local.create_redis_auth_token_secret ? 1 : 0
  name                    = format("bigeye/%s/datawatch/redis/authtoken", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  count         = local.create_redis_auth_token_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.redis_auth_token[0].id
  secret_string = random_password.redis_auth_token[0].result
}

data "aws_secretsmanager_secret_version" "byo_redis_auth_token" {
  count     = local.create_redis_auth_token_secret ? 0 : 1
  secret_id = var.redis_auth_token_secret_arn
}

module "redis" {
  depends_on               = [aws_secretsmanager_secret_version.redis_auth_token]
  source                   = "../redis"
  name                     = local.name
  vpc_id                   = local.vpc_id
  create_security_groups   = var.create_security_groups
  subnet_group_name        = local.elasticache_subnet_group_name
  extra_security_group_ids = concat(var.redis_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  allowed_client_security_group_ids = var.create_security_groups ? [
    module.scheduler.security_group_id,
    module.datawatch.security_group_id,
    module.datawork.security_group_id,
    module.metricwork.security_group_id,
  ] : []
  auth_token               = local.create_redis_auth_token_secret ? aws_secretsmanager_secret_version.redis_auth_token[0].secret_string : data.aws_secretsmanager_secret_version.byo_redis_auth_token[0].secret_string
  instance_type            = var.redis_instance_type
  instance_count           = var.redundant_infrastructure ? 2 : 1
  engine_version           = var.redis_engine_version
  maintenance_window       = var.redis_maintenance_window
  cloudwatch_loggroup_name = aws_cloudwatch_log_group.bigeye.name
  tags                     = merge(local.tags, { app = "datawatch" })
}

#======================================================
# Datawatch - RDS
#======================================================
resource "random_password" "datawatch_rds_password" {
  count   = local.create_datawatch_rds_password_secret ? 1 : 0
  length  = 16
  special = false
}
resource "aws_secretsmanager_secret" "datawatch_rds_password" {
  count                   = local.create_datawatch_rds_password_secret ? 1 : 0
  name                    = format("bigeye/%s/datawatch/rds/password", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "datawatch_rds_password" {
  count         = local.create_datawatch_rds_password_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.datawatch_rds_password[0].id
  secret_string = random_password.datawatch_rds_password[0].result
}
data "aws_secretsmanager_secret_version" "byo_datawatch_rds_password" {
  count     = local.create_datawatch_rds_password_secret ? 0 : 1
  secret_id = var.datawatch_rds_root_user_password_secret_arn
}

module "datawatch_rds" {
  depends_on = [aws_secretsmanager_secret_version.datawatch_rds_password]
  source     = "../rds"
  name       = "${local.name}-datawatch"

  # Connection Info
  db_name             = var.datawatch_rds_db_name
  root_user_name      = var.datawatch_rds_root_user_name
  root_user_password  = local.create_datawatch_rds_password_secret ? aws_secretsmanager_secret_version.datawatch_rds_password[0].secret_string : data.aws_secretsmanager_secret_version.byo_datawatch_rds_password[0].secret_string
  snapshot_identifier = var.datawatch_rds_snapshot_identifier

  #Networking
  vpc_id                   = local.vpc_id
  db_subnet_group_name     = local.database_subnet_group_name
  create_security_groups   = var.create_security_groups
  extra_security_group_ids = concat(var.datawatch_rds_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  enable_multi_az          = var.redundant_infrastructure ? true : false

  allowed_client_security_group_ids = var.create_security_groups ? [
    module.datawatch.security_group_id,
    module.datawork.security_group_id,
    module.metricwork.security_group_id,
  ] : []

  # Settings
  instance_class = var.datawatch_rds_instance_type
  engine_version = var.datawatch_rds_engine_version

  # Storage
  allocated_storage     = var.datawatch_rds_allocated_storage
  max_allocated_storage = var.datawatch_rds_max_allocated_storage
  storage_type          = "gp3"

  # Ops
  apply_immediately                     = var.rds_apply_immediately
  deletion_protection                   = var.deletion_protection
  backup_window                         = var.rds_backup_window
  backup_retention_period               = var.datawatch_rds_backup_retention_period
  maintenance_window                    = var.rds_maintenance_window
  enable_performance_insights           = local.datawatch_rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  enhanced_monitoring_interval          = var.datawatch_rds_enhanced_monitoring_interval
  enhanced_monitoring_role_arn          = var.datawatch_rds_enhanced_monitoring_role_arn

  create_option_group    = false
  create_parameter_group = true
  parameter_group_name   = "${local.name}-datawatch"
  parameters             = var.datawatch_rds_parameters

  # Replica
  create_replica                  = var.datawatch_rds_replica_enabled
  replica_instance_class          = var.datawatch_rds_replica_instance_type
  replica_backup_retention_period = var.datawatch_rds_replica_backup_retention_period

  replica_create_parameter_group = true
  replica_parameter_group_name   = "${local.name}-datawatch-replica"
  replica_parameters             = var.datawatch_rds_replica_parameters

  tags                    = merge(local.tags, { app = "datawatch" }, var.datawatch_rds_additional_tags)
  primary_additional_tags = var.datawatch_rds_primary_additional_tags
  replica_additional_tags = var.datawatch_rds_replica_additional_tags
}

#======================================================
# Datawatch - Compute
#======================================================
resource "random_password" "robot_password" {
  count   = local.create_robot_password_secret ? 1 : 0
  length  = 16
  special = false
}
resource "aws_secretsmanager_secret" "robot_password" {
  count                   = local.create_robot_password_secret ? 1 : 0
  name                    = format("bigeye/%s/datawatch/robot-password", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "robot_password" {
  count         = local.create_robot_password_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.robot_password[0].id
  secret_string = random_password.robot_password[0].result
}

locals {
  datawatch_common_env_vars = {
    ENVIRONMENT = var.environment
    INSTANCE    = var.instance
    PORT        = var.datawatch_port

    AGENT_LARGE_PAYLOAD_BUCKET_NAME = aws_s3_bucket.large_payload.id
    AWS_REGION                      = local.aws_region
    DEPLOY_TYPE                     = "AWS"

    MYSQL_JDBC                  = "jdbc:mysql://${local.datawatch_mysql_dns_name}:3306/${local.datawatch_jdbc_database_name}?serverTimezone=UTC"
    MYSQL_USER                  = var.datawatch_rds_root_user_name
    MYSQL_MAXSIZE               = var.datawatch_mysql_maxsize
    MYSQL_TRANSACTION_ISOLATION = "read-committed"

    MONOCLE_ADDRESS   = "https://${local.monocle_dns_name}"
    REDIRECT_ADDRESS  = "https://${local.vanity_dns_name}"
    SCHEDULER_ADDRESS = "https://${local.scheduler_dns_name}"
    TORETTO_ADDRESS   = "https://${local.toretto_dns_name}"

    MQ_BROKER_HOST     = module.rabbitmq.endpoint
    MQ_BROKER_USERNAME = var.rabbitmq_user_name

    REDIS_PRIMARY_ADDRESS = module.redis.primary_endpoint_dns_name
    REDIS_PRIMARY_PORT    = module.redis.port
    REDIS_SSL_ENABLED     = "true"

    ACTIONABLE_NOTIFICATION_ENABLED = "false"
    FF_ANALYTICS_LOGGING_ENABLED    = var.datawatch_feature_analytics_logging_enabled
    FF_QUEUE_BACKFILL_ENABLED       = "true"
    FF_SEND_ANALYTICS_ENABLED       = var.datawatch_feature_analytics_send_enabled
    MAX_RAM_PERCENTAGE              = var.datawatch_jvm_max_ram_pct
    REQUEST_AUTH_LOGGING_ENABLED    = var.datawatch_request_auth_logging_enabled
    REQUEST_BODY_LOGGING_ENABLED    = var.datawatch_request_body_logging_enabled

    AUTH0_DOMAIN            = var.auth0_domain
    EXTERNAL_LOGGING_LEVEL  = var.datawatch_external_logging_level
    SLACK_HAS_DEDICATED_APP = var.datawatch_slack_has_dedicated_app ? "true" : "false"
    STITCH_SCHEMA_NAME      = var.datawatch_stitch_schema_name

    TEMPORAL_ENABLED                           = true
    TEMPORAL_TARGET                            = "${local.temporal_dns_name}:${local.temporal_lb_port}"
    TEMPORAL_NAMESPACE                         = var.temporal_namespace
    TEMPORAL_SSL_HOSTNAME_VERIFICATION_ENABLED = var.temporal_use_default_certificates ? "false" : "true"

    MAILER_HOST         = local.byomailserver_smtp_host
    MAILER_PORT         = local.byomailserver_smtp_port
    MAILER_USER         = local.byomailserver_smtp_user
    MAILER_FROM_ADDRESS = local.byomailserver_smtp_from_address

    MTLS_KEY_PATH  = "/temporal/mtls.key"
    MTLS_CERT_PATH = "/temporal/mtls.pem"
  }
}

module "datawatch" {
  depends_on = [aws_secretsmanager_secret_version.robot_password]
  source     = "../simpleservice"
  app        = "datawatch"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-datawatch"
  tags       = merge(local.tags, { app = "datawatch" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.datawatch_extra_security_group_ids)
  traffic_port                  = var.datawatch_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  healthcheck_grace_period         = 300
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.datawatch_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_deregistration_delay          = 900

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "datawatch")

  # Task settings
  desired_count             = var.datawatch_desired_count
  cpu                       = var.datawatch_cpu
  memory                    = var.datawatch_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.datawatch.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.datawatch_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP             = "datawatch"
      WORKERS_ENABLED = "false"
    },
    var.datawatch_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns
}

module "datawork" {
  depends_on = [aws_secretsmanager_secret_version.robot_password]
  source     = "../simpleservice"
  app        = "datawork"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-datawork"
  tags       = merge(local.tags, { app = "datawork" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.datawork_extra_security_group_ids)
  traffic_port                  = var.datawork_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  healthcheck_interval             = 90
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.datawork_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "datawork")

  # Task settings
  desired_count             = var.datawork_desired_count
  cpu                       = var.datawork_cpu
  memory                    = var.datawork_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.datawatch.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.datawork_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                = "datawork"
      DATAWATCH_ADDRESS  = "http://localhost:${var.datawork_port}"
      WORKERS_ENABLED    = "true"
      METRIC_RUN_WORKERS = "1"
      EXCLUDE_QUEUES     = "trigger-batch-metric-run"
    },
    var.datawork_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns
}

module "metricwork" {
  depends_on = [aws_secretsmanager_secret_version.robot_password]
  source     = "../simpleservice"
  app        = "metricwork"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-metricwork"
  tags       = merge(local.tags, { app = "metricwork" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.metricwork_extra_security_group_ids)
  traffic_port                  = var.metricwork_port
  ecs_cluster_id                = aws_ecs_cluster.this.id

  # Load balancer
  healthcheck_path                 = "/health"
  healthcheck_interval             = 90
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.metricwork_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "metricwork")

  # Task settings
  desired_count             = var.metricwork_desired_count
  cpu                       = var.metricwork_cpu
  memory                    = var.metricwork_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.datawatch.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.metricwork_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                   = "metricwork"
      DATAWATCH_ADDRESS     = "http://localhost:${var.metricwork_port}"
      WORKERS_ENABLED       = "true"
      METRIC_RUN_WORKERS    = "1"
      SINGLE_QUEUE_OVERRIDE = "trigger-batch-metric-run"
    },
    var.metricwork_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns
}

