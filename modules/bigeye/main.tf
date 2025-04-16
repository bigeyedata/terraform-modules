terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.68.0, < 6.0.0"
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
      condition     = var.create_security_groups || length(var.backfillwork_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the backfillwork lb using backfillwork_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.datawork_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the datawork lb using datawork_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.indexwork_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the indexwork lb using indexwork_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.lineagework_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the lineagework lb using lineagework_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.metricwork_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the metricwork lb using metricwork_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.rootcause_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the rootcause lb using rootcause_lb_extra_security_group_ids (ports 80/443)"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.internalapi_lb_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the internalapi lb using internalapi_lb_extra_security_group_ids (ports 80/443)"
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
      condition     = var.create_security_groups || length(var.backfillwork_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the backfillwork ECS tasks using backfillwork_extra_security_group_ids (port ${var.backfillwork_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.datawork_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the datawork ECS tasks using datawork_extra_security_group_ids (port ${var.datawork_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.indexwork_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the indexwork ECS tasks using indexwork_extra_security_group_ids (port ${var.indexwork_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.lineagework_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the lineagework ECS tasks using lineagework_extra_security_group_ids (port ${var.lineagework_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.metricwork_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the metricwork ECS tasks using metricwork_extra_security_group_ids (port ${var.metricwork_port})"
    }

    postcondition {
      condition     = var.create_security_groups || length(var.rootcause_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the rootcause ECS tasks using rootcause_extra_security_group_ids (port ${var.rootcause_port})"
    }


    postcondition {
      condition     = var.create_security_groups || length(var.internalapi_extra_security_group_ids) > 0
      error_message = "If create_security_groups is false, you must provide a security group for the internalapi ECS tasks using internalapi_extra_security_group_ids (port ${var.internalapi_port})"
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
    cidr_blocks = concat([var.vpc_cidr_block], var.internal_additional_ingress_cidrs)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "Allow HTTPS traffic"
    cidr_blocks = concat([var.vpc_cidr_block], var.internal_additional_ingress_cidrs)
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
  count        = var.create_dns_records ? 1 : 0
  name         = "${var.top_level_dns_name}."
  private_zone = var.private_hosted_zone
}

resource "aws_route53_record" "apex" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = local.vanity_dns_name
  type    = "A"
  alias {
    name                   = module.haproxy.lb_dns_name
    zone_id                = module.haproxy.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "static" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = local.static_asset_dns_name
  type    = "A"
  alias {
    name = local.web_static_asset_root
    zone_id = (
      var.cloudfront_enabled && var.cloudfront_route_static_asset_traffic ?
      module.cloudfront[0].cloudfront_distribution_hosted_zone_id : aws_route53_record.apex[0].zone_id
    )
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "datawatch_mysql" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = local.datawatch_mysql_vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.datawatch_rds.primary_dns_name]
}

resource "aws_route53_record" "datawatch_mysql_replica" {
  count   = var.create_dns_records && var.datawatch_rds_replica_enabled ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = local.datawatch_mysql_replica_vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.datawatch_rds.replica_dns_name]
}

resource "aws_route53_record" "temporal" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = local.temporal_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.temporal.dns_name]
}

resource "aws_route53_record" "temporal_mysql" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = data.aws_route53_zone.this[0].zone_id
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
  zone_id         = data.aws_route53_zone.this[0].zone_id
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
  count = local.create_ecs_role ? 1 : 0
  name  = "${local.name}-service-role"
  tags  = local.tags
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
  count = local.create_ecs_role ? 1 : 0
  role  = aws_iam_role.ecs[0].id
  name  = "ECSTaskExecution"
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
        }, {
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
  count = local.create_ecs_role ? 1 : 0
  role  = aws_iam_role.ecs[0].id
  name  = "AllowAccessSecrets"
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

resource "aws_ecs_cluster_capacity_providers" "this" {
  count        = var.lineageplus_enabled ? 1 : 0
  cluster_name = aws_ecs_cluster.this.name
  capacity_providers = [
    module.lineageplus_solr[0].aws_ecs_capacity_provider_name
  ]
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
  execution_role_arn        = local.ecs_role_arn
  task_iam_role_arn         = var.admin_container_ecs_task_role_arn
  fargate_version           = var.fargate_version
  efs_volume_id             = local.efs_volume_enabled && var.enable_bigeye_admin_module ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = local.efs_volume_enabled && var.enable_bigeye_admin_module ? aws_efs_access_point.bigeye_admin[0].id : ""
  efs_mount_point           = var.efs_mount_point

  stack_name = local.name

  haproxy_domain_name      = local.vanity_dns_name
  web_domain_name          = module.web.dns_name
  monocle_domain_name      = module.monocle.dns_name
  toretto_domain_name      = module.toretto.dns_name
  temporal_domain_name     = local.temporal_dns_name
  temporalui_domain_name   = module.temporalui.dns_name
  datawatch_domain_name    = module.datawatch.dns_name
  datawork_domain_name     = module.datawork.dns_name
  backfillwork_domain_name = module.backfillwork.dns_name
  indexwork_domain_name    = module.indexwork.dns_name
  lineagework_domain_name  = module.lineagework.dns_name
  metricwork_domain_name   = module.metricwork.dns_name
  rootcause_domain_name    = module.rootcause.dns_name
  internalapi_domain_name  = module.internalapi.dns_name
  scheduler_domain_name    = module.scheduler.dns_name

  haproxy_resource_name      = "${local.name}-haproxy"
  web_resource_name          = "${local.name}-web"
  monocle_resource_name      = "${local.name}-monocle"
  toretto_resource_name      = "${local.name}-toretto"
  temporal_resource_name     = "${local.name}-temporal"
  temporalui_resource_name   = "${local.name}-temporalui"
  datawatch_resource_name    = "${local.name}-datawatch"
  datawork_resource_name     = "${local.name}-datawork"
  backfillwork_resource_name = "${local.name}-backfillwork"
  indexwork_resource_name    = "${local.name}-indexwork"
  lineagework_resource_name  = "${local.name}-lineagework"
  metricwork_resource_name   = "${local.name}-metricwork"
  rootcause_resource_name    = "${local.name}-rootcause"
  internalapi_resource_name  = "${local.name}-internalapi"
  scheduler_resource_name    = "${local.name}-scheduler"

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

  rabbitmq_endpoint            = local.rabbitmq_endpoint
  rabbitmq_username            = var.rabbitmq_user_name
  rabbitmq_password_secret_arn = local.rabbitmq_user_password_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri
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
  count          = local.create_rabbitmq_user_password_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.rabbitmq_user_password[0].id
  secret_string  = random_password.rabbitmq_user_password[0].result
  version_stages = ["AWSCURRENT"]
}

data "aws_secretsmanager_secret_version" "byo_rabbitmq_user_password" {
  count         = local.create_rabbitmq_user_password_secret ? 0 : 1
  secret_id     = var.rabbitmq_user_password_secret_arn
  version_stage = "AWSCURRENT"
}

module "rabbitmq" {
  count                     = local.create_rabbitmq ? 1 : 0
  depends_on                = [aws_secretsmanager_secret_version.rabbitmq_user_password]
  source                    = "../rabbitmq"
  name                      = local.name
  vpc_id                    = local.vpc_id
  deployment_mode           = local.rabbitmq_cluster_mode_enabled ? "CLUSTER_MULTI_AZ" : "SINGLE_INSTANCE"
  create_security_groups    = var.create_security_groups
  extra_security_groups     = concat(var.rabbitmq_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  extra_ingress_cidr_blocks = concat(var.rabbitmq_extra_ingress_cidr_blocks, var.internal_additional_ingress_cidrs)
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
      days = 45
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
          AWS = local.datawatch_role_arn
        }
      }
    ]
  })
}

#======================================================
# ALBs
#======================================================
resource "aws_security_group" "internal_alb" {
  count       = var.create_security_groups ? 1 : 0
  name        = "${local.name}-internal-lb"
  description = "Allows 80/443 to internal loadbalancer"
  vpc_id      = local.vpc_id
  tags        = local.tags
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_egress" {
  count             = var.create_security_groups ? 1 : 0
  security_group_id = aws_security_group.internal_alb[0].id
  from_port         = 0
  to_port           = local.max_port
  ip_protocol       = "TCP"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_ingress_cidrs_http" {
  for_each          = var.create_security_groups ? toset(local.internal_alb_ingress_cidrs) : []
  security_group_id = aws_security_group.internal_alb[0].id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "TCP"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_ingress_cidrs_https" {
  for_each          = var.create_security_groups ? toset(local.internal_alb_ingress_cidrs) : []
  security_group_id = aws_security_group.internal_alb[0].id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "TCP"
  cidr_ipv4         = each.value
}

resource "aws_lb" "internal_alb" {
  name               = "${local.name}-internal"
  internal           = true
  load_balancer_type = "application"
  subnets            = local.internal_service_alb_subnet_ids
  security_groups    = local.internal_alb_security_group_ids
  idle_timeout       = 60
  tags               = local.tags

  access_logs {
    enabled = var.elb_access_logs_enabled
    bucket  = var.elb_access_logs_bucket
    prefix  = format("%s-%s", local.elb_access_logs_prefix, "internal")
  }
}

resource "aws_lb_listener" "http_internal" {
  load_balancer_arn = aws_lb.internal_alb.arn
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
  tags = merge({ "Name" = "http-internal" }, local.tags)
}

resource "aws_lb_listener" "https_internal" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = local.acm_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "requested servicename not found"
      status_code  = "404"
    }
  }
  tags = merge({ "Name" = "https-internal" }, local.tags)
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
  count          = local.create_adminpages_password_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.adminpages_password[0].id
  secret_string  = random_password.adminpages_password[0].result
  version_stages = ["AWSCURRENT"]
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
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
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
  lb_additional_ingress_cidrs      = var.additional_ingress_cidrs
  lb_stickiness_enabled            = true
  lb_deregistration_delay          = 900

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "haproxy")

  # Task settings
  desired_count             = var.haproxy_desired_count
  cpu                       = var.haproxy_cpu
  memory                    = var.haproxy_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "haproxy", var.image_repository_suffix)
  image_tag                 = local.haproxy_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "haproxy") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "haproxy") ? aws_efs_access_point.this["haproxy"].id : ""
  efs_mount_point           = var.efs_mount_point

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

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    {
      ENVIRONMENT      = var.environment
      INSTANCE         = var.instance
      DW_HOST          = module.datawatch.dns_name
      DW_PORT          = "443"
      SCHEDULER_HOST   = module.scheduler.dns_name
      SCHEDULER_PORT   = "443"
      TORETTO_HOST     = module.toretto.dns_name
      TORETTO_PORT     = "443"
      MONOCLE_HOST     = module.monocle.dns_name
      MONOCLE_PORT     = "443"
      WEB_HOST         = module.web.dns_name
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
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
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
  lb_additional_ingress_cidrs      = var.internal_additional_ingress_cidrs
  lb_stickiness_enabled            = true
  lb_deregistration_delay          = 120

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "web")

  # Task settings
  desired_count             = var.web_desired_count
  cpu                       = var.web_cpu
  memory                    = var.web_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "web", var.image_repository_suffix)
  image_tag                 = local.web_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "web") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "web") ? aws_efs_access_point.this["web"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.web_dd_env_vars,
    {
      ENVIRONMENT       = var.environment
      INSTANCE          = var.instance
      DOCKER_ENV        = var.environment
      APP_ENVIRONMENT   = var.environment
      STATIC_ASSET_ROOT = "https://${var.create_dns_records ? aws_route53_record.static[0].fqdn : local.vanity_dns_name}"
      NODE_ENV          = "production"
      PORT              = var.web_port
      DROPWIZARD_HOST   = "https://${module.datawatch.dns_name}"
      DATAWATCH_ADDRESS = "https://${module.datawatch.dns_name}"
      MAX_NODE_MEM_MB   = "4096"
    },
    var.web_additional_environment_vars,
  )

  secret_arns = merge(
    local.sentry_dsn_secret_map,
    var.web_additional_secret_arns
  )

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-web.${var.top_level_dns_name}"
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
  count          = local.create_temporal_rds_password_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.temporal_rds_password[0].id
  secret_string  = random_password.temporal_rds_password[0].result
  version_stages = ["AWSCURRENT"]
}

