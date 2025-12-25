#======================================================
# Frontend Service
#
# The temporal frontend service is responsible for
# receiving external requests and processing them
# in the cluster
#======================================================
resource "aws_lb" "temporal" {
  name                             = "${local.name}-temporal"
  internal                         = var.temporal_internet_facing ? false : true
  load_balancer_type               = "network"
  subnets                          = var.temporal_internet_facing ? local.public_alb_subnet_ids : local.internal_service_alb_subnet_ids
  enable_cross_zone_load_balancing = true
  security_groups                  = concat(aws_security_group.temporal_lb[*].id, var.external_additional_security_group_ids, [module.bigeye_admin.client_security_group_id])
  tags                             = merge(local.tags, { app = "temporal", component = "frontend" })

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
  deregistration_delay = 120
  tags                 = merge(local.tags, { app = "temporal", component = "frontend" })

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

resource "aws_ecs_service" "temporal" {
  depends_on                    = [aws_lb.temporal]
  name                          = "${local.name}-temporal"
  cluster                       = aws_ecs_cluster.this.id
  task_definition               = aws_ecs_task_definition.temporal_components["frontend"].arn
  desired_count                 = local.temporal_component_desired_count["frontend"]
  availability_zone_rebalancing = "ENABLED"

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = var.spot_instance_config.on_demand_weight
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = var.spot_instance_config.spot_weight
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
    container_name   = "${local.name}-temporal-frontend"
    container_port   = 7233
    target_group_arn = aws_lb_target_group.temporal.arn
  }

  platform_version = var.fargate_version

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  propagate_tags = "SERVICE"

  tags = merge(local.tags, { app = "temporal", component = "frontend" })

  # force_new_deployment is required to avoid ECS service replacement when changing spot base/weight
  force_new_deployment = true
}
#======================================================
# Temporal Components
#
# These components work together in the temporal cluster.
# More can be seen here:
# https://docs.temporal.io/clusters
#======================================================
locals {
  temporal_services        = ["history", "matching", "worker", "internal-frontend", "frontend"]
  non_lb_temporal_services = ["history", "matching", "worker", "internal-frontend"]
}

resource "aws_ecs_task_definition" "temporal_components" {
  for_each                 = toset(local.temporal_services)
  family                   = "${local.name}-temporal-${local.temporal_svc_override_names[each.key]}"
  cpu                      = local.temporal_component_cpu[each.key]
  memory                   = local.temporal_component_memory[each.key]
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  tags                     = merge(local.tags, { app = "temporal", component = each.key })
  execution_role_arn       = local.ecs_role_arn
  container_definitions = jsonencode(concat(
    [local.temporal_component_container_def[each.key]],
    var.datadog_agent_enabled ? [local.temporal_component_datadog_container_def[each.key]] : [],
    var.awsfirelens_enabled && var.temporal_logging_enabled ? [local.temporal_component_awsfirelens_container_def[each.key]] : [],
  ))
  dynamic "volume" {
    for_each = contains(var.efs_volume_enabled_services, "temporal-${local.temporal_svc_override_names[each.key]}") ? ["temporal-${local.temporal_svc_override_names[each.key]}"] : []
    content {
      name = "${local.name}-${each.value}"
      efs_volume_configuration {
        file_system_id     = aws_efs_file_system.this[each.value].id
        transit_encryption = "ENABLED"
        authorization_config {
          access_point_id = aws_efs_access_point.this[each.value].id
          iam             = "ENABLED"
        }
      }
    }
  }
}

resource "aws_ecs_service" "temporal_components" {
  for_each = toset(local.non_lb_temporal_services)

  name                          = "${local.name}-temporal-${local.temporal_svc_override_names[each.key]}"
  cluster                       = aws_ecs_cluster.this.id
  task_definition               = aws_ecs_task_definition.temporal_components[each.key].arn
  desired_count                 = local.temporal_component_desired_count[each.key]
  availability_zone_rebalancing = "ENABLED"

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = var.spot_instance_config.on_demand_weight
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = var.spot_instance_config.spot_weight
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

  platform_version = var.fargate_version

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  propagate_tags = "SERVICE"

  tags = merge(local.tags, { app = "temporal", component = each.key })

  # force_new_deployment is required to avoid ECS service replacement when changing spot base/weight
  force_new_deployment = true
}



