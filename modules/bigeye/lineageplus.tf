module "solr" {
  count             = var.deploy_solr ? 1 : 0
  source            = "../solr-single-instance"
  solr_subnet       = module.vpc[0].private_subnets[0]
  alb_subnets       = module.vpc[0].public_subnets
  env_instance_name = local.name
  service_name      = "solr"
  vpc_id            = module.vpc[0].vpc_id
  ecs_cluster_name  = aws_ecs_cluster.this.name
  availability_zone = module.vpc[0].azs[0]
  instance_type     = var.solr_instance_type

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