data "aws_secretsmanager_secret_version" "byo_temporal_rds_password" {
  count         = local.create_temporal_rds_password_secret ? 0 : 1
  secret_id     = var.temporal_rds_root_user_password_secret_arn
  version_stage = "AWSCURRENT"
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
  iops                                  = var.temporal_rds_iops
  db_subnet_group_name                  = local.database_subnet_group_name
  create_security_groups                = var.create_security_groups
  additional_ingress_cidrs              = var.internal_additional_ingress_cidrs
  extra_security_group_ids              = concat(var.temporal_rds_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  allowed_client_security_group_ids     = var.create_security_groups ? [aws_security_group.temporal[0].id] : []
  instance_class                        = var.temporal_rds_instance_type
  backup_window                         = var.rds_backup_window
  backup_retention_period               = var.temporal_rds_backup_retention_period
  maintenance_window                    = var.rds_maintenance_window
  enable_performance_insights           = local.temporal_rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  enabled_logs                          = var.temporal_rds_enabled_logs
  enable_multi_az                       = var.redundant_infrastructure ? true : false
  option_group_name                     = "${local.name}-temporal"
  options                               = var.temporal_rds_options
  create_parameter_group                = true
  parameter_group_name                  = "${local.name}-temporal"
  parameters                            = merge(var.temporal_rds_default_parameters, var.temporal_rds_parameters)
  tags                                  = merge(local.tags, { app = "temporal" }, var.temporal_rds_additional_tags)
  primary_additional_tags               = var.temporal_rds_primary_additional_tags
  replica_additional_tags               = var.temporal_rds_primary_additional_tags
}

#======================================================
# Monocle
#======================================================
resource "aws_iam_role" "monocle" {
  count = local.create_monocle_role ? 1 : 0
  name  = "${local.name}-monocle"
  tags  = local.tags
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
  count = local.create_monocle_role ? 1 : 0
  role  = aws_iam_role.monocle[0].id
  name  = "AllowAccessModelsBucket"
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

resource "aws_iam_role_policy" "monocle_ecs_exec" {
  count = local.create_monocle_role && (var.monocle_enable_ecs_exec || var.toretto_enable_ecs_exec) ? 1 : 0
  role  = aws_iam_role.monocle[0].id
  name  = "AllowECSExec"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" = "*"
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

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(
    var.monocle_extra_security_group_ids,
    [module.bigeye_admin.client_security_group_id],
    var.create_security_groups && local.create_rabbitmq ? [module.rabbitmq[0].client_security_group_id] : [],

  )
  traffic_port           = var.monocle_port
  ecs_cluster_id         = aws_ecs_cluster.this.id
  fargate_version        = var.fargate_version
  enable_execute_command = var.monocle_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_interval                   = 60
  healthcheck_timeout                    = 20
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.monocle_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs
  lb_deregistration_delay                = 300

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "monocle")

  # Task settings
  control_desired_count     = var.monocle_autoscaling_config.type == "none"
  desired_count             = var.monocle_desired_count
  cpu                       = var.monocle_cpu
  memory                    = var.monocle_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.monocle_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "monocle", var.image_repository_suffix)
  image_tag                 = local.monocle_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "monocle") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "monocle") ? aws_efs_access_point.this["monocle"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    {
      ENVIRONMENT                = var.environment
      INSTANCE                   = var.instance
      PORT                       = var.monocle_port
      MQ_BROKER_HOST             = local.rabbitmq_endpoint
      MQ_BROKER_USERNAME         = var.rabbitmq_user_name
      ML_MODELS_S3_BUCKET        = aws_s3_bucket.models.id
      DEPLOY_TYPE                = "AWS"
      QUEUE_CONNECTION_HEARTBEAT = "1000"
      BACKLOG                    = "512"
      WORKERS                    = "2"
      TIMEOUT                    = "900"
      DATAWATCH_ADDRESS          = "https://${module.internalapi.dns_name}"
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

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-monocle.${var.top_level_dns_name}"
}

resource "aws_appautoscaling_target" "monocle" {
  count              = var.monocle_autoscaling_config.type == "none" ? 0 : 1
  depends_on         = [module.monocle]
  min_capacity       = var.monocle_autoscaling_config.min_capacity
  max_capacity       = var.monocle_autoscaling_config.max_capacity
  resource_id        = format("service/%s/%s-monocle", local.name, local.name)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "monocle_cpu_utilization" {
  count              = var.monocle_autoscaling_config.type == "cpu_utilization" ? 1 : 0
  name               = format("%s-monocle-cpu-utilization", local.name)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.monocle[0].resource_id
  scalable_dimension = aws_appautoscaling_target.monocle[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.monocle[0].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.monocle_autoscaling_config.target_utilization
  }
}

resource "aws_appautoscaling_policy" "monocle_request_count_per_target" {
  count              = var.monocle_autoscaling_config.type == "request_count_per_target" ? 1 : 0
  name               = format("%s-monocle-request-count-per-target", local.name)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.monocle[0].resource_id
  scalable_dimension = aws_appautoscaling_target.monocle[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.monocle[0].service_namespace
  target_tracking_scaling_policy_configuration {
    target_value       = var.monocle_autoscaling_config.target_utilization
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

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(
    var.toretto_extra_security_group_ids,
    [module.bigeye_admin.client_security_group_id],
    var.create_security_groups && local.create_rabbitmq ? [module.rabbitmq[0].client_security_group_id] : [],
  )
  traffic_port           = var.toretto_port
  ecs_cluster_id         = aws_ecs_cluster.this.id
  fargate_version        = var.fargate_version
  enable_execute_command = var.toretto_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.toretto_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "toretto")

  # Task settings
  control_desired_count     = var.toretto_autoscaling_enabled ? false : true
  desired_count             = var.toretto_desired_count
  cpu                       = var.toretto_cpu
  memory                    = var.toretto_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.monocle_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "toretto", var.image_repository_suffix)
  image_tag                 = local.toretto_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "toretto") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "toretto") ? aws_efs_access_point.this["toretto"].id : ""
  efs_mount_point           = var.efs_mount_point

  # This can be removed when toretto handles sigterm better 
  stop_timeout = 10

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    {
      ENVIRONMENT                = var.environment
      INSTANCE                   = var.instance
      MQ_BROKER_HOST             = local.rabbitmq_endpoint
      MQ_BROKER_USERNAME         = var.rabbitmq_user_name
      ML_MODELS_S3_BUCKET        = aws_s3_bucket.models.id
      DEPLOY_TYPE                = "AWS"
      QUEUE_CONNECTION_HEARTBEAT = "1000"
      PORT                       = var.toretto_port
      BACKLOG                    = "512"
      WORKERS                    = "1"
      TIMEOUT                    = "900"
      DATAWATCH_ADDRESS          = "https://${module.internalapi.dns_name}"
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

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-toretto.${var.top_level_dns_name}"
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
  count           = var.toretto_autoscaling_enabled && local.create_rabbitmq ? 1 : 0
  alarm_name      = format("%s-toretto autoscaling", local.name)
  actions_enabled = true
  alarm_actions   = [aws_appautoscaling_policy.toretto[0].arn]
  metric_name     = "MessageCount"
  namespace       = "AWS/AmazonMQ"
  statistic       = "Average"
  dimensions = {
    Broker      = module.rabbitmq[0].name
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

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(
    var.scheduler_extra_security_group_ids,
    [module.bigeye_admin.client_security_group_id],
  )
  traffic_port    = var.scheduler_port
  ecs_cluster_id  = aws_ecs_cluster.this.id
  fargate_version = var.fargate_version

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.scheduler_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "scheduler")

  # Task settings
  desired_count             = var.scheduler_desired_count
  cpu                       = var.scheduler_cpu
  memory                    = var.scheduler_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "scheduler", var.image_repository_suffix)
  image_tag                 = local.scheduler_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "scheduler") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "scheduler") ? aws_efs_access_point.this["scheduler"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    {
      ENVIRONMENT           = var.environment
      INSTANCE              = var.instance
      PORT                  = var.scheduler_port
      DEPLOY_TYPE           = "AWS"
      DATAWATCH_ADDRESS     = "https://${module.internalapi.dns_name}"
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

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-scheduler.${var.top_level_dns_name}"
}

#======================================================
# Datawatch - IAM
#======================================================
resource "aws_iam_role" "datawatch" {
  count = local.create_datawatch_role ? 1 : 0
  name  = "${local.name}-datawatch"
  tags  = local.tags
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
  count = local.create_datawatch_role ? 1 : 0
  role  = aws_iam_role.datawatch[0].id
  name  = "AllowAccessLargePayloadBucket"
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
  count = local.create_datawatch_role ? 1 : 0
  role  = aws_iam_role.datawatch[0].id
  name  = "AllowTemporalSecretsAccess"
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
  count = local.create_datawatch_role ? 1 : 0
  role  = aws_iam_role.datawatch[0].id
  name  = "AllowListSecrets"
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
  count = local.create_datawatch_role ? 1 : 0
  role  = aws_iam_role.datawatch[0].id
  name  = "AllowSecretsAccess"
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

resource "aws_iam_role_policy" "datawatch_ecs_exec" {
  count = local.create_datawatch_role && (var.datawatch_enable_ecs_exec || var.backfillwork_enable_ecs_exec || var.datawork_enable_ecs_exec || var.indexwork_enable_ecs_exec || var.lineagework_enable_ecs_exec || var.metricwork_enable_ecs_exec || var.rootcause_enable_ecs_exec || var.internalapi_enable_ecs_exec) ? 1 : 0
  role  = aws_iam_role.datawatch[0].id
  name  = "AllowECSExec"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_efs" {
  count = local.create_datawatch_role && local.efs_volume_enabled ? 1 : 0
  role  = aws_iam_role.datawatch[0].id
  name  = "AllowEFS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ],
        "Resource" : "arn:aws:elasticfilesystem:${local.aws_region}:${local.aws_account_id}:file-system/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/stack" = local.name
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "datawatch_kms" {
  count = local.create_datawatch_role ? 1 : 0
  role  = aws_iam_role.datawatch[0].id
  name  = "AllowKMS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:DescribeKey",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",

        ],
        "Resource" : local.kms_key_arn
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
  count          = local.create_redis_auth_token_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.redis_auth_token[0].id
  secret_string  = random_password.redis_auth_token[0].result
  version_stages = ["AWSCURRENT"]
}

data "aws_secretsmanager_secret_version" "byo_redis_auth_token" {
  count         = local.create_redis_auth_token_secret ? 0 : 1
  secret_id     = var.redis_auth_token_secret_arn
  version_stage = "AWSCURRENT"
}

module "redis" {
  depends_on               = [aws_secretsmanager_secret_version.redis_auth_token]
  source                   = "../redis"
  name                     = local.name
  vpc_id                   = local.vpc_id
  create_security_groups   = var.create_security_groups
  additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  subnet_group_name        = local.elasticache_subnet_group_name
  extra_security_group_ids = concat(var.redis_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])

  # Be mindful of the order when changing the membership of this var.  It is used in a count since the input is not known
  # plan time, so can't be a for_each, thus changing ordering will cause resource destroy/recreate.
  allowed_client_security_group_ids = var.create_security_groups ? [
    module.scheduler.security_group_id,
    module.datawatch.security_group_id,
    module.datawork.security_group_id,
    module.lineagework.security_group_id,
    module.metricwork.security_group_id,
    module.internalapi.security_group_id,
    module.indexwork.security_group_id,
    module.backfillwork.security_group_id,
    module.rootcause.security_group_id,
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
  count          = local.create_datawatch_rds_password_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.datawatch_rds_password[0].id
  secret_string  = random_password.datawatch_rds_password[0].result
  version_stages = ["AWSCURRENT"]
}
data "aws_secretsmanager_secret_version" "byo_datawatch_rds_password" {
  count         = local.create_datawatch_rds_password_secret ? 0 : 1
  secret_id     = var.datawatch_rds_root_user_password_secret_arn
  version_stage = "AWSCURRENT"
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
  additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  extra_security_group_ids = concat(var.datawatch_rds_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  enable_multi_az          = var.redundant_infrastructure ? true : false

  # Be mindful of the order when changing the membership of this var.  It is used in a count since the input is not known
  # plan time, so can't be a for_each, thus changing ordering will cause resource destroy/recreate.
  allowed_client_security_group_ids = var.create_security_groups ? [
    module.datawatch.security_group_id,
    module.datawork.security_group_id,
    module.lineagework.security_group_id,
    module.metricwork.security_group_id,
    module.internalapi.security_group_id,
    module.indexwork.security_group_id,
    module.backfillwork.security_group_id,
    module.rootcause.security_group_id,
  ] : []

  # Settings
  instance_class = var.datawatch_rds_instance_type
  engine_version = var.datawatch_rds_engine_version

  # Storage
  allocated_storage     = var.datawatch_rds_allocated_storage
  max_allocated_storage = var.datawatch_rds_max_allocated_storage
  storage_type          = "gp3"
  iops                  = var.datawatch_rds_iops

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
  enabled_logs                          = var.datawatch_rds_enabled_logs

  option_group_name      = "${local.name}-datawatch"
  options                = var.datawatch_rds_options
  create_parameter_group = true
  parameter_group_name   = "${local.name}-datawatch"
  parameters             = merge(var.datawatch_rds_default_parameters, var.datawatch_rds_parameters)

  # Replica
  create_replica                                = var.datawatch_rds_replica_enabled
  replica_engine_version                        = var.datawatch_rds_replica_engine_version
  replica_instance_class                        = var.datawatch_rds_replica_instance_type
  replica_backup_retention_period               = var.datawatch_rds_replica_backup_retention_period
  replica_enable_performance_insights           = local.datawatch_rds_replica_performance_insights_enabled
  replica_performance_insights_retention_period = var.replica_rds_performance_insights_retention_period
  replica_iops                                  = var.datawatch_rds_replica_iops

  replica_option_group_name      = "${local.name}-datawatch-replica"
  replica_options                = var.datawatch_replica_rds_options
  replica_create_parameter_group = true
  replica_parameter_group_name   = "${local.name}-datawatch-replica"
  replica_parameters             = merge(var.datawatch_rds_replica_default_parameters, var.datawatch_rds_replica_parameters)

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
  count          = local.create_robot_password_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.robot_password[0].id
  secret_string  = random_password.robot_password[0].result
  version_stages = ["AWSCURRENT"]
}

resource "random_password" "robot_agent_api_key" {
  count   = local.create_robot_agent_apikey_secret ? 1 : 0
  length  = 40
  special = false
}
resource "aws_secretsmanager_secret" "robot_agent_api_key" {
  count                   = local.create_robot_agent_apikey_secret ? 1 : 0
  name                    = format("bigeye/%s/datawatch/robot-agent-api-key", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "robot_agent_api_key" {
  count          = local.create_robot_agent_apikey_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.robot_agent_api_key[0].id
  secret_string  = "bigeye_agent_${random_password.robot_agent_api_key[0].result}"
  version_stages = ["AWSCURRENT"]
}

resource "random_password" "base_encryption" {
  count   = local.create_base_dw_encryption_secret ? 1 : 0
  length  = 32
  special = false
}
resource "aws_secretsmanager_secret" "base_encryption" {
  count                   = local.create_base_dw_encryption_secret ? 1 : 0
  name                    = format("bigeye/%s/datawatch/base-encryption", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "base_encryption" {
  count          = local.create_base_dw_encryption_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.base_encryption[0].id
  secret_string  = random_password.base_encryption[0].result
  version_stages = ["AWSCURRENT"]
}

resource "random_password" "base_salt" {
  count   = local.create_base_dw_salt_secret ? 1 : 0
  length  = 32
  special = false
}
resource "aws_secretsmanager_secret" "base_salt" {
  count                   = local.create_base_dw_salt_secret ? 1 : 0
  name                    = format("bigeye/%s/datawatch/base-salt", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}
resource "aws_secretsmanager_secret_version" "base_salt" {
  count          = local.create_base_dw_salt_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.base_salt[0].id
  secret_string  = random_password.base_salt[0].result
  version_stages = ["AWSCURRENT"]
}
resource "aws_kms_alias" "encryption_key_alias" {
  count         = local.create_kms_key ? 1 : 0
  name          = format("alias/bigeye/%s/datawatch", local.name)
  target_key_id = aws_kms_key.datawatch[0].key_id
}

data "aws_kms_key" "datawatch" {
  count  = local.create_kms_key ? 0 : 1
  key_id = var.datawatch_kms_key_arn
}

resource "aws_kms_key" "datawatch" {
  count                   = local.create_kms_key ? 1 : 0
  description             = "KMS key that we use to encrypt/decrypt secrets. This will be used for securely storing sensitive information such as connection info. One will be created if not provided."
  enable_key_rotation     = true
  rotation_period_in_days = var.datawatch_kms_key_rotation_days
  tags                    = merge(local.tags, { app = "datawatch" })
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

    MONOCLE_ADDRESS   = "https://${module.monocle.dns_name}"
    REDIRECT_ADDRESS  = "https://${local.vanity_dns_name}"
    SCHEDULER_ADDRESS = "https://${module.scheduler.dns_name}"
    TORETTO_ADDRESS   = "https://${module.toretto.dns_name}"

    MQ_BROKER_HOST     = local.rabbitmq_endpoint
    MQ_BROKER_USERNAME = var.rabbitmq_user_name

    REDIS_PRIMARY_ADDRESS = module.redis.primary_endpoint_dns_name
    REDIS_PRIMARY_PORT    = module.redis.port
    REDIS_SSL_ENABLED     = "true"

    ACTIONABLE_NOTIFICATION_ENABLED = "false"
    FF_ANALYTICS_LOGGING_ENABLED    = var.datawatch_feature_analytics_logging_enabled
    FF_QUEUE_BACKFILL_ENABLED       = "true"
    FF_SEND_ANALYTICS_ENABLED       = var.datawatch_feature_analytics_send_enabled
    REQUEST_AUTH_LOGGING_ENABLED    = var.datawatch_request_auth_logging_enabled
    REQUEST_BODY_LOGGING_ENABLED    = true
    CLASS_LOADING_LOGGING_ENABLED   = var.datawatch_class_loading_logging_enabled
    MAX_REQUEST_SIZE                = var.datawatch_max_request_size

    AUTH0_DOMAIN            = var.auth0_domain
    EXTERNAL_LOGGING_LEVEL  = var.datawatch_external_logging_level
    SLACK_HAS_DEDICATED_APP = var.datawatch_slack_has_dedicated_app ? "true" : "false"
    STITCH_SCHEMA_NAME      = var.datawatch_stitch_schema_name

    TEMPORAL_ENABLED                           = true
    TEMPORAL_TARGET                            = "${local.temporal_dns_name}:${local.temporal_lb_port}"
    TEMPORAL_NAMESPACE                         = var.temporal_namespace
    TEMPORAL_SSL_HOSTNAME_VERIFICATION_ENABLED = var.temporal_use_default_certificates ? "false" : "true"
    TEMPORAL_LARGE_PAYLOAD_ENABLED             = var.datawatch_temporal_large_payload_enabled

    MAILER_HOST         = local.byomailserver_smtp_host
    MAILER_PORT         = local.byomailserver_smtp_port
    MAILER_USER         = local.byomailserver_smtp_user
    MAILER_FROM_ADDRESS = local.byomailserver_smtp_from_address

    USE_KMS    = local.using_kms
    KMS_KEY_ID = local.using_kms ? local.kms_key_id : ""
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
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.datawatch_extra_security_group_ids)
  traffic_port                  = var.datawatch_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version
  enable_execute_command        = var.datawatch_enable_ecs_exec

  # Load balancer
  healthcheck_path                 = "/health"
  healthcheck_grace_period         = 300
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.datawatch_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs      = var.internal_additional_ingress_cidrs
  lb_deregistration_delay          = 900

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "datawatch")

  # Task settings
  desired_count             = var.datawatch_desired_count
  cpu                       = var.datawatch_cpu
  memory                    = var.datawatch_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.datawatch_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "datawatch") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "datawatch") ? aws_efs_access_point.this["datawatch"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                = "datawatch"
      WORKERS_ENABLED    = "false"
      MAX_RAM_PERCENTAGE = var.datawatch_jvm_max_ram_pct
      HEAP_DUMP_PATH     = contains(var.efs_volume_enabled_services, "datawatch") ? var.efs_mount_point : ""
    },
    var.datawatch_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-datawatch.${var.top_level_dns_name}"
}

module "datawork" {
  depends_on = [aws_secretsmanager_secret_version.robot_password, aws_secretsmanager_secret_version.robot_agent_api_key]
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
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.datawork_extra_security_group_ids)
  traffic_port                  = var.datawork_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version
  enable_execute_command        = var.datawork_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_interval                   = 90
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.datawork_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "datawork")

  # Task settings
  desired_count             = var.datawork_desired_count
  cpu                       = var.datawork_cpu
  memory                    = var.datawork_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.datawork_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120
  efs_volume_id             = contains(var.efs_volume_enabled_services, "datawork") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "datawork") ? aws_efs_access_point.this["datawork"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                                = "datawork"
      DATAWATCH_ADDRESS                  = "http://localhost:${var.datawork_port}"
      WORKERS_ENABLED                    = "true"
      MAX_RAM_PERCENTAGE                 = var.datawork_jvm_max_ram_pct
      METRIC_RUN_WORKERS                 = "0"
      EXCLUDE_QUEUES                     = local.datawork_temporal_exclude_queues_str
      MQ_EXCLUDE_QUEUES                  = local.datawork_mq_exclude_queues
      HEAP_DUMP_PATH                     = contains(var.efs_volume_enabled_services, "datawork") ? var.efs_mount_point : ""
      AGENT_HEARTBEAT_WF_EXEC_SIZE       = var.temporal_client_agent_heartbeat_wf_exec_size
      AGENT_HEARTBEAT_ACT_EXEC_SIZE      = var.temporal_client_agent_heartbeat_act_exec_size
      COLLECT_LINEAGE_WF_EXEC_SIZE       = var.temporal_client_collect_lineage_wf_exec_size
      COLLECT_LINEAGE_ACT_EXEC_SIZE      = var.temporal_client_collect_lineage_act_exec_size
      RUN_METRICS_WF_EXEC_SIZE           = var.temporal_client_run_metrics_wf_exec_size
      RUN_METRICS_ACT_EXEC_SIZE          = var.temporal_client_run_metrics_act_exec_size
      DELETE_SOURCE_WF_EXEC_SIZE         = var.temporal_client_delete_source_wf_exec_size
      DELETE_SOURCE_ACT_EXEC_SIZE        = var.temporal_client_delete_source_act_exec_size
      EXTERNAL_TICKET_WF_EXEC_SIZE       = var.temporal_client_external_ticket_wf_exec_size
      EXTERNAL_TICKET_ACT_EXEC_SIZE      = var.temporal_client_external_ticket_act_exec_size
      GET_SAMPLES_WF_EXEC_SIZE           = var.temporal_client_get_samples_wf_exec_size
      GET_SAMPLES_ACT_EXEC_SIZE          = var.temporal_client_get_samples_act_exec_size
      ISSUE_AI_OVERVIEW_WF_EXEC_SIZE     = var.temporal_client_issue_ai_overview_wf_exec_size
      ISSUE_AI_OVERVIEW_ACT_EXEC_SIZE    = var.temporal_client_issue_ai_overview_act_exec_size
      ISSUE_NOTIFY_WF_EXEC_SIZE          = var.temporal_client_issue_notify_wf_exec_size
      ISSUE_NOTIFY_ACT_EXEC_SIZE         = var.temporal_client_issue_notify_act_exec_size
      ISSUE_UPDATE_WF_EXEC_SIZE          = var.temporal_client_issue_update_wf_exec_size
      ISSUE_UPDATE_ACT_EXEC_SIZE         = var.temporal_client_issue_update_act_exec_size
      RECONCILIATION_WF_EXEC_SIZE        = var.temporal_client_reconciliation_wf_exec_size
      RECONCILIATION_ACT_EXEC_SIZE       = var.temporal_client_reconciliation_act_exec_size
      REFRESH_SCORECARDS_WF_EXEC_SIZE    = var.temporal_client_refresh_scorecard_wf_exec_size
      REFRESH_SCORECARDS_ACT_EXEC_SIZE   = var.temporal_client_refresh_scorecard_act_exec_size
      MONOCLE_INVALIDATION_WF_EXEC_SIZE  = var.temporal_client_monocle_invalidation_wf_exec_size
      MONOCLE_INVALIDATION_ACT_EXEC_SIZE = var.temporal_client_monocle_invalidation_act_exec_size
    },
    var.datawork_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-datawork.${var.top_level_dns_name}"
}

module "backfillwork" {
  depends_on = [aws_secretsmanager_secret_version.robot_password, aws_secretsmanager_secret_version.robot_agent_api_key]
  source     = "../simpleservice"
  app        = "backfillwork"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-backfillwork"
  tags       = merge(local.tags, { app = "backfillwork" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.backfillwork_extra_security_group_ids)
  traffic_port                  = var.backfillwork_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version
  enable_execute_command        = var.backfillwork_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_interval                   = 90
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.backfillwork_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "backfillwork")

  # Task settings
  desired_count             = var.backfillwork_desired_count
  cpu                       = var.backfillwork_cpu
  memory                    = var.backfillwork_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.backfillwork_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120
  efs_volume_id             = contains(var.efs_volume_enabled_services, "backfillwork") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "backfillwork") ? aws_efs_access_point.this["backfillwork"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                      = "backfillwork"
      DATAWATCH_ADDRESS        = "http://localhost:${var.backfillwork_port}"
      WORKERS_ENABLED          = "true"
      MAX_RAM_PERCENTAGE       = var.backfillwork_jvm_max_ram_pct
      METRIC_RUN_WORKERS       = "0"
      MQ_INCLUDE_QUEUES        = local.backfillwork_mq_include_queues_str
      HEAP_DUMP_PATH           = contains(var.efs_volume_enabled_services, "backfillwork") ? var.efs_mount_point : ""
      TEMPORAL_WORKERS_ENABLED = "false"
    },
    var.backfillwork_additional_environment_vars,
  )
  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-backfillwork.${var.top_level_dns_name}"
}

