#==============================================
# Containers, lots of boilerplate here
#==============================================
locals {
  container_cpu    = var.cpu - (var.datadog_agent_enabled ? var.datadog_agent_cpu : 0) - (var.awsfirelens_enabled ? var.awsfirelens_cpu : 0)
  container_memory = var.memory - (var.datadog_agent_enabled ? var.datadog_agent_memory : 0) - (var.awsfirelens_enabled ? var.awsfirelens_memory : 0)
  container_image  = "${var.image_registry}/${var.image_repository}:${var.image_tag}"

  container_environment_variables = [for k, v in merge(local.datadog_service_environment_variables, var.environment_variables) : { Name = k, Value = v }]
  container_environment_secrets   = [for k, v in merge(local.datadog_service_secret_arns, var.secret_arns) : { Name = k, ValueFrom = v }]

  primary_container_definition = {
    name   = var.name,
    cpu    = local.container_cpu
    memory = local.container_memory
    image  = local.container_image
    portMappings = [{
      containerPort = var.traffic_port
      hostPort      = var.traffic_port
      protocol      = "tcp"
    }]
    essential = true
    mountPoints = local.efs_volume_enabled ? [
      {
        containerPath : var.efs_mount_point,
        sourceVolume : var.name,
      }
    ] : []
    volumesFrom  = []
    dockerLabels = merge(local.datadog_docker_labels, var.docker_labels)
    environment  = local.container_environment_variables
    secrets      = local.container_environment_secrets
    stopTimeout  = var.stop_timeout
    logConfiguration = var.awsfirelens_enabled ? {
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
        "awslogs-group"         = var.cloudwatch_log_group_name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = var.name
      }
    }
  }

  datadog_agent_environment_vars = {
    ECS_FARGATE                    = "true"
    DD_DOGSTATSD_TAG_CARDINALITY   = "orchestrator"
    DD_APM_ENABLED                 = "true"
    DD_DOGSTATSD_NON_LOCAL_TRAFFIC = "true"
  }

  datadog_docker_labels = var.datadog_agent_enabled ? merge(
    var.datadog_additional_docker_labels,
    {
      "com.datadoghq.tags.app"      = var.app
      "com.datadoghq.tags.env"      = var.stack
      "com.datadoghq.tags.instance" = var.instance
      "com.datadoghq.tags.service"  = var.app
      "com.datadoghq.tags.stack"    = var.stack
    },
  ) : {}
  datadog_service_environment_variables = var.datadog_agent_enabled ? {
    DATADOG_ENABLED = "true"
    DD_SERVICE      = var.app
    DD_TAGS         = "app:${var.app} instance:${var.instance} stack:${var.stack}"
    DD_ENV          = var.stack
    } : {
    DATADOG_ENABLED = "false"
  }

  datadog_service_secret_arns = var.datadog_agent_enabled ? merge(
    {
      DD_API_KEY = var.datadog_agent_api_key_secret_arn
    },
    var.datadog_agent_additional_secret_arns
  ) : {}

  datadog_agent_container_definition = {
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
    environment = [for k, v in local.datadog_agent_environment_vars : { name = k, value = v }]
    secrets     = [for k, v in local.datadog_service_secret_arns : { Name = k, ValueFrom = v }]
  }

  awsfirelens_container_definition = {
    name         = "awsfirelens-log-router"
    image        = var.awsfirelens_image
    cpu          = var.awsfirelens_cpu
    memory       = var.awsfirelens_memory
    essential    = true
    mountPoints  = []
    volumesFrom  = []
    portMappings = []
    firelensConfiguration = {
      type = "fluentbit",
      options = {
        "enable-ecs-log-metadata" : "true"
      }
    }
    logConfiguration = {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group"         = var.cloudwatch_log_group_name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = var.name
      }
    }
    environment = []
    user        = "0"
  }

  container_definitions = concat(
    [local.primary_container_definition],
    var.datadog_agent_enabled ? [local.datadog_agent_container_definition] : [],
    var.awsfirelens_enabled ? [local.awsfirelens_container_definition] : [],
  )
}

data "aws_region" "current" {}
