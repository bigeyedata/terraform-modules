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

  # Temporal Task Queues
  lineage_temporal_queues    = ["source-lineage", "metacenter-lineage"]
  metric_run_temporal_queues = ["trigger-batch-metric-run"]

  datawork_temporal_exclude_queues_str = join(",",
    concat(
      local.lineage_temporal_queues,
      local.metric_run_temporal_queues
    )
  )
  lineagework_temporal_include_queues_str = join(",", local.lineage_temporal_queues)
  metricwork_temporal_include_queues_str  = join(",", local.metric_run_temporal_queues)

  # Rabbit MQ
  create_rabbitmq               = var.byo_rabbitmq_endpoint == ""
  rabbitmq_endpoint             = local.create_rabbitmq ? module.rabbitmq[0].endpoint : var.byo_rabbitmq_endpoint
  rabbitmq_cluster_mode_enabled = var.rabbitmq_cluster_enabled == null ? var.redundant_infrastructure : var.rabbitmq_cluster_enabled
  # compact() will strip the empty elements
  backfillwork_mq_include_queues = compact([
    "backfill",
    "posthoc",
  ])
  backfillwork_mq_include_queues_str = join(",", local.backfillwork_mq_include_queues)

  datawork_mq_exclude_queues = join(",",
    concat(
      local.backfillwork_mq_include_queues,
      local.indexwork_mq_include_queues,
      local.lineagework_mq_include_queues,
      local.metricwork_mq_include_queues,
    )
  )

  indexwork_mq_include_queues = compact([
    "dataset_index_op_v2",
    "catalog_index_v2",
  ])
  indexwork_mq_include_queues_str = join(",", local.indexwork_mq_include_queues)

  lineagework_mq_include_queues = compact([
    "lineage"
  ])
  lineagework_mq_include_queues_str = join(",", local.lineagework_mq_include_queues)
  metricwork_mq_include_queues = compact([
    "metric_batch"
  ])
  metricwork_mq_include_queues_str = join(",", local.metricwork_mq_include_queues)

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
  create_robot_agent_apikey_secret     = var.datawatch_robot_agent_api_key_secret_arn == ""
  robot_agent_apikey_secret_arn        = local.create_robot_agent_apikey_secret ? aws_secretsmanager_secret.robot_agent_api_key[0].arn : var.datawatch_robot_agent_api_key_secret_arn
  create_base_dw_encryption_secret     = var.datawatch_base_encryption_secret_arn == ""
  base_datawatch_encryption_secret_arn = local.create_base_dw_encryption_secret ? aws_secretsmanager_secret.base_encryption[0].arn : var.datawatch_base_encryption_secret_arn
  create_base_dw_salt_secret           = var.datawatch_base_salt_secret_arn == ""
  base_datawatch_salt_secret_arn       = local.create_base_dw_salt_secret ? aws_secretsmanager_secret.base_salt[0].arn : var.datawatch_base_salt_secret_arn
  create_datawatch_rds_password_secret = var.datawatch_rds_root_user_password_secret_arn == ""
  datawatch_rds_password_secret_arn    = local.create_datawatch_rds_password_secret ? aws_secretsmanager_secret.datawatch_rds_password[0].arn : var.datawatch_rds_root_user_password_secret_arn
  create_temporal_rds_password_secret  = var.temporal_rds_root_user_password_secret_arn == ""
  temporal_rds_password_secret_arn     = local.create_temporal_rds_password_secret ? aws_secretsmanager_secret.temporal_rds_password[0].arn : var.temporal_rds_root_user_password_secret_arn

  temporal_opensearch_password_byo_secret    = var.temporal_opensearch_master_user_password_secret_arn != ""
  create_temporal_opensearch_password_secret = var.temporal_opensearch_enabled && var.temporal_opensearch_master_user_password_secret_arn == ""
  temporal_opensearch_password_secret_arn    = local.create_temporal_opensearch_password_secret ? aws_secretsmanager_secret.temporal_opensearch_password[0].arn : var.temporal_opensearch_master_user_password_secret_arn

  create_adminpages_password_secret = var.adminpages_password_secret_arn == ""
  adminpages_password_secret_arn    = local.create_adminpages_password_secret ? aws_secretsmanager_secret.adminpages_password[0].arn : var.adminpages_password_secret_arn
  # byomailserver
  byomailserver_enabled                   = var.byomailserver_smtp_host != "" && var.byomailserver_smtp_port != "" && var.byomailserver_smtp_user != "" && var.byomailserver_smtp_password_secret_arn != "" && var.byomailserver_smtp_from_address != ""
  byomailserver_smtp_host                 = local.byomailserver_enabled ? var.byomailserver_smtp_host : ""
  byomailserver_smtp_port                 = local.byomailserver_enabled ? var.byomailserver_smtp_port : ""
  byomailserver_smtp_user                 = local.byomailserver_enabled ? var.byomailserver_smtp_user : ""
  byomailserver_smtp_from_address         = local.byomailserver_enabled ? var.byomailserver_smtp_from_address : ""
  byomailserver_smtp_password_secrets_map = local.byomailserver_enabled ? { MAILER_PASSWORD = var.byomailserver_smtp_password_secret_arn } : {}

  # DNS
  base_dns_alias                          = coalesce(var.vanity_alias, local.name)
  vanity_dns_name                         = var.use_top_level_dns_apex_as_vanity ? var.top_level_dns_name : "${local.base_dns_alias}.${var.top_level_dns_name}"
  datawatch_dns_name                      = "${local.base_dns_alias}-datawatch.${var.top_level_dns_name}"
  datawatch_mysql_vanity_dns_name         = "${local.base_dns_alias}-mysql.${var.top_level_dns_name}"
  datawatch_mysql_replica_vanity_dns_name = "${local.base_dns_alias}-mysql-ro.${var.top_level_dns_name}"
  datawork_dns_name                       = "${local.base_dns_alias}-datawork.${var.top_level_dns_name}"
  backfillwork_dns_name                   = "${local.base_dns_alias}-backfillwork.${var.top_level_dns_name}"
  indexwork_dns_name                      = "${local.base_dns_alias}-indexwork.${var.top_level_dns_name}"
  lineagework_dns_name                    = "${local.base_dns_alias}-lineagework.${var.top_level_dns_name}"
  metricwork_dns_name                     = "${local.base_dns_alias}-metricwork.${var.top_level_dns_name}"
  internalapi_dns_name                    = "${local.base_dns_alias}-internalapi.${var.top_level_dns_name}"
  temporal_dns_name                       = "${local.base_dns_alias}-workflows.${var.top_level_dns_name}"
  temporalui_dns_name                     = "${local.base_dns_alias}-workflows-admin.${var.top_level_dns_name}"
  temporal_mysql_vanity_dns_name          = "${local.base_dns_alias}-temporal-mysql.${var.top_level_dns_name}"
  monocle_dns_name                        = "${local.base_dns_alias}-monocle.${var.top_level_dns_name}"
  toretto_dns_name                        = "${local.base_dns_alias}-toretto.${var.top_level_dns_name}"
  scheduler_dns_name                      = "${local.base_dns_alias}-scheduler.${var.top_level_dns_name}"
  web_dns_name                            = "${local.base_dns_alias}-web.${var.top_level_dns_name}"

  # RDS DNS - if create_dns_records is disabled, using the RDS-provided DNS name is a more reliable way of getting up and running
  use_rds_vanity_names     = var.create_dns_records ? true : false
  datawatch_mysql_dns_name = local.use_rds_vanity_names ? local.datawatch_mysql_vanity_dns_name : module.datawatch_rds.primary_dns_name
  temporal_mysql_dns_name  = local.use_rds_vanity_names ? local.temporal_mysql_vanity_dns_name : module.temporal_rds.primary_dns_name

  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.Overview.Engines.html
  performance_insights_unavailable_instance_types      = ["db.t2.micro", "db.t2.small", "db.t3.micro", "db.t3.small", "db.t4g.micro", "db.t4g.small"]
  datawatch_rds_performance_insights_available         = !contains(local.performance_insights_unavailable_instance_types, var.datawatch_rds_instance_type) ? true : false
  datawatch_rds_performance_insights_enabled           = alltrue([var.datawatch_rds_enable_performance_insights, local.datawatch_rds_performance_insights_available])
  datawatch_rds_replica_performance_insights_available = !contains(local.performance_insights_unavailable_instance_types, var.datawatch_rds_replica_instance_type) ? true : false
  datawatch_rds_replica_performance_insights_enabled   = alltrue([var.datawatch_rds_enable_performance_insights, local.datawatch_rds_replica_performance_insights_available])
  temporal_rds_performance_insights_available          = !contains(local.performance_insights_unavailable_instance_types, var.temporal_rds_instance_type) ? true : false
  temporal_rds_performance_insights_enabled            = alltrue([var.temporal_rds_enable_performance_insights, local.temporal_rds_performance_insights_available])

  create_acm_cert           = var.acm_certificate_arn == "" ? true : false
  domain_validation_options = local.create_acm_cert ? aws_acm_certificate.wildcard[0].domain_validation_options : []
  acm_certificate_arn       = local.create_acm_cert ? aws_acm_certificate.wildcard[0].arn : var.acm_certificate_arn

  max_port = 65535

  # IAM Roles
  create_ecs_role       = var.ecs_service_role_arn == ""
  ecs_role_arn          = local.create_ecs_role ? aws_iam_role.ecs[0].arn : var.ecs_service_role_arn
  create_datawatch_role = var.datawatch_task_role_arn == ""
  datawatch_role_arn    = local.create_datawatch_role ? aws_iam_role.datawatch[0].arn : var.datawatch_task_role_arn
  create_monocle_role   = var.monocle_task_role_arn == ""
  monocle_role_arn      = local.create_monocle_role ? aws_iam_role.monocle[0].arn : var.monocle_task_role_arn

  # KMS
  using_kms      = var.datawatch_encrypt_secrets_with_kms_enabled ? true : false
  create_kms_key = var.datawatch_kms_key_arn == "" ? true : false
  kms_key_arn    = local.create_kms_key ? aws_kms_key.datawatch[0].arn : data.aws_kms_key.datawatch[0].arn
  kms_key_id     = local.create_kms_key ? aws_kms_key.datawatch[0].key_id : data.aws_kms_key.datawatch[0].id

  # Models bucket random name
  models_bucket_has_name_override = var.ml_models_s3_bucket_name_override == "" ? false : true

  # Docker image tags
  haproxy_image_tag      = coalesce(var.haproxy_image_tag, var.image_tag)
  web_image_tag          = coalesce(var.web_image_tag, var.image_tag)
  monocle_image_tag      = coalesce(var.monocle_image_tag, var.image_tag)
  toretto_image_tag      = coalesce(var.toretto_image_tag, var.image_tag)
  temporalui_image_tag   = coalesce(var.temporalui_image_tag, var.image_tag)
  temporal_image_tag     = coalesce(var.temporal_image_tag, var.image_tag)
  datawatch_image_tag    = coalesce(var.datawatch_image_tag, var.image_tag)
  datawork_image_tag     = coalesce(var.datawork_image_tag, var.image_tag)
  backfillwork_image_tag = coalesce(var.backfillwork_image_tag, var.image_tag)
  indexwork_image_tag    = coalesce(var.indexwork_image_tag, var.image_tag)
  lineagework_image_tag  = coalesce(var.lineagework_image_tag, var.image_tag)
  metricwork_image_tag   = coalesce(var.metricwork_image_tag, var.image_tag)
  internalapi_image_tag  = coalesce(var.internalapi_image_tag, var.image_tag)
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

  sentry_event_level_env_variable = var.sentry_event_level != "" ? {
    SENTRY_EVENT_LEVEL = var.sentry_event_level
  } : {}
  sentry_dsn_secret_map = var.sentry_dsn_secret_arn != "" ? {
    SENTRY_DSN = var.sentry_dsn_secret_arn
  } : {}

  datawatch_jdbc_database_name = coalesce(var.datawatch_db_name, var.datawatch_rds_db_name)
  datawatch_additional_security_groups = var.create_security_groups ? concat(
    [module.bigeye_admin.client_security_group_id],
    local.create_rabbitmq ? [module.rabbitmq[0].client_security_group_id] : [],
  ) : []

  datawatch_secret_arns = merge(
    local.auth0_secrets_map,
    local.slack_secrets_map,
    local.stitch_secrets_map,
    local.sentry_dsn_secret_map,
    local.byomailserver_smtp_password_secrets_map,
    {
      REDIS_PRIMARY_PASSWORD = local.redis_auth_token_secret_arn
      MQ_BROKER_PASSWORD     = local.rabbitmq_user_password_secret_arn
      MYSQL_PASSWORD         = local.datawatch_rds_password_secret_arn
      ROBOT_PASSWORD         = local.robot_password_secret_arn
      ROBOT_AGENT_API_KEY    = local.robot_agent_apikey_secret_arn
      BASE_ENCRYPTION_SECRET = local.base_datawatch_encryption_secret_arn
      BASE_SALT              = local.base_datawatch_salt_secret_arn
    },
    var.datawatch_additional_secret_arns,
  )
  efs_volume_enabled = length(var.efs_volume_enabled_services) > 0

  temporal_lb_port                                     = 443
  temporal_per_namespace_worker_count                  = coalesce(var.temporal_per_namespace_worker_count, var.temporal_desired_count * 3)
  temporal_max_concurrent_workflow_task_pollers        = coalesce(var.temporal_max_concurrent_workflow_task_pollers, local.temporal_per_namespace_worker_count * 3)
  temporal_frontend_persistence_max_qps                = var.temporal_frontend_persistence_max_qps
  temporal_history_persistence_max_qps                 = var.temporal_history_persistence_max_qps
  temporal_matching_persistence_max_qps                = var.temporal_matching_persistence_max_qps
  temporal_worker_persistence_max_qps                  = var.temporal_worker_persistence_max_qps
  temporal_system_visibility_persistence_max_read_qps  = var.temporal_system_visibility_persistence_max_read_qps
  temporal_system_visibility_persistence_max_write_qps = var.temporal_system_visibility_persistence_max_write_qps


  #======================================================
  # Datadog specs
  #======================================================
  web_dd_env_vars = var.datadog_agent_enabled ? {
    DD_TRACE_DISABLED_PLUGINS = "dns"
  } : {}
  datawatch_dd_env_vars = var.datadog_agent_enabled ? {
    DD_TRACE_DISABLED_PLUGINS        = "dns"
    DD_LOGS_INJECTION                = "true"
    DD_TRACE_SAMPLE_RATE             = "1.0"
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

  elb_access_logs_prefix = var.elb_access_logs_prefix == "" ? local.name : format("%s/%s", var.elb_access_logs_prefix, local.name)
}