module "indexwork" {
  depends_on = [aws_secretsmanager_secret_version.robot_password, aws_secretsmanager_secret_version.robot_agent_api_key]
  source     = "../simpleservice"
  app        = "indexwork"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-indexwork"
  tags       = merge(local.tags, { app = "indexwork" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.indexwork_extra_security_group_ids)
  traffic_port                  = var.indexwork_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version
  enable_execute_command        = var.indexwork_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_interval                   = 90
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.indexwork_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "indexwork")

  # Task settings
  desired_count             = var.indexwork_desired_count
  cpu                       = var.indexwork_cpu
  memory                    = var.indexwork_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.indexwork_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120
  efs_volume_id             = contains(var.efs_volume_enabled_services, "indexwork") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "indexwork") ? aws_efs_access_point.this["indexwork"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                    = "indexwork"
      DATAWATCH_ADDRESS      = "http://localhost:${var.indexwork_port}"
      WORKERS_ENABLED        = "true"
      MAX_RAM_PERCENTAGE     = var.indexwork_jvm_max_ram_pct
      METRIC_RUN_WORKERS     = "0"
      INCLUDE_QUEUES         = local.indexwork_temporal_include_queues_str
      MQ_INCLUDE_QUEUES      = local.indexwork_mq_include_queues_str
      HEAP_DUMP_PATH         = contains(var.efs_volume_enabled_services, "indexwork") ? var.efs_mount_point : ""
      INDEXING_WF_EXEC_SIZE  = var.temporal_client_indexing_wf_exec_size
      INDEXING_ACT_EXEC_SIZE = var.temporal_client_indexing_act_exec_size
    },
    var.indexwork_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-indexwork.${var.top_level_dns_name}"
}

