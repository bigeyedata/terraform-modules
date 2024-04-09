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
  security_groups                  = concat(aws_security_group.temporal_lb[*].id, var.temporal_lb_extra_security_group_ids, [module.bigeye_admin.client_security_group_id])
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
  deregistration_delay = 300
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
  depends_on      = [aws_lb.temporal]
  name            = "${local.name}-temporal"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.temporal_components["frontend"].arn
  desired_count   = local.temporal_component_desired_count["frontend"]

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
    container_name   = "${local.name}-temporal-frontend"
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

  tags = merge(local.tags, { app = "temporal", component = "frontend" })
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
  execution_role_arn       = aws_iam_role.ecs.arn
  container_definitions    = var.datadog_agent_enabled ? jsonencode([local.temporal_component_container_def[each.key], local.temporal_component_datadog_container_def[each.key]]) : jsonencode([local.temporal_component_container_def[each.key]])
}

resource "aws_ecs_service" "temporal_components" {
  for_each = toset(local.non_lb_temporal_services)

  name            = "${local.name}-temporal-${local.temporal_svc_override_names[each.key]}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.temporal_components[each.key].arn
  desired_count   = local.temporal_component_desired_count[each.key]

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

  platform_version = "1.4.0"

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  propagate_tags = "SERVICE"

  tags = merge(local.tags, { app = "temporal", component = each.key })
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
    description = "Traffic port open to anywhere"
    from_port   = local.temporal_lb_port
    to_port     = local.temporal_lb_port
    protocol    = "TCP"
    cidr_blocks = var.temporal_internet_facing ? ["0.0.0.0/0"] : concat([var.vpc_cidr_block], var.additional_ingress_cidrs)
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

  temporal_environment_variables_general = merge(
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

  temporal_container_def_general = {
    image            = format("%s/%s%s:%s", local.image_registry, "temporal", var.image_repository_suffix, local.temporal_image_tag)
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
  temporal_component_container_def = {
    for svc in local.temporal_services : svc => merge(
      local.temporal_container_def_general,
      {
        name   = "${local.name}-temporal-${local.temporal_svc_override_names[svc]}"
        cpu    = var.datadog_agent_enabled ? local.temporal_component_cpu[svc] - var.datadog_agent_cpu : local.temporal_component_cpu[svc]
        memory = var.datadog_agent_enabled ? local.temporal_component_memory[svc] - var.datadog_agent_memory : local.temporal_component_memory[svc]
        dockerLabels = var.datadog_agent_enabled ? merge(
          local.temporal_docker_labels_general,
          {
            "com.datadoghq.tags.app"       = "temporal"
            "com.datadoghq.tags.component" = svc
            "com.datadoghq.tags.service"   = "temporal-${local.temporal_svc_override_names[svc]}"
          }
        ) : {}
        environment = [for k, v in local.temporal_component_env_vars[svc] : { Name = k, Value = v }]
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
    name        = "datadog-agent"
    image       = var.datadog_agent_image
    cpu         = var.datadog_agent_cpu
    memory      = var.datadog_agent_memory
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

  temporal_component_datadog_container_def = {
    for svc in local.temporal_services : svc => merge(
      local.temporal_datadog_container_def_generic,
      {
        dockerLabels = merge(local.temporal_datadog_docker_labels_generic, {
          "com.datadoghq.ad.instances" : "[\n    {\n      \"openmetrics_endpoint\": \"http://localhost:9091/metrics\",\n      \"collect_histogram_buckets\": true,\n      \"histogram_buckets_as_distributions\": true,\n      \"collect_counters_with_distributions\": true,\n      \"tags\": [\n        \"app:temporal\"\n,        \"component:${svc}\",\n        \"instance:${var.instance}\",\n        \"stack:${local.name}\"\n      ]\n    }\n  ]\n",
          "com.datadog.tags.app" : "temporal"
          "com.datadog.tags.component" : local.temporal_svc_override_names[svc]
          "com.datadog.tags.service" : "temporal-${local.temporal_svc_override_names[svc]}"
        })
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
  vpc_cidr_block                = var.vpc_cidr_block
  subnet_ids                    = local.application_subnet_ids
  create_security_groups        = var.create_security_groups
  task_additional_ingress_cidrs = var.internal_additional_ingress_cidrs
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
  lb_additional_ingress_cidrs      = var.internal_additional_ingress_cidrs
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

