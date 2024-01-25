locals {
  environment         = "test"
  instance            = "dns"
  top_level_dns_name  = "example.com"
  acm_certificate_arn = "arn:aws:acm:YOUR_REGION:YOUR_ACCOUNT:certificate/YOUR_CERT_ID"
}

module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v1.12.0"
  environment = local.environment
  instance    = local.instance

  top_level_dns_name  = local.top_level_dns_name
  create_dns_records  = false
  acm_certificate_arn = local.acm_certificate_arn

  image_tag = "1.35.0"
}

output "bigeye" {
  value = module.bigeye
}