module "lineagework" {
  depends_on = [aws_secretsmanager_secret_version.robot_password, aws_secretsmanager_secret_version.robot_agent_api_key]
  source     = "../simpleservice"
  app        = "lineagework"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-lineagework"
  tags       = merge(local.tags, { app = "lineagework" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.lineagework_extra_security_group_ids)
  traffic_port                  = var.lineagework_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  enable_execute_command        = var.lineagework_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_interval                   = 90
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.lineagework_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "lineagework")

  # Task settings
  desired_count             = var.lineagework_desired_count
  cpu                       = var.lineagework_cpu
  memory                    = var.lineagework_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.lineagework_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120
  efs_volume_id             = contains(var.efs_volume_enabled_services, "lineagework") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "lineagework") ? aws_efs_access_point.this["lineagework"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                          = "lineagework"
      DATAWATCH_ADDRESS            = "http://localhost:${var.lineagework_port}"
      WORKERS_ENABLED              = "true"
      MAX_RAM_PERCENTAGE           = var.lineagework_jvm_max_ram_pct
      METRIC_RUN_WORKERS           = "0"
      INCLUDE_QUEUES               = local.lineagework_temporal_include_queues_str
      MQ_WORKERS_ENABLED           = "true"
      MQ_INCLUDE_QUEUES            = local.lineagework_mq_include_queues_str
      HEAP_DUMP_PATH               = contains(var.efs_volume_enabled_services, "lineagework") ? var.efs_mount_point : ""
      SOURCE_LINEAGE_WF_EXEC_SIZE  = var.temporal_client_source_lineage_wf_exec_size
      SOURCE_LINEAGE_ACT_EXEC_SIZE = var.temporal_client_source_lineage_act_exec_size
      MC_LINEAGE_WF_EXEC_SIZE      = var.temporal_client_mc_lineage_wf_exec_size
      MC_LINEAGE_ACT_EXEC_SIZE     = var.temporal_client_mc_lineage_act_exec_size
    },
    var.lineagework_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-lineagework.${var.top_level_dns_name}"
}

