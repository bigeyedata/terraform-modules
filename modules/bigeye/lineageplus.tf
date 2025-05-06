module "lineageplus_solr" {
  count         = var.lineageplus_enabled && length(var.lineageplus_solr_image_tag) > 0 ? 1 : 0
  source        = "../solr-single-instance"
  subnet_id     = local.application_subnet_ids[0]
  lb_subnet_ids = local.public_alb_subnet_ids
  app           = "lineageplus"
  instance      = var.instance
  stack         = local.name
  name          = "${local.name}-solr"
  vpc_id        = local.vpc_id
  tags = merge(local.tags,
    { app       = "lineageplus",
      component = "solr"
    }
  )
  ecs_cluster_name  = aws_ecs_cluster.this.name
  availability_zone = local.vpc_availability_zones[0]
  instance_type     = var.lineageplus_solr_instance_type

  acm_certificate_arn = local.acm_certificate_arn
  dns_name            = var.create_dns_records ? local.lineageplus_solr_dns_name : ""
  route53_zone_id     = var.create_dns_records ? data.aws_route53_zone.this[0].id : ""
  solr_cnames         = var.create_dns_records ? var.lineageplus_solr_cnames : []

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = local.elb_access_logs_prefix

  service_discovery_private_dns_namespace_id = aws_service_discovery_private_dns_namespace.this.id
  refresh_instance_on_launch_template_change = var.lineageplus_solr_refresh_instance_on_launch_template_change

  image_registry            = local.image_registry
  image_repository          = "solr${var.lineageplus_solr_image_repository_suffix}"
  image_tag                 = var.lineageplus_solr_image_tag
  cloudwatch_log_group_name = aws_cloudwatch_log_group.bigeye.name
  # Enable the JMX port if datadog is enabled
  solr_opts = concat(var.lineageplus_solr_opts, var.datadog_agent_enabled ? [
    "-Dcom.sun.management.jmxremote.local.only=false",
    "-Dcom.sun.management.jmxremote.ssl=false",
    "-Dcom.sun.management.jmxremote.authenticate=false",
    "-Dcom.sun.management.jmxremote.port=${var.lineageplus_solr_jmx_port}",
    "-Dcom.sun.management.jmxremote.rmi.port=${var.lineageplus_solr_jmx_port}",
  ] : [])
  solr_jmx_port         = var.lineageplus_solr_jmx_port
  desired_count         = var.lineageplus_solr_desired_count
  solr_heap_size        = var.lineageplus_solr_heap_size
  ebs_volume_size       = var.lineageplus_solr_ebs_volume_size
  ebs_volume_iops       = var.lineageplus_solr_ebs_volume_iops
  ebs_volume_throughput = var.lineageplus_solr_ebs_volume_throughput
  ebs_volume_size_os    = var.lineageplus_solr_ebs_volume_size_os
  execution_role_arn    = local.ecs_role_arn

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

  secret_arns = var.datadog_agent_enabled ? {
    DATADOG_API_KEY = var.datadog_agent_api_key_secret_arn
  } : {}
}
