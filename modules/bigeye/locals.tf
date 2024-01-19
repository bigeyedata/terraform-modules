locals {
  # The global name to use
  name       = "${var.environment}-${var.instance}"
  stack_name = local.name

  tags = merge(
    {
      env      = var.environment,
      stack    = local.stack_name,
      instance = var.instance
    },
    var.tags_global,
  )

  # VPC Calculated values
  vpc_id     = data.aws_vpc.this.id
  create_vpc = length(var.byovpc_vpc_id) > 0 ? false : true
  # vpc_cidr_prefix takes the first part of the CIDR block, e.g. "10.1.0.0/16" -> "10.1"
  vpc_cidr_prefix = local.create_vpc ? join(".", slice(split(".", var.vpc_cidr_block), 0, 2)) : ""
  vpc_availability_zones = length(var.vpc_availability_zones) == 0 ? [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b",
    "${data.aws_region.current.name}c"
  ] : var.vpc_availability_zones

  internal_service_alb_subnet_ids = local.create_vpc ? module.vpc[0].intra_subnets : var.byovpc_internal_subnet_ids
  public_alb_subnet_ids           = local.create_vpc ? module.vpc[0].public_subnets : var.byovpc_public_subnet_ids
  application_subnet_ids          = local.create_vpc ? module.vpc[0].private_subnets : var.byovpc_application_subnet_ids
  database_subnet_group_name      = local.create_vpc ? module.vpc[0].database_subnet_group_name : var.byovpc_database_subnet_group_name
  elasticache_subnet_group_name   = local.create_vpc ? module.vpc[0].elasticache_subnet_group_name : var.byovpc_redis_subnet_group_name
  rabbitmq_subnet_group_ids       = local.create_vpc ? module.vpc[0].elasticache_subnets : var.byovpc_rabbitmq_subnet_ids


  # AWS Account
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name
  image_registry = var.image_registry == "" ? "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com" : var.image_registry

  # Secrets
  secret_retention_days                = 0
  create_rabbitmq_user_password_secret = var.rabbitmq_user_password_secret_arn == ""
  rabbitmq_user_password_secret_arn    = local.create_rabbitmq_user_password_secret ? aws_secretsmanager_secret.rabbitmq_user_password[0].arn : var.rabbitmq_user_password_secret_arn
  create_redis_auth_token_secret       = var.redis_auth_token_secret_arn == ""
  redis_auth_token_secret_arn          = local.create_redis_auth_token_secret ? aws_secretsmanager_secret.redis_auth_token[0].arn : var.redis_auth_token_secret_arn
  create_robot_password_secret         = var.datawatch_robot_password_secret_arn == ""
  robot_password_secret_arn            = local.create_robot_password_secret ? aws_secretsmanager_secret.robot_password[0].arn : var.datawatch_robot_password_secret_arn
  create_datawatch_rds_password_secret = var.datawatch_rds_root_user_password_secret_arn == ""
  datawatch_rds_password_secret_arn    = local.create_datawatch_rds_password_secret ? aws_secretsmanager_secret.datawatch_rds_password[0].arn : var.datawatch_rds_root_user_password_secret_arn
  create_temporal_rds_password_secret  = var.temporal_rds_root_user_password_secret_arn == ""
  temporal_rds_password_secret_arn     = local.create_temporal_rds_password_secret ? aws_secretsmanager_secret.temporal_rds_password[0].arn : var.temporal_rds_root_user_password_secret_arn
  create_adminpages_password_secret    = var.adminpages_password_secret_arn == ""
  adminpages_password_secret_arn       = local.create_adminpages_password_secret ? aws_secretsmanager_secret.adminpages_password[0].arn : var.adminpages_password_secret_arn

  # DNS
  base_dns_alias                   = coalesce(var.vanity_alias, local.name)
  vanity_dns_name                  = "${local.base_dns_alias}.${var.top_level_dns_name}"
  datawatch_dns_name               = "${local.base_dns_alias}-datawatch.${var.top_level_dns_name}"
  datawatch_mysql_dns_name         = "${local.base_dns_alias}-mysql.${var.top_level_dns_name}"
  datawatch_mysql_replica_dns_name = "${local.base_dns_alias}-mysql-ro.${var.top_level_dns_name}"
  datawork_dns_name                = "${local.base_dns_alias}-datawork.${var.top_level_dns_name}"
  metricwork_dns_name              = "${local.base_dns_alias}-metricwork.${var.top_level_dns_name}"
  temporal_dns_name                = "${local.base_dns_alias}-workflows.${var.top_level_dns_name}"
  temporal_admin_dns_name          = "${local.base_dns_alias}-workflows-admin.${var.top_level_dns_name}"
  temporal_mysql_dns_name          = "${local.base_dns_alias}-temporal-mysql.${var.top_level_dns_name}"
  monocle_dns_name                 = "${local.base_dns_alias}-monocle.${var.top_level_dns_name}"
  toretto_dns_name                 = "${local.base_dns_alias}-toretto.${var.top_level_dns_name}"
  scheduler_dns_name               = "${local.base_dns_alias}-scheduler.${var.top_level_dns_name}"
  web_dns_name                     = "${local.base_dns_alias}-web.${var.top_level_dns_name}"

  create_acm_cert           = var.acm_certificate_arn == "" ? true : false
  domain_validation_options = local.create_acm_cert ? aws_acm_certificate.wildcard[0].domain_validation_options : []
  acm_certificate_arn       = local.create_acm_cert ? aws_acm_certificate.wildcard[0].arn : var.acm_certificate_arn

  max_port = 65535

  # Docker image tags
  haproxy_image_tag      = coalesce(var.haproxy_image_tag, var.image_tag)
  web_image_tag          = coalesce(var.web_image_tag, var.image_tag)
  monocle_image_tag      = coalesce(var.monocle_image_tag, var.image_tag)
  toretto_image_tag      = coalesce(var.toretto_image_tag, var.image_tag)
  temporalui_image_tag   = coalesce(var.temporalui_image_tag, var.image_tag)
  temporal_image_tag     = coalesce(var.temporal_image_tag, var.image_tag)
  datawatch_image_tag    = coalesce(var.datawatch_image_tag, var.image_tag)
  datawork_image_tag     = coalesce(var.datawork_image_tag, var.image_tag)
  metricwork_image_tag   = coalesce(var.metricwork_image_tag, var.image_tag)
  scheduler_image_tag    = coalesce(var.scheduler_image_tag, var.image_tag)
  bigeye_admin_image_tag = coalesce(var.bigeye_admin_image_tag, var.image_tag)

  auth0_secrets_map = var.auth0_client_id_secretsmanager_arn == "" ? {} : {
    AUTH0_CLIENT_ID     = var.auth0_client_id_secretsmanager_arn
    AUTH0_CLIENT_SECRET = var.auth0_client_secret_secretsmanager_arn
  }

  slack_secrets_map = var.slack_client_id_secretsmanager_arn == "" ? {} : {
    SLACK_CLIENT_ID      = var.slack_client_id_secretsmanager_arn
    SLACK_CLIENT_SECRET  = var.slack_client_secret_secretsmanager_arn
    SLACK_SIGNING_SECRET = var.slack_client_signing_secret_secretsmanager_arn
  }

  stitch_secrets_map = var.stitch_api_token_secretsmanager_arn == "" ? {} : {
    STITCH_API_TOKEN = var.stitch_api_token_secretsmanager_arn
  }

  datawatch_additional_security_groups = var.create_security_groups ? concat(
    [
      module.redis.client_security_group_id,
      module.rabbitmq.client_security_group_id,
      module.datawatch_rds.client_security_group_id,
      module.bigeye_admin.client_security_group_id,
    ],
    var.datawatch_rds_replica_enabled ? [module.datawatch_rds.replica_client_security_group_id] : [],
  ) : []

  datawatch_secret_arns = merge(
    local.auth0_secrets_map,
    local.slack_secrets_map,
    local.stitch_secrets_map,
    var.datawatch_additional_secret_arns,
    {
      REDIS_PRIMARY_PASSWORD = local.redis_auth_token_secret_arn
      MQ_BROKER_PASSWORD     = local.rabbitmq_user_password_secret_arn
      MYSQL_PASSWORD         = local.datawatch_rds_password_secret_arn
      ROBOT_PASSWORD         = local.robot_password_secret_arn
    }
  )

  temporal_lb_port                              = 443
  temporal_per_namespace_worker_count           = coalesce(var.temporal_per_namespace_worker_count, var.temporal_desired_count * 3)
  temporal_max_concurrent_workflow_task_pollers = coalesce(var.temporal_max_concurrent_workflow_task_pollers, local.temporal_per_namespace_worker_count * 3)

  #======================================================
  # Datadog specs
  #======================================================
  create_datadog_secret            = var.datadog_agent_enabled && var.datadog_agent_api_key != "" && var.datadog_agent_api_key_secret_arn == ""
  datadog_agent_api_key_secret_arn = local.create_datadog_secret ? aws_secretsmanager_secret.datadog_agent_api_key[0].arn : var.datadog_agent_api_key_secret_arn
  web_dd_env_vars = var.datadog_agent_enabled ? {
    DD_TRACE_DISABLED_PLUGINS = "dns"
  } : {}
  datawatch_dd_env_vars = var.datadog_agent_enabled ? {
    DD_TRACE_DISABLED_PLUGINS        = "dns"
    DD_LOG_INJECTION                 = "true"
    DD_TRACE_SAMPLE_RATE             = "1.00"
    DD_INTEGRATION_HIBERNATE_ENABLED = "false"
    DD_INTEGRATION_JDBC_ENABLED      = "false"
  } : {}
  temporalui_dd_env_vars = var.datadog_agent_enabled ? {
    DD_VERSION = var.image_tag
  } : {}
  temporal_dd_env_vars = var.datadog_agent_enabled ? {
    DD_VERSION      = var.image_tag
    DD_TAGS         = "app:temporal instance:${var.instance} stack:${local.name}"
    DD_SERVICE      = "temporal"
    DATADOG_ENABLED = "true"
    DD_ENV          = local.name
  } : {}
}