module "metricwork" {
  depends_on = [aws_secretsmanager_secret_version.robot_password, aws_secretsmanager_secret_version.robot_agent_api_key]
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
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.metricwork_extra_security_group_ids)
  traffic_port                  = var.metricwork_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  enable_execute_command        = var.metricwork_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_interval                   = 90
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.metricwork_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "metricwork")

  # Task settings
  desired_count             = var.metricwork_desired_count
  cpu                       = var.metricwork_cpu
  memory                    = var.metricwork_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.metricwork_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120
  efs_volume_id             = contains(var.efs_volume_enabled_services, "metricwork") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "metricwork") ? aws_efs_access_point.this["metricwork"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                                    = "metricwork"
      DATAWATCH_ADDRESS                      = "http://localhost:${var.metricwork_port}"
      WORKERS_ENABLED                        = "true"
      MAX_RAM_PERCENTAGE                     = var.metricwork_jvm_max_ram_pct
      METRIC_RUN_WORKERS                     = "1"
      INCLUDE_QUEUES                         = local.metricwork_temporal_include_queues_str
      MQ_INCLUDE_QUEUES                      = local.metricwork_mq_include_queues_str
      HEAP_DUMP_PATH                         = contains(var.efs_volume_enabled_services, "metricwork") ? var.efs_mount_point : ""
      TRIGGER_BATCH_METRIC_RUN_WF_EXEC_SIZE  = var.temporal_client_trigger_batch_metric_run_wf_exec_size
      TRIGGER_BATCH_METRIC_RUN_ACT_EXEC_SIZE = var.temporal_client_trigger_batch_metric_run_act_exec_size
    },
    var.metricwork_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-metricwork.${var.top_level_dns_name}"
}

