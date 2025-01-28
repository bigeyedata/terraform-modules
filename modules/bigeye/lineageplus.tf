module "solr" {
  count             = var.lineageplus_enabled ? 1 : 0
  source            = "../solr-single-instance"
  subnet_id         = local.application_subnet_ids[0]
  lb_subnet_ids     = local.public_alb_subnet_ids
  env_instance_name = local.name
  service_name      = "solr"
  vpc_id            = local.vpc_id
  ecs_cluster_name  = aws_ecs_cluster.this.name
  availability_zone = local.vpc_availability_zones[0]
  instance_type     = var.lineageplus_solr_instance_type

  acm_certificate_arn = local.acm_certificate_arn
  dns_name            = var.create_dns_records ? local.solr_dns_name : ""
  route53_zone_id     = var.create_dns_records ? data.aws_route53_zone.this[0].id : ""
  elb_access_logs_bucket_config = {
    enabled = var.elb_access_logs_enabled
    bucket  = var.elb_access_logs_bucket
    prefix  = local.elb_access_logs_prefix
  }

  service_discovery_private_dns_namespace_name = aws_service_discovery_private_dns_namespace.this.name
  refresh_instance_on_launch_template_change   = true
}

