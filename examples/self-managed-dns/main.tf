locals {
  environment         = "test"
  instance            = "dns"
  top_level_dns_name  = "example.com"
  acm_certificate_arn = "arn:aws:acm:YOUR_REGION:YOUR_ACCOUNT:certificate/YOUR_CERT_ID"
}

module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v23.1.0"
  environment = local.environment
  instance    = local.instance

  top_level_dns_name  = local.top_level_dns_name
  create_dns_records  = false
  acm_certificate_arn = local.acm_certificate_arn

  # This is Bigeye's ECR registry.  Setting this to Bigeye's registry is simple as a hello world example, but it is recommended
  # for enterprise customers to cache our images in you own ECR repo.  See the self-managed-ecr example
  image_registry = "021451147547.dkr.ecr.us-west-2.amazonaws.com"

  # Bigeye app version.  You can list the tags available in the image_registry (using the latest is always recommended).
  image_tag = "2.34.0"
}

output "bigeye" {
  value = module.bigeye
}