module "rootcause" {
  depends_on = [aws_secretsmanager_secret_version.robot_password, aws_secretsmanager_secret_version.robot_agent_api_key]
  source     = "../simpleservice"
  app        = "rootcause"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-rootcause"
  tags       = merge(local.tags, { app = "rootcause" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.rootcause_extra_security_group_ids)
  traffic_port                  = var.rootcause_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  enable_execute_command        = var.rootcause_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_interval                   = 90
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  # revisit this after we observe the runtime, it likely can be much shorter (~5minute) since temporal respects sigterm and max runtime on API calls
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = concat(var.rootcause_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs      = var.internal_additional_ingress_cidrs

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "rootcause")

  # Task settings
  desired_count             = var.rootcause_desired_count
  cpu                       = var.rootcause_cpu
  memory                    = var.rootcause_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.rootcause_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  stop_timeout              = 120
  efs_volume_id             = contains(var.efs_volume_enabled_services, "rootcause") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "rootcause") ? aws_efs_access_point.this["rootcause"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                            = "rootcause"
      DATAWATCH_ADDRESS              = "http://localhost:${var.rootcause_port}"
      WORKERS_ENABLED                = "true"
      MAX_RAM_PERCENTAGE             = var.rootcause_jvm_max_ram_pct
      METRIC_RUN_WORKERS             = "0"
      INCLUDE_QUEUES                 = local.rootcause_temporal_include_queues_str
      MQ_WORKERS_ENABLED             = "false"
      HEAP_DUMP_PATH                 = contains(var.efs_volume_enabled_services, "rootcause") ? var.efs_mount_point : ""
      ISSUE_ROOT_CAUSE_WF_EXEC_SIZE  = var.temporal_client_issue_root_cause_wf_exec_size
      ISSUE_ROOT_CAUSE_ACT_EXEC_SIZE = var.temporal_client_issue_root_cause_act_exec_size
    },
    var.rootcause_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-rootcause.${var.top_level_dns_name}"
}