#======================================================
# Security Groups
#======================================================
resource "aws_security_group" "temporal_lb" {
  count       = var.create_security_groups ? 1 : 0
  name        = "${local.name}-temporal-lb"
  description = "Allows traffic to the temporal load balancer"
  vpc_id      = local.vpc_id
  tags = merge(local.tags, {
    Name = "${local.name}-temporal-lb"
  })

  ingress {
    description = "Traffic port open from external"
    from_port   = local.temporal_lb_port
    to_port     = local.temporal_lb_port
    protocol    = "TCP"
    cidr_blocks = concat(var.external_ingress_cidrs, var.temporal_internet_facing ? local.nat_cidrs : [var.vpc_cidr_block])
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

  # TODO split this out into their own resources
  dynamic "ingress" {
    for_each = toset(var.internal_additional_ingress_cidrs)

    content {
      from_port   = 9091
      to_port     = 9091
      protocol    = "TCP"
      description = "Allows metrics port 9091 from cidr - ${ingress.key}"
      cidr_blocks = [ingress.key]
    }
  }

  # TODO split this out into their own resources
  dynamic "ingress" {
    for_each = toset(var.internal_additional_ingress_cidrs)

    content {
      from_port   = 7233
      to_port     = 7233
      protocol    = "TCP"
      description = "Allows port 7233 from cidr - ${ingress.key}"
      cidr_blocks = [ingress.key]
    }
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
# Temporal Local Config
#======================================================
locals {
  temporal_svc_override_names = merge(
    { for e in toset(local.temporal_services) : e => e },
    {
      "internal-frontend" = "intra"
    }
  )
  temporal_component_desired_count = {
    history             = coalesce(var.temporal_history_desired_count, var.temporal_desired_count)
    matching            = coalesce(var.temporal_matching_desired_count, var.temporal_desired_count)
    worker              = coalesce(var.temporal_worker_desired_count, var.temporal_desired_count)
    "internal-frontend" = coalesce(var.temporal_internal_frontend_desired_count, var.temporal_desired_count)
    frontend            = coalesce(var.temporal_frontend_desired_count, var.temporal_desired_count)
  }
  temporal_component_cpu = {
    history             = coalesce(var.temporal_history_cpu, var.temporal_cpu)
    matching            = coalesce(var.temporal_matching_cpu, var.temporal_cpu)
    worker              = coalesce(var.temporal_worker_cpu, var.temporal_cpu)
    "internal-frontend" = coalesce(var.temporal_internal_frontend_cpu, var.temporal_cpu)
    frontend            = coalesce(var.temporal_frontend_cpu, var.temporal_cpu)
  }
  temporal_component_memory = {
    history             = coalesce(var.temporal_history_memory, var.temporal_memory)
    matching            = coalesce(var.temporal_matching_memory, var.temporal_memory)
    worker              = coalesce(var.temporal_worker_memory, var.temporal_memory)
    "internal-frontend" = coalesce(var.temporal_internal_frontend_memory, var.temporal_memory)
    frontend            = coalesce(var.temporal_frontend_memory, var.temporal_memory)
  }

  temporal_docker_labels_general = var.datadog_agent_enabled ? {
    "com.datadoghq.tags.env"      = local.name
    "com.datadoghq.tags.instance" = var.instance
    "com.datadoghq.tags.stack"    = local.name
  } : {}

  temporal_visibility_env_vars = var.temporal_opensearch_enabled ? {
    ENABLE_ES  = "true"
    ES_VERSION = "v7"
    ES_SCHEME  = "https"
    ES_SEEDS   = module.temporal_opensearch[0].dns_name
    ES_PORT    = "443"
    ES_USER    = "temporal"
  } : {}

  temporal_environment_variables_general = merge(
    local.temporal_dd_env_vars,
    {
      ENVIRONMENT = var.environment
      INSTANCE    = var.instance
      DB          = "mysql8"
      DB_PORT     = "3306"
      DBNAME      = "temporal"
      MYSQL_SEEDS = local.temporal_mysql_dns_name
      MYSQL_USER  = "bigeye"

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
    local.temporal_visibility_env_vars,
  )

  temporal_component_common_env_vars = {
    TEMPORAL_CLI_ADDRESS     = "${local.temporal_dns_name}:${local.temporal_lb_port}"
    TEMPORAL_ADDRESS         = "${local.temporal_dns_name}:${local.temporal_lb_port}"
    TEMPORAL_CLI_SHOW_STACKS = "1"
    USE_INTERNAL_FRONTEND    = "true"
  }
  temporal_component_env_vars = {
    "frontend" = merge(
      local.temporal_environment_variables_general,
      {
        SERVICES                                   = "frontend"
        TEMPORAL_AUTH_AUTHORIZER                   = "default"
        TEMPORAL_AUTH_CLAIM_MAPPER                 = "apikey"
        TEMPORAL_TLS_INTERNODE_REQUIRE_CLIENT_AUTH = "true"
        TEMPORAL_TLS_ALLOW_CLIENT_MTLS             = "true"
        TEMPORAL_TLS_REQUIRE_CLIENT_AUTH           = "false"
        TEMPORAL_API_KEY_VERIFICATION_ENDPOINT     = "https://${local.vanity_dns_name}/api/v1/agent-api-keys/verify"
      },
      var.temporal_additional_environment_vars,
      var.temporal_frontend_additional_environment_vars,
    )
    "internal-frontend" = merge(
      local.temporal_environment_variables_general,
      {
        SERVICES = "internal-frontend"
      },
      local.temporal_component_common_env_vars,
      var.temporal_additional_environment_vars,
      var.temporal_internal_frontend_additional_environment_vars,
    )
    "history" = merge(
      local.temporal_environment_variables_general,
      {
        SERVICES = "history"
      },
      local.temporal_component_common_env_vars,
      var.temporal_additional_environment_vars,
      var.temporal_history_additional_environment_vars,
    )
    "matching" = merge(
      local.temporal_environment_variables_general,
      {
        SERVICES = "matching"
      },
      local.temporal_component_common_env_vars,
      var.temporal_additional_environment_vars,
      var.temporal_matching_additional_environment_vars,
    )
    "worker" = merge(
      local.temporal_environment_variables_general,
      {
        SERVICES = "worker"
      },
      local.temporal_component_common_env_vars,
      var.temporal_additional_environment_vars,
      var.temporal_worker_additional_environment_vars,
    )
  }

  temporal_secret_arns = merge(
    {
      "MYSQL_PWD" = local.temporal_rds_password_secret_arn
    },
    var.temporal_opensearch_enabled ? {
      "ES_PWD" = local.temporal_opensearch_password_secret_arn
    } : {},
    var.temporal_additional_secret_arns,
  )

  temporal_component_secret_arns = {
    "frontend" = merge(
      local.temporal_secret_arns,
      {
        TEMPORAL_API_KEY_CONSTANT_KEY = local.robot_agent_apikey_secret_arn
      }
    )
    "internal-frontend" = local.temporal_secret_arns
    "history"           = local.temporal_secret_arns
    "matching"          = local.temporal_secret_arns
    "worker"            = local.temporal_secret_arns
  }

  log_configuration_def = var.temporal_logging_enabled ? var.awsfirelens_enabled ? {
    logDriver = "awsfirelens",
    options = {
      "Name"       = "http"
      "Host"       = var.awsfirelens_host
      "URI"        = var.awsfirelens_uri
      "Port"       = 443
      "tls"        = "on"
      "tls.verify" = "off"
      "format"     = "json_lines"
    } } : {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = aws_cloudwatch_log_group.temporal.name
      "awslogs-region"        = local.aws_region
      "awslogs-stream-prefix" = "${local.name}-temporal"
    }
  } : null

  temporal_container_def_general = {
    image            = format("%s/%s%s:%s", local.image_registry, "temporal", var.image_repository_suffix, var.temporal_image_tag)
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
  temporal_component_container_def = {
    for svc in local.temporal_services : svc => merge(
      local.temporal_container_def_general,
      {
        name   = "${local.name}-temporal-${local.temporal_svc_override_names[svc]}"
        cpu    = local.temporal_component_cpu[svc] - (var.datadog_agent_enabled ? var.datadog_agent_cpu : 0) - (var.awsfirelens_enabled ? var.awsfirelens_cpu : 0)
        memory = local.temporal_component_memory[svc] - (var.datadog_agent_enabled ? var.datadog_agent_memory : 0) - (var.awsfirelens_enabled ? var.awsfirelens_memory : 0)
        dockerLabels = var.datadog_agent_enabled ? merge(
          local.temporal_docker_labels_general,
          {
            "com.datadoghq.tags.app"       = "temporal"
            "com.datadoghq.tags.component" = svc
            "com.datadoghq.tags.service"   = "temporal-${local.temporal_svc_override_names[svc]}"
          }
        ) : {}
        secrets     = [for k, v in local.temporal_component_secret_arns[svc] : { Name = k, ValueFrom = v }]
        environment = [for k, v in local.temporal_component_env_vars[svc] : { Name = k, Value = v }]
        mountPoints = contains(var.efs_volume_enabled_services, "temporal-${local.temporal_svc_override_names[svc]}") ? [{
          containerPath : var.efs_mount_point,
          sourceVolume : "temporal-${local.temporal_svc_override_names[svc]}",
        }] : []
      }
    )
  }
}


#======================================================
# Temporal Datadog Container Defs
#======================================================
locals {
  temporal_datadog_secret_arns = {
    DD_API_KEY = var.datadog_agent_api_key_secret_arn
  }
  temporal_datadog_environment_variables = {
    DD_APM_ENABLED                 = "true"
    DD_DOGSTATSD_NON_LOCAL_TRAFFIC = "true"
    DD_DOGSTATSD_TAG_CARDINALITY   = "orchestrator"
    ECS_FARGATE                    = "true"
  }

  temporal_datadog_docker_labels_generic = {
    "com.datadoghq.ad.check_names" : "[\"temporal\"]",
    "com.datadoghq.ad.init_configs" : "[{}]",
    "com.datadoghq.tags.env" : local.name
    "com.datadoghq.tags.instance" : var.instance
    "com.datadoghq.tags.stack" : local.name
  }
  temporal_datadog_container_def_generic = {
    name           = "datadog-agent"
    image          = var.datadog_agent_image
    cpu            = var.datadog_agent_cpu
    memory         = var.datadog_agent_memory
    essential      = true
    mountPoints    = []
    volumesFrom    = []
    systemControls = []
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

  temporal_component_datadog_container_def = {
    for svc in local.temporal_services : svc => merge(
      local.temporal_datadog_container_def_generic,
      {
        dockerLabels = merge(local.temporal_datadog_docker_labels_generic, {
          "com.datadoghq.ad.instances" : "[\n    {\n      \"openmetrics_endpoint\": \"http://localhost:9091/metrics\",\n      \"extra_metrics\": [\n        \"approximate_backlog_count\"\n,        \"approximate_backlog_age_seconds\"\n      ],\n      \"collect_histogram_buckets\": true,\n      \"histogram_buckets_as_distributions\": true,\n      \"collect_counters_with_distributions\": true,\n      \"tags\": [\n        \"app:temporal\"\n,        \"component:${svc}\",\n        \"instance:${var.instance}\",\n        \"stack:${local.name}\"\n      ]\n    }\n  ]\n",
          "com.datadog.tags.app" : "temporal"
          "com.datadog.tags.component" : local.temporal_svc_override_names[svc]
          "com.datadog.tags.service" : "temporal-${local.temporal_svc_override_names[svc]}"
        })
      }
    )
  }
}

#======================================================
# Temporal Awsfirelens Container Defs
#======================================================

locals {
  temporal_awsfirelens_container_def_generic = {
    name           = "awsfirelens-log-router"
    image          = var.awsfirelens_image
    cpu            = var.awsfirelens_cpu
    memory         = var.awsfirelens_memory
    essential      = true
    mountPoints    = []
    volumesFrom    = []
    systemControls = []
    portMappings   = []
    firelensConfiguration = {
      type = "fluentbit",
      options = {
        "enable-ecs-log-metadata" : "true"
      }
    }
    logConfiguration = {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group"         = aws_cloudwatch_log_group.temporal.name
        "awslogs-region"        = local.aws_region
        "awslogs-stream-prefix" = "${local.name}-temporal"
      }
    }
    environment = []
    user        = "0"
  }

  temporal_component_awsfirelens_container_def = {
    for svc in local.temporal_services : svc => merge(
      local.temporal_awsfirelens_container_def_generic,
      {
        dockerLabels = var.awsfirelens_enabled ? merge(
          local.temporal_docker_labels_general,
          {
            "com.datadoghq.tags.app"       = "temporal"
            "com.datadoghq.tags.component" = local.temporal_svc_override_names[svc]
            "com.datadoghq.tags.service"   = "temporal-${local.temporal_svc_override_names[svc]}"
        }) : {}
      }
    )
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
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
  additional_security_group_ids = concat(var.temporalui_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
  traffic_port                  = var.temporalui_port
  ecs_cluster_id                = aws_ecs_cluster.this.id
  fargate_version               = var.fargate_version

  # Load balancer
  centralized_lb_arn                     = aws_lb.internal_alb.arn
  centralized_lb_security_group_ids      = local.internal_alb_security_group_ids
  centralized_lb_https_listener_rule_arn = aws_lb_listener.https_internal.arn
  healthcheck_path                       = "/"
  healthcheck_interval                   = 15
  healthcheck_unhealthy_threshold        = 3
  lb_deregistration_delay                = 30

  # Task settings
  desired_count             = var.temporalui_desired_count
  spot_instance_config      = var.spot_instance_config
  cpu                       = var.temporalui_cpu
  memory                    = var.temporalui_memory
  execution_role_arn        = local.ecs_role_arn
  task_role_arn             = null
  image_registry            = local.image_registry
  image_repository          = format("%s%s", "temporalui", var.image_repository_suffix)
  image_tag                 = var.temporalui_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.temporal.name
  efs_volume_id             = contains(var.efs_volume_enabled_services, "temporalui") ? aws_efs_file_system.this[0].id : ""
  efs_access_point_id       = contains(var.efs_volume_enabled_services, "temporalui") ? aws_efs_access_point.this["temporalui"].id : ""
  efs_mount_point           = var.efs_mount_point

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

  # aws firelens
  awsfirelens_cpu     = var.awsfirelens_cpu
  awsfirelens_memory  = var.awsfirelens_memory
  awsfirelens_enabled = var.awsfirelens_enabled
  awsfirelens_host    = var.awsfirelens_host
  awsfirelens_image   = var.awsfirelens_image
  awsfirelens_uri     = var.awsfirelens_uri

  create_dns_records = var.create_dns_records
  route53_zone_id    = data.aws_route53_zone.this[0].zone_id
  dns_name           = "${local.base_dns_alias}-workflows-admin.${var.top_level_dns_name}"
}

#======================================================
# Temporal-Elasticsearch
#======================================================
resource "random_password" "temporal_opensearch_password" {
  count       = local.create_temporal_opensearch_password_secret ? 1 : 0
  length      = 16
  special     = true
  upper       = true
  lower       = true
  numeric     = true
  min_special = 1
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1

}

resource "aws_secretsmanager_secret" "temporal_opensearch_password" {
  count                   = local.create_temporal_opensearch_password_secret ? 1 : 0
  name                    = format("bigeye/%s/bigeye/temporal/opensearch-password", local.name)
  recovery_window_in_days = local.secret_retention_days
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "temporal_opensearch_password" {
  count          = local.create_temporal_opensearch_password_secret ? 1 : 0
  secret_id      = aws_secretsmanager_secret.temporal_opensearch_password[0].id
  secret_string  = random_password.temporal_opensearch_password[0].result
  version_stages = ["AWSCURRENT"]
}

data "aws_secretsmanager_secret_version" "byo_temporal_opensearch_password" {
  count         = local.temporal_opensearch_password_byo_secret ? 1 : 0
  secret_id     = var.temporal_opensearch_master_user_password_secret_arn
  version_stage = "AWSCURRENT"
}

module "temporal_opensearch" {
  count  = var.temporal_opensearch_enabled ? 1 : 0
  source = "../opensearch"

  name                   = local.name
  vpc_id                 = local.vpc_id
  tags                   = local.tags
  create_security_groups = var.create_security_groups
  ingress_security_group_ids = var.create_security_groups ? [
    aws_security_group.temporal[0].id,
    module.backfillwork.security_group_id,
    module.datawatch.security_group_id,
    module.datawork.security_group_id,
    module.indexwork.security_group_id,
    module.internalapi.security_group_id,
    module.lineageapi.security_group_id,
    module.lineagework.security_group_id,
    module.metricwork.security_group_id,
    module.rootcause.security_group_id,
  ] : []
  extra_security_group_ids  = var.temporal_opensearch_extra_security_group_ids
  additional_ingress_cidrs  = var.internal_additional_ingress_cidrs
  engine_version            = var.temporal_opensearch_engine_version
  instance_type             = var.temporal_opensearch_instance_type
  instance_count            = var.redundant_infrastructure ? 3 : 1
  subnet_ids                = local.rabbitmq_subnet_group_ids
  master_user_password      = local.create_temporal_opensearch_password_secret ? aws_secretsmanager_secret_version.temporal_opensearch_password[0].secret_string : data.aws_secretsmanager_secret_version.byo_temporal_opensearch_password[0].secret_string
  master_nodes_enabled      = var.redundant_infrastructure ? true : false
  master_node_instance_type = var.temporal_opensearch_master_instance_type
}
