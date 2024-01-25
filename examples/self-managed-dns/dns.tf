data "aws_route53_zone" "parent" {
  name = local.top_level_dns_name
}

resource "aws_route53_record" "apex" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.haproxy_load_balancer_dns_name]
}

resource "aws_route53_record" "datawatch" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.datawatch_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.datawatch_load_balancer_dns_name]
}

resource "aws_route53_record" "datawatch_mysql" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.datawatch_database_vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.datawatch_database_dns_name]
}

resource "aws_route53_record" "datawork" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.datawork_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.datawork_load_balancer_dns_name]
}

resource "aws_route53_record" "metricwork" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.metricwork_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.metricwork_load_balancer_dns_name]
}

resource "aws_route53_record" "monocle" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.monocle_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.monocle_load_balancer_dns_name]
}

resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.web_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.web_load_balancer_dns_name]
}

resource "aws_route53_record" "toretto" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.toretto_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.toretto_load_balancer_dns_name]
}

resource "aws_route53_record" "scheduler" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.scheduler_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.scheduler_load_balancer_dns_name]
}

resource "aws_route53_record" "temporalui" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.temporalui_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.temporalui_load_balancer_dns_name]
}

resource "aws_route53_record" "temporal" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.temporal_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.temporal_load_balancer_dns_name]
}

resource "aws_route53_record" "temporal_mysql" {
  zone_id = data.aws_route53_zone.parent.zone_id
  name    = module.bigeye.temporal_database_vanity_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [module.bigeye.temporal_database_dns_name]
}