module "internalapi" {
  depends_on = [aws_secretsmanager_secret_version.robot_password, aws_secretsmanager_secret_version.robot_agent_api_key]
  source     = "../simpleservice"
  app        = "internalapi"
  instance   = var.instance
  stack      = local.name
  name       = "${local.name}-internalapi"
  tags       = merge(local.tags, { app = "internalapi" })

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(local.datawatch_additional_security_groups, var.internalapi_extra_security_group_ids)
  traffic_port                  = var.internalapi_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version
  enable_execute_command        = var.internalapi_enable_ecs_exec

  # Load balancer
  create_lb                              = var.install_individual_internal_lbs
  use_centralized_lb                     = var.use_centralized_internal_lb
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/health"
  healthcheck_grace_period               = 300
  ssl_policy                             = var.alb_ssl_policy
  acm_certificate_arn                    = local.acm_certificate_arn
  lb_idle_timeout                        = 900
  lb_subnet_ids                          = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids       = concat(var.internalapi_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  lb_additional_ingress_cidrs            = var.internal_additional_ingress_cidrs
  lb_deregistration_delay                = 180

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = format("%s-%s", local.elb_access_logs_prefix, "internalapi")

  # Task settings
  control_desired_count     = var.internalapi_autoscaling_config.type == "none"
  desired_count             = var.internalapi_desired_count
  cpu                       = var.internalapi_cpu
  memory                    = var.internalapi_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = local.datawatch_role_arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = local.internalapi_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "internalapi") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "internalapi") ? aws_efs_access_point.this["internalapi"].id : ""
  efs_mount_point           = var.efs_mount_point

  # Datadog
  datadog_agent_enabled            = var.datadog_agent_enabled
  datadog_agent_image              = var.datadog_agent_image
  datadog_agent_cpu                = var.datadog_agent_cpu
  datadog_agent_memory             = var.datadog_agent_memory
  datadog_agent_api_key_secret_arn = var.datadog_agent_api_key_secret_arn

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    local.datawatch_common_env_vars,
    {
      APP                = "internalapi"
      WORKERS_ENABLED    = "false"
      MAX_RAM_PERCENTAGE = var.internalapi_jvm_max_ram_pct

      HEAP_DUMP_PATH = contains(var.efs_volume_enabled_services, "internalapi") ? var.efs_mount_point : ""
    },
    var.internalapi_additional_environment_vars,
  )

  secret_arns = local.datawatch_secret_arns

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-internalapi.${var.top_level_dns_name}"
}

