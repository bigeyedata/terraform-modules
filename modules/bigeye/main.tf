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
    Duty   = "dmz"
    Public = "true"
  })

  # Internal subnets
  intra_subnets = [
    "${local.vpc_cidr_prefix}.2.0/24",
    "${local.vpc_cidr_prefix}.4.0/24",
    "${local.vpc_cidr_prefix}.6.0/24",
  ]
  intra_subnet_suffix = "internal-dmz"
  intra_subnet_tags = merge(local.tags, {
    Duty   = "internaldmz"
    Public = "false"
  })

  # Private subnets
  private_subnets = [
    "${local.vpc_cidr_prefix}.64.0/18",
    "${local.vpc_cidr_prefix}.128.0/18",
    "${local.vpc_cidr_prefix}.192.0/18",
  ]
  private_subnet_suffix = "general"
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
    ecr_dkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      subnet_ids          = local.application_subnet_ids
      private_dns_enabled = true
      tags = merge(local.tags, {
        Name = "${local.name}-ecrdkr-endpoint"
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
  name    = local.datawatch_mysql_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.datawatch_rds.primary_dns_name]
}

resource "aws_route53_record" "datawatch_mysql_replica" {
  count   = var.create_dns_records && var.datawatch_rds_replica_enabled ? 1 : 0
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.datawatch_mysql_replica_dns_name
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
  name    = local.temporal_admin_dns_name
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
  name    = local.temporal_mysql_dns_name
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

data "aws_iam_policy" "ecs_managed" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = data.aws_iam_policy.ecs_managed.arn
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

module "rabbitmq" {
  source                   = "../rabbitmq"
  name                     = local.name
  vpc_id                   = local.vpc_id
  deployment_mode          = var.redundant_infrastructure ? "CLUSTER_MULTI_AZ" : "SINGLE_INSTANCE"
  create_security_groups   = var.create_security_groups
  extra_security_groups    = var.rabbitmq_extra_security_group_ids
  subnet_ids               = local.rabbitmq_subnet_group_ids
  instance_type            = var.rabbitmq_instance_type
  engine_version           = var.rabbitmq_engine_version
  maintenance_day          = var.rabbitmq_maintenance_day
  maintenance_time         = var.rabbitmq_maintenance_time
  user_name                = var.rabbitmq_user_name
  user_password_secret_arn = local.rabbitmq_user_password_secret_arn
  tags                     = local.tags
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
  bucket = "${local.name}-models-${random_string.models_bucket_suffix.result}"
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
  source   = "../simpleservice"
  app      = "haproxy"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-haproxy"
  tags     = merge(local.tags, { app = "haproxy" })

  internet_facing               = var.internet_facing
  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = var.haproxy_extra_security_group_ids
  traffic_port                  = var.haproxy_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/haproxy-health"
  healthcheck_interval             = 15
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = var.internet_facing ? local.public_alb_subnet_ids : local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = var.haproxy_lb_extra_security_group_ids
  lb_stickiness_enabled            = true
  lb_deregistration_delay          = 900

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/haproxy"

  # Task settings
  desired_count             = var.haproxy_desired_count
  cpu                       = var.haproxy_cpu
  memory                    = var.haproxy_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "haproxy", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key


  environment_variables = merge(var.haproxy_additional_environment_vars, {
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
  })

  secret_arns = merge(var.haproxy_additional_secret_arns, {
    BIGEYE_ADMIN_PAGES_PASSWORD = local.adminpages_password_secret_arn
  })
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
  additional_security_group_ids = var.web_extra_security_group_ids
  traffic_port                  = var.web_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/next-status"
  healthcheck_interval             = 15
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 180
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = var.web_lb_extra_security_group_ids
  lb_stickiness_enabled            = true
  lb_deregistration_delay          = 120

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/web"

  # Task settings
  desired_count             = var.web_desired_count
  cpu                       = var.web_cpu
  memory                    = var.web_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "web", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key


  environment_variables = merge(
    local.web_dd_env_vars,
    var.web_additional_environment_vars,
    {
      ENVIRONMENT       = var.environment
      INSTANCE          = var.instance
      DOCKER_ENV        = "test"
      APP_ENVIRONMENT   = "test"
      NODE_ENV          = "production"
      PORT              = var.web_port
      INTERCOM_APP_ID   = "TODO"
      HEAP_API_KEY      = "TODO"
      DROPWIZARD_HOST   = "https://${local.datawatch_dns_name}"
      DATAWATCH_ADDRESS = "https://${local.datawatch_dns_name}"
      MAX_NODE_MEM_MB   = "4096"
    }
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

module "temporal_rds" {
  source                                = "../rds"
  name                                  = "${local.name}-temporal"
  db_name                               = "temporal"
  root_user_name                        = "bigeye"
  root_user_password_secret_arn         = local.temporal_rds_password_secret_arn
  deletion_protection                   = var.deletion_protection
  snapshot_identifier                   = var.temporal_rds_snapshot_identifier
  vpc_id                                = local.vpc_id
  engine_version                        = var.temporal_rds_engine_version
  allocated_storage                     = var.temporal_rds_allocated_storage
  max_allocated_storage                 = var.temporal_rds_max_allocated_storage
  storage_type                          = "gp3"
  db_subnet_group_name                  = local.database_subnet_group_name
  create_security_groups                = var.create_security_groups
  extra_security_group_ids              = var.temporal_rds_extra_security_group_ids
  instance_class                        = var.temporal_rds_instance_type
  backup_window                         = var.rds_backup_window
  backup_retention_period               = var.temporal_rds_backup_retention_period
  maintenance_window                    = var.rds_maintenance_window
  enable_performance_insights           = var.temporal_rds_enable_performance_insights
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  enable_multi_az                       = var.redundant_infrastructure ? true : false
  create_option_group                   = false
  create_parameter_group                = false
  tags                                  = local.tags
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
    from_port   = 443
    to_port     = 443
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
  security_groups                  = var.create_security_groups ? concat([aws_security_group.temporal_lb[0].id], var.temporal_lb_extra_security_group_ids) : var.temporal_lb_extra_security_group_ids
  tags                             = local.tags

  access_logs {
    enabled = var.elb_access_logs_enabled
    bucket  = var.elb_access_logs_bucket
    prefix  = "${var.elb_access_logs_prefix}/temporal"
  }
}

resource "aws_lb_target_group" "temporal" {
  name                 = "${local.name}-temporal"
  port                 = 7233
  protocol             = "TCP"
  vpc_id               = local.vpc_id
  target_type          = "ip"
  deregistration_delay = 300
  tags                 = local.tags

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
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.temporal.arn
  }
}

locals {
  temporal_environment_variables = merge(
    local.temporal_dd_env_vars,
    var.temporal_additional_environment_vars,
    {
      ENVIRONMENT                                      = var.environment
      INSTANCE                                         = var.instance
      DB                                               = "mysql8"
      DB_PORT                                          = "3306"
      DBNAME                                           = "temporal"
      MYSQL_SEEDS                                      = local.temporal_mysql_dns_name
      MYSQL_USER                                       = "bigeye"
      NUM_HISTORY_SHARDS                               = "512"
      PROMETHEUS_ENDPOINT                              = "0.0.0.0:9091"
      TEMPORAL_TLS_REQUIRE_CLIENT_AUTH                 = "true"
      TEMPORAL_TLS_FRONTEND_DISABLE_HOST_VERIFICATION  = var.temporal_use_default_certificates ? "true" : "false"
      TEMPORAL_TLS_INTERNODE_DISABLE_HOST_VERIFICATION = var.temporal_use_default_certificates ? "true" : "false"
      TEMPORAL_TLS_INTERNODE_SERVER_NAME               = local.temporal_dns_name
      TEMPORAL_TLS_FRONTEND_SERVER_NAME                = local.temporal_dns_name
      TEMPORAL_PER_NAMESPACE_WORKER_COUNT              = local.temporal_per_namespace_worker_count
      TEMPORAL_MAX_CONCURRENT_WORKFLOW_TASK_POLLERS    = local.temporal_max_concurrent_workflow_task_pollers
      TEMPORAL_TLS_DISABLE_HOST_VERIFICATION           = var.temporal_use_default_certificates ? "true" : "false"
      TEMPORAL_TLS_SERVER_NAME                         = local.temporal_dns_name
      SQL_MAX_IDLE_CONNS                               = "10"
    }
  )

  temporal_secret_arns = merge(var.temporal_additional_secret_arns, {
    "MYSQL_PWD" = local.temporal_rds_password_secret_arn
  })
}

resource "aws_ecs_task_definition" "temporal" {
  family                   = "${local.name}-temporal"
  cpu                      = var.temporal_cpu
  memory                   = var.temporal_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = local.tags
  execution_role_arn       = aws_iam_role.ecs.arn
  container_definitions = jsonencode([
    {
      name        = "${local.name}-temporal"
      cpu         = var.temporal_cpu
      memory      = var.temporal_memory
      image       = format("%s/%s%s:%s", local.image_registry, "temporal", var.image_repository_suffix, var.image_tag)
      environment = [for k, v in local.temporal_environment_variables : { Name = k, Value = v }]
      secrets     = [for k, v in local.temporal_secret_arns : { Name = k, ValueFrom = v }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.temporal.name
          "awslogs-region"        = local.aws_region
          "awslogs-stream-prefix" = "${local.name}-temporal"
        }
      }
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
  ])
}

resource "aws_ecs_service" "temporal" {
  depends_on      = [aws_lb.temporal]
  name            = "${local.name}-temporal"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.temporal.arn
  desired_count   = var.temporal_desired_count

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 300
  platform_version                   = "1.4.0"
  tags                               = local.tags

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 1
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }

  network_configuration {
    subnets          = local.application_subnet_ids
    assign_public_ip = false
    security_groups  = var.create_security_groups ? concat([aws_security_group.temporal[0].id, module.temporal_rds.client_security_group_id], var.temporal_extra_security_group_ids) : var.temporal_extra_security_group_ids
  }

  load_balancer {
    container_name   = "${local.name}-temporal"
    container_port   = 7233
    target_group_arn = aws_lb_target_group.temporal.arn
  }
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
  additional_security_group_ids = var.temporalui_extra_security_group_ids
  traffic_port                  = var.temporalui_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  healthcheck_interval             = 15
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = var.temporalui_lb_extra_security_group_ids
  lb_deregistration_delay          = 120

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/temporalui"

  # Task settings
  desired_count             = var.temporalui_desired_count
  cpu                       = var.temporalui_cpu
  memory                    = var.temporalui_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "temporalui", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key


  environment_variables = merge(
    local.temporalui_dd_env_vars,
    var.temporalui_additional_environment_vars,
    {
      ENVIRONMENT                           = var.environment
      INSTANCE                              = var.instance
      TEMPORAL_ADDRESS                      = "${local.temporal_dns_name}:443"
      TEMPORAL_UI_PORT                      = var.temporalui_port
      TEMPORAL_CORS_ORIGINS                 = "https://${local.temporal_dns_name}:443"
      TEMPORAL_TLS_ENABLE_HOST_VERIFICATION = var.temporal_use_default_certificates ? "false" : "true"
      TEMPORAL_TLS_SERVER_NAME              = local.temporal_dns_name
    }
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

  vpc_id                        = local.vpc_id
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  additional_security_group_ids = concat([module.rabbitmq.client_security_group_id], var.monocle_extra_security_group_ids)
  traffic_port                  = var.monocle_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  healthcheck_interval             = 60
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = var.monocle_lb_extra_security_group_ids
  lb_deregistration_delay          = 300

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/monocle"

  # Task settings
  desired_count             = var.monocle_desired_count
  cpu                       = var.monocle_cpu
  memory                    = var.monocle_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.monocle.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "monocle", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key


  environment_variables = merge(
    local.monocle_dd_env_vars,
    var.monocle_additional_environment_vars,
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
      SENTRY_DSN                 = var.sentry_dsn
    }
  )

  secret_arns = merge(var.monocle_additional_secret_arns, local.stitch_secrets_map, {
    MQ_BROKER_PASSWORD = local.rabbitmq_user_password_secret_arn
    ROBOT_PASSWORD     = local.robot_password_secret_arn
  })
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
  additional_security_group_ids = concat([module.rabbitmq.client_security_group_id], var.toretto_extra_security_group_ids)
  traffic_port                  = var.toretto_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = var.toretto_lb_extra_security_group_ids

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/toretto"

  # Task settings
  desired_count             = var.toretto_desired_count
  cpu                       = var.toretto_cpu
  memory                    = var.toretto_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.monocle.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "toretto", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key


  environment_variables = merge(
    local.toretto_dd_env_vars,
    var.toretto_additional_environment_vars,
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
      SENTRY_DSN                 = var.sentry_dsn
    }
  )

  secret_arns = merge(var.toretto_additional_secret_arns, local.stitch_secrets_map, {
    MQ_BROKER_PASSWORD = local.rabbitmq_user_password_secret_arn
    ROBOT_PASSWORD     = local.robot_password_secret_arn
  })
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
  additional_security_group_ids = concat([module.redis.client_security_group_id], var.scheduler_extra_security_group_ids)
  traffic_port                  = var.scheduler_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  healthcheck_path                 = "/health"
  ssl_policy                       = var.alb_ssl_policy
  acm_certificate_arn              = local.acm_certificate_arn
  lb_idle_timeout                  = 900
  lb_subnet_ids                    = local.internal_service_alb_subnet_ids
  lb_additional_security_group_ids = var.scheduler_lb_extra_security_group_ids

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/scheduler"

  # Task settings
  desired_count             = var.scheduler_desired_count
  cpu                       = var.scheduler_cpu
  memory                    = var.scheduler_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "scheduler", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key


  environment_variables = merge(var.scheduler_additional_environment_vars, {
    ENVIRONMENT           = var.environment
    INSTANCE              = var.instance
    PORT                  = var.scheduler_port
    DEPLOY_TYPE           = "AWS"
    DATAWATCH_ADDRESS     = "https://${local.datawatch_dns_name}"
    MAX_RAM_PERCENTAGE    = "85"
    SCHEDULER_THREADS     = var.scheduler_threads
    SENTRY_DSN            = var.sentry_dsn
    REDIS_PRIMARY_ADDRESS = module.redis.primary_endpoint_dns_name
    REDIS_PRIMARY_PORT    = module.redis.port
  })

  secret_arns = merge(var.scheduler_additional_secret_arns, {
    REDIS_PRIMARY_PASSWORD = local.redis_auth_token_secret_arn
    ROBOT_PASSWORD         = local.robot_password_secret_arn
  })
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

module "redis" {
  depends_on               = [aws_secretsmanager_secret_version.redis_auth_token]
  source                   = "../redis"
  name                     = local.name
  vpc_id                   = local.vpc_id
  create_security_groups   = var.create_security_groups
  subnet_group_name        = local.elasticache_subnet_group_name
  extra_security_group_ids = var.redis_extra_security_group_ids
  auth_token_secret_arn    = local.redis_auth_token_secret_arn
  instance_type            = var.redis_instance_type
  instance_count           = var.redundant_infrastructure ? 2 : 1
  engine_version           = var.redis_engine_version
  maintenance_window       = var.redis_maintenance_window
  cloudwatch_loggroup_name = aws_cloudwatch_log_group.bigeye.name
  tags                     = local.tags
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
module "datawatch_rds" {
  source = "../rds"
  name   = "${local.name}-datawatch"

  # Connection Info
  db_name                       = var.datawatch_rds_db_name
  root_user_name                = "bigeye"
  root_user_password_secret_arn = local.datawatch_rds_password_secret_arn
  snapshot_identifier           = var.datawatch_rds_snapshot_identifier

  #Networking
  vpc_id                   = local.vpc_id
  db_subnet_group_name     = local.database_subnet_group_name
  create_security_groups   = var.create_security_groups
  extra_security_group_ids = var.datawatch_rds_extra_security_group_ids
  enable_multi_az          = var.redundant_infrastructure ? true : false

  # Settings
  instance_class = var.datawatch_rds_instance_type
  engine_version = var.datawatch_rds_engine_version

  # Storage
  allocated_storage     = var.datawatch_rds_allocated_storage
  max_allocated_storage = var.datawatch_rds_max_allocated_storage
  storage_type          = "gp3"

  # Ops
  deletion_protection                   = var.deletion_protection
  backup_window                         = var.rds_backup_window
  backup_retention_period               = var.datawatch_rds_backup_retention_period
  maintenance_window                    = var.rds_maintenance_window
  enable_performance_insights           = var.datawatch_rds_enable_performance_insights
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  enhanced_monitoring_interval          = var.datawatch_rds_enhanced_monitoring_interval
  enhanced_monitoring_role_arn          = var.datawatch_rds_enhanced_monitoring_role_arn

  create_option_group    = false
  create_parameter_group = true
  parameter_group_name   = "${local.name}-datawatch"
  parameters = [
    {
      name  = "log_bin_trust_function_creators"
      value = "1"
    },
    {
      name  = "general_log"
      value = 0
    },
    {
      name  = "slow_query_log"
      value = 0
    },
    {
      name  = "long_query_time"
      value = 120
    },
    {
      name         = "performance_schema"
      value        = 1
      apply_method = "pending-reboot"
    },
    {
      name         = "skip_name_resolve"
      value        = 1
      apply_method = "pending-reboot"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "innodb_lock_wait_timeout"
      value = 300
    },
    {
      name  = "lock_wait_timeout"
      value = 300
    }
  ]

  # Replica
  create_replica                  = var.datawatch_rds_replica_enabled
  replica_instance_class          = var.datawatch_rds_replica_instance_type
  replica_backup_retention_period = var.datawatch_rds_replica_backup_retention_period

  tags = local.tags
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

module "datawatch" {
  source   = "../simpleservice"
  app      = "datawatch"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-datawatch"
  tags     = merge(local.tags, { app = "datawatch" })

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
  lb_additional_security_group_ids = var.datawatch_lb_extra_security_group_ids
  lb_deregistration_delay          = 900

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/datawatch"

  # Task settings
  desired_count             = var.datawatch_desired_count
  cpu                       = var.datawatch_cpu
  memory                    = var.datawatch_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.datawatch.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    var.datawatch_additional_environment_vars,
    {
      ENVIRONMENT                     = var.environment
      INSTANCE                        = var.instance
      PORT                            = var.datawatch_port
      APP                             = "datawatch"
      MYSQL_JDBC                      = "jdbc:mysql://${local.datawatch_mysql_dns_name}:3306/toro?serverTimezone=UTC"
      MYSQL_USER                      = "bigeye"
      MYSQL_MAXSIZE                   = var.datawatch_mysql_maxsize
      MYSQL_TRANSACTION_ISOLATION     = "default"
      REDIRECT_ADDRESS                = "https://${local.vanity_dns_name}"
      MONOCLE_ADDRESS                 = "https://${local.monocle_dns_name}"
      SCHEDULER_ADDRESS               = "https://${local.scheduler_dns_name}"
      TORETTO_ADDRESS                 = "https://${local.toretto_dns_name}"
      FF_SEND_ANALYTICS_ENABLED       = "true"
      MQ_BROKER_HOST                  = module.rabbitmq.endpoint
      MQ_BROKER_USERNAME              = var.rabbitmq_user_name
      DEPLOY_TYPE                     = "AWS"
      FF_QUEUE_BACKFILL_ENABLED       = "true"
      FF_ANALYTICS_LOGGING_ENABLED    = var.datawatch_feature_analytics_logging_enabled
      STITCH_SCHEMA_NAME              = var.datawatch_stitch_schema_name
      AUTH0_DOMAIN                    = var.auth0_domain
      EXTERNAL_LOGGING_LEVEL          = var.datawatch_external_logging_level
      REDIS_PRIMARY_ADDRESS           = module.redis.primary_endpoint_dns_name
      REDIS_PRIMARY_PORT              = module.redis.port
      REDIS_SSL_ENABLED               = "true"
      SLACK_HAS_DEDICATED_APP         = var.datawatch_slack_has_dedicated_app ? "true" : "false"
      WORKERS_ENABLED                 = "false"
      ACTIONABLE_NOTIFICATION_ENABLED = "false"
      REQUEST_BODY_LOGGING_ENABLED    = var.datawatch_request_body_logging_enabled
      REQUEST_AUTH_LOGGING_ENABLED    = var.datawatch_request_auth_logging_enabled

      TEMPORAL_ENABLED                           = true
      TEMPORAL_TARGET                            = "${local.temporal_dns_name}:443"
      TEMPORAL_NAMESPACE                         = var.temporal_namespace
      TEMPORAL_SSL_HOSTNAME_VERIFICATION_ENABLED = var.temporal_use_default_certificates ? "false" : "true"

      MTLS_KEY_PATH         = "/temporal/mtls.key"
      MTLS_CERT_PATH        = "/temporal/mtls.pem"
      MAX_RAM_PERCENTAGE    = var.datawatch_jvm_max_ram_pct
      DEMO_ENDPOINT_ENABLED = var.is_demo
      SENTRY_DSN            = var.sentry_dsn
      AWS_REGION            = local.aws_region
    }
  )

  secret_arns = local.datawatch_secret_arns
}

module "datawork" {
  source   = "../simpleservice"
  app      = "datawork"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-datawork"
  tags     = merge(local.tags, { app = "datawork" })

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
  lb_additional_security_group_ids = var.datawork_lb_extra_security_group_ids

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/datawork"

  # Task settings
  desired_count             = var.datawork_desired_count
  cpu                       = var.datawork_cpu
  memory                    = var.datawork_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.datawatch.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    var.datawork_additional_environment_vars,
    {
      ENVIRONMENT                  = var.environment
      INSTANCE                     = var.instance
      PORT                         = var.datawork_port
      APP                          = "datawork"
      MYSQL_JDBC                   = "jdbc:mysql://${local.datawatch_mysql_dns_name}:3306/toro?serverTimezone=UTC"
      MYSQL_USER                   = "bigeye"
      MYSQL_MAXSIZE                = var.datawatch_mysql_maxsize
      MYSQL_TRANSACTION_ISOLATION  = "default"
      REDIRECT_ADDRESS             = "https://${local.vanity_dns_name}"
      MONOCLE_ADDRESS              = "https://${local.monocle_dns_name}"
      SCHEDULER_ADDRESS            = "https://${local.scheduler_dns_name}"
      TORETTO_ADDRESS              = "https://${local.toretto_dns_name}"
      DATAWATCH_ADDRESS            = "http://localhost:${var.datawork_port}"
      FF_SEND_ANALYTICS_ENABLED    = "true"
      MQ_BROKER_HOST               = module.rabbitmq.endpoint
      MQ_BROKER_USERNAME           = var.rabbitmq_user_name
      DEPLOY_TYPE                  = "AWS"
      FF_QUEUE_BACKFILL_ENABLED    = "true"
      FF_ANALYTICS_LOGGING_ENABLED = var.datawatch_feature_analytics_logging_enabled
      STITCH_SCHEMA_NAME           = var.datawatch_stitch_schema_name
      AUTH0_DOMAIN                 = var.auth0_domain
      EXTERNAL_LOGGING_LEVEL       = var.datawatch_external_logging_level
      REDIS_PRIMARY_ADDRESS        = module.redis.primary_endpoint_dns_name
      REDIS_PRIMARY_PORT           = module.redis.port
      REDIS_SSL_ENABLED            = "true"
      SLACK_HAS_DEDICATED_APP      = var.datawatch_slack_has_dedicated_app

      WORKERS_ENABLED    = "true"
      METRIC_RUN_WORKERS = "1"
      EXCLUDE_QUEUES     = "trigger-batch-metric-run"

      ACTIONABLE_NOTIFICATION_ENABLED            = "false"
      REQUEST_BODY_LOGGING_ENABLED               = var.datawatch_request_body_logging_enabled
      REQUEST_AUTH_LOGGING_ENABLED               = var.datawatch_request_auth_logging_enabled
      TEMPORAL_ENABLED                           = true
      TEMPORAL_TARGET                            = "${local.temporal_dns_name}:443"
      TEMPORAL_NAMESPACE                         = var.temporal_namespace
      TEMPORAL_SSL_HOSTNAME_VERIFICATION_ENABLED = var.temporal_use_default_certificates ? "false" : "true"
      MTLS_KEY_PATH                              = "/temporal/mtls.key"
      MTLS_CERT_PATH                             = "/temporal/mtls.pem"
      MAX_RAM_PERCENTAGE                         = var.datawatch_jvm_max_ram_pct
      DEMO_ENDPOINT_ENABLED                      = var.is_demo
      SENTRY_DSN                                 = var.sentry_dsn
      AWS_REGION                                 = local.aws_region
    }
  )

  secret_arns = local.datawatch_secret_arns
}

module "metricwork" {
  source   = "../simpleservice"
  app      = "metricwork"
  instance = var.instance
  stack    = local.name
  name     = "${local.name}-metricwork"
  tags     = merge(local.tags, { app = "metricwork" })

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
  lb_additional_security_group_ids = var.metricwork_lb_extra_security_group_ids

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = "${var.elb_access_logs_prefix}/metricwork"

  # Task settings
  desired_count             = var.metricwork_desired_count
  cpu                       = var.metricwork_cpu
  memory                    = var.metricwork_memory
  execution_role_arn        = aws_iam_role.ecs.arn
  task_role_arn             = aws_iam_role.datawatch.arn
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "datawatch", var.image_repository_suffix)
  image_tag                 = var.image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name

  # Datadog
  datadog_agent_enabled = var.datadog_agent_enabled
  datadog_agent_image   = var.datadog_agent_image
  datadog_agent_cpu     = var.datadog_agent_cpu
  datadog_agent_memory  = var.datadog_agent_memory
  datadog_agent_api_key = var.datadog_agent_api_key

  environment_variables = merge(
    local.datawatch_dd_env_vars,
    var.metricwork_additional_environment_vars,
    {
      ENVIRONMENT                  = var.environment
      INSTANCE                     = var.instance
      PORT                         = var.metricwork_port
      APP                          = "metricwork"
      MYSQL_JDBC                   = "jdbc:mysql://${local.datawatch_mysql_dns_name}:3306/toro?serverTimezone=UTC"
      MYSQL_USER                   = "bigeye"
      MYSQL_MAXSIZE                = var.datawatch_mysql_maxsize
      MYSQL_TRANSACTION_ISOLATION  = "default"
      REDIRECT_ADDRESS             = "https://${local.vanity_dns_name}"
      MONOCLE_ADDRESS              = "https://${local.monocle_dns_name}"
      SCHEDULER_ADDRESS            = "https://${local.scheduler_dns_name}"
      TORETTO_ADDRESS              = "https://${local.toretto_dns_name}"
      DATAWATCH_ADDRESS            = "http://localhost:${var.metricwork_port}"
      FF_SEND_ANALYTICS_ENABLED    = "true"
      MQ_BROKER_HOST               = module.rabbitmq.endpoint
      MQ_BROKER_USERNAME           = var.rabbitmq_user_name
      DEPLOY_TYPE                  = "AWS"
      FF_QUEUE_BACKFILL_ENABLED    = "true"
      FF_ANALYTICS_LOGGING_ENABLED = var.datawatch_feature_analytics_logging_enabled
      STITCH_SCHEMA_NAME           = var.datawatch_stitch_schema_name
      AUTH0_DOMAIN                 = var.auth0_domain
      EXTERNAL_LOGGING_LEVEL       = var.datawatch_external_logging_level
      REDIS_PRIMARY_ADDRESS        = module.redis.primary_endpoint_dns_name
      REDIS_PRIMARY_PORT           = module.redis.port
      REDIS_SSL_ENABLED            = "true"
      SLACK_HAS_DEDICATED_APP      = var.datawatch_slack_has_dedicated_app

      WORKERS_ENABLED       = "true"
      METRIC_RUN_WORKERS    = "1"
      SINGLE_QUEUE_OVERRIDE = "trigger-batch-metric-run"

      ACTIONABLE_NOTIFICATION_ENABLED            = "false"
      REQUEST_BODY_LOGGING_ENABLED               = var.datawatch_request_body_logging_enabled
      REQUEST_AUTH_LOGGING_ENABLED               = var.datawatch_request_auth_logging_enabled
      TEMPORAL_ENABLED                           = true
      TEMPORAL_TARGET                            = "${local.temporal_dns_name}:443"
      TEMPORAL_NAMESPACE                         = var.temporal_namespace
      TEMPORAL_SSL_HOSTNAME_VERIFICATION_ENABLED = var.temporal_use_default_certificates ? "false" : "true"
      MTLS_KEY_PATH                              = "/temporal/mtls.key"
      MTLS_CERT_PATH                             = "/temporal/mtls.pem"
      MAX_RAM_PERCENTAGE                         = var.datawatch_jvm_max_ram_pct
      DEMO_ENDPOINT_ENABLED                      = var.is_demo
      SENTRY_DSN                                 = var.sentry_dsn
      AWS_REGION                                 = local.aws_region
    }
  )

  secret_arns = local.datawatch_secret_arns
}

