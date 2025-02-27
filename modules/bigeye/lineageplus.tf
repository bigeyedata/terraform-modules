module "lineageplus_solr" {
  count             = var.lineageplus_enabled && length(var.lineageplus_solr_image_tag) > 0 ? 1 : 0
  source            = "../solr-single-instance"
  subnet_id         = local.application_subnet_ids[0]
  lb_subnet_ids     = local.public_alb_subnet_ids
  instance          = local.name
  name              = "solr"
  vpc_id            = local.vpc_id
  ecs_cluster_name  = aws_ecs_cluster.this.name
  availability_zone = local.vpc_availability_zones[0]
  instance_type     = var.lineageplus_solr_instance_type

  acm_certificate_arn = local.acm_certificate_arn
  dns_name            = var.create_dns_records ? local.lineageplus_solr_dns_name : ""
  route53_zone_id     = var.create_dns_records ? data.aws_route53_zone.this[0].id : ""

  lb_access_logs_enabled       = var.elb_access_logs_enabled
  lb_access_logs_bucket_name   = var.elb_access_logs_bucket
  lb_access_logs_bucket_prefix = local.elb_access_logs_prefix

  service_discovery_private_dns_namespace_id = aws_service_discovery_private_dns_namespace.this.id
  refresh_instance_on_launch_template_change = true

  image_registry        = local.image_registry
  image_repository      = "solr${var.lineageplus_solr_image_repository_suffix}"
  image_tag             = var.lineageplus_solr_image_tag
  solr_opts             = var.lineageplus_solr_opts
  desired_count         = var.lineageplus_solr_desired_count
  solr_heap_size        = var.lineageplus_solr_heap_size
  ebs_volume_size       = var.lineageplus_solr_ebs_volume_size
  ebs_volume_iops       = var.lineageplus_solr_ebs_volume_iops
  ebs_volume_throughput = var.lineageplus_solr_ebs_volume_throughput
}
