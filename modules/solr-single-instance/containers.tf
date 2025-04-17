#==============================================
# Containers, lots of boilerplate here
#==============================================
locals {
  # 1024 was arrived at through experimentation on a m5.xlarge EC2 instance.  768 would not allow a task to start due to no ECS task being large enough
  # note on mem increments
  #   - 16cpu ECS mem must increment in 8GB increments.
  #   - 8cpu ECS mem must increment in 4GB increments
  #   - 4cpu and below, mem must increment in 1GB increments
  # We use this when subtracting an overhead amount from the host OS to arrive at the ECS task mem.
  os_mem_overhead = (
    data.aws_ec2_instance_type.this.default_vcpus >= 16 ? 8 * 1024 : (
    data.aws_ec2_instance_type.this.default_vcpus >= 8 ? 4 * 1024 : 4 * 1024)
  )
  ec2_mem_usable   = data.aws_ec2_instance_type.this.memory_size - local.os_mem_overhead
  container_memory = local.ec2_mem_usable - (var.datadog_agent_enabled ? var.datadog_agent_memory : 0) - (var.awsfirelens_enabled ? var.awsfirelens_memory : 0)
  # default = 80% of container mem to leave headroom for OS etc.
  solr_heap_size = length(var.solr_heap_size) > 0 ? var.solr_heap_size : ceil(local.container_memory * 0.8)

  ec2_cpu_units = data.aws_ec2_instance_type.this.default_vcpus * 1024
  container_cpu = local.ec2_cpu_units - (var.datadog_agent_enabled ? var.datadog_agent_cpu : 0) - (var.awsfirelens_enabled ? var.awsfirelens_cpu : 0)

  container_image = "${var.image_registry}/${var.image_repository}:${var.image_tag}"
  container_environment_variables = [for k, v in merge(local.datadog_service_environment_variables,
    {
      SOLR_HOME      = "/var/solr/configs"
      SOLR_DATA_HOME = "/var/solr/data"
      SOLR_HEAP      = "${local.solr_heap_size}M"
      SOLR_PORT      = tostring(var.solr_traffic_port)
      SOLR_OPTS      = join(" ", concat(local.solr_default_opts, var.solr_opts))
  }) : { Name = k, Value = v }]
  container_environment_secrets = [for k, v in merge(local.datadog_service_secret_arns, var.secret_arns) : { Name = k, ValueFrom = v }]

  primary_container_definition = {
    name   = var.name
    cpu    = local.container_cpu
    memory = local.container_memory
    image  = local.container_image
    portMappings = [{
      containerPort = var.solr_traffic_port
      hostPort      = var.solr_traffic_port
      protocol      = "tcp"
      }, var.datadog_agent_enabled ? {
      containerPort = var.solr_jmx_port
      hostPort      = var.solr_jmx_port
      protocol      = "tcp"
    } : null]
    essential = true
    mountPoints = [
      {
        sourceVolume  = "${var.name}-data"
        containerPath = "/var/solr/data"
        readOnly      = false
      }
    ]
    ulimits = [ # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-resource-limits
      {
        name      = "nofile"
        softLimit = 1048576
        hardLimit = 1048576
      }
    ]
    dockerLabels = merge(local.datadog_docker_labels, var.docker_labels)
    environment  = local.container_environment_variables
    secrets      = local.container_environment_secrets
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
      "com.datadoghq.tags.app"       = var.app
      "com.datadoghq.tags.component" = "solr"
      "com.datadoghq.tags.env"       = var.stack
      "com.datadoghq.tags.instance"  = var.instance
      "com.datadoghq.tags.service"   = var.app
      "com.datadoghq.tags.stack"     = var.stack
    },
  ) : {}
  datadog_service_environment_variables = var.datadog_agent_enabled ? {
    DATADOG_ENABLED = "true"
    DD_SERVICE      = var.app
    DD_TAGS         = "app:${var.app} component:solr instance:${var.instance} stack:${var.stack}"
    DD_ENV          = var.stack
    } : {
    DATADOG_ENABLED = "false"
  }

  datadog_jmx_docker_labels = {
    "com.datadoghq.ad.check_names"  = "[\"solr\"]"
    "com.datadoghq.ad.init_configs" = "[{\"service\": \"lineageplus-solr\",\"is_jmx\": true,\"collect_default_metrics\": true,\"new_gc_metrics\": true}]"
    "com.datadoghq.ad.instances"    = "[{\"host\":\"%%host%%\",\"port\": ${var.solr_jmx_port},\"max_returned_metrics\": 15000,\"collect_default_jvm_metrics\": true,\"tags\": [\"app:${var.app}\",\"component:solr\",\"instance:${var.instance}\",\"stack:${var.stack}\"]}]"
  }

  datadog_service_secret_arns = var.datadog_agent_enabled ? merge(
    {
      DD_API_KEY = var.datadog_agent_api_key_secret_arn
    },
    var.datadog_agent_additional_secret_arns
  ) : {}

  datadog_agent_container_definition = {
    name        = "datadog-agent"
    image       = "${var.datadog_agent_image}-jmx"
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
    # Can be uncommented to get debugging logs on console for this container
    # logConfiguration = {
    #   "logDriver" : "awslogs",
    #   "options" : {
    #     "awslogs-group"         = var.cloudwatch_log_group_name
    #     "awslogs-region"        = data.aws_region.current.name
    #     "awslogs-stream-prefix" = "${var.name}-datadog"
    #   }
    # }
    dockerLabels = merge(local.datadog_docker_labels, local.datadog_jmx_docker_labels, var.docker_labels)
    environment  = [for k, v in local.datadog_agent_environment_vars : { name = k, value = v }]
    secrets      = [for k, v in local.datadog_service_secret_arns : { Name = k, ValueFrom = v }]
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
    # Can be uncommented to get debugging logs on console for this container
    # logConfiguration = {
    #   "logDriver" : "awslogs",
    #   "options" : {
    #     "awslogs-group"         = var.cloudwatch_log_group_name
    #     "awslogs-region"        = data.aws_region.current.name
    #     "awslogs-stream-prefix" = "${var.name}-firelens"
    #   }
    # }
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