resource "aws_appautoscaling_target" "internalapi" {
  count              = var.internalapi_autoscaling_config.type == "none" ? 0 : 1
  depends_on         = [module.internalapi]
  min_capacity       = var.internalapi_autoscaling_config.min_capacity
  max_capacity       = var.internalapi_autoscaling_config.max_capacity
  resource_id        = format("service/%s/%s-internalapi", local.name, local.name)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "internalapi_cpu_utilization" {
  count              = var.internalapi_autoscaling_config.type == "cpu_utilization" ? 1 : 0
  depends_on         = [aws_appautoscaling_target.internalapi]
  name               = format("%s-internalapi-cpu-utilization", local.name)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.internalapi[0].resource_id
  scalable_dimension = aws_appautoscaling_target.internalapi[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.internalapi[0].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.internalapi_autoscaling_config.target_utilization
  }
}

resource "aws_appautoscaling_policy" "internalapi_request_count_per_target" {
  count              = var.internalapi_autoscaling_config.type == "request_count_per_target" ? 1 : 0
  depends_on         = [aws_appautoscaling_target.internalapi]
  name               = format("%s-internalapi-request-count-per-target", local.name)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.internalapi[0].resource_id
  scalable_dimension = aws_appautoscaling_target.internalapi[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.internalapi[0].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = format("%s/%s", module.internalapi.load_balancer_full_name, module.internalapi.target_group_full_name)
    }
    target_value = var.internalapi_autoscaling_config.target_utilization
  }
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "${local.name}.internal"
  vpc  = local.vpc_id
}

