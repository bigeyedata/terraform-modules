module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v7.0.1"
  environment = "test"
  instance    = "bigeye"

  # This is domain name of the domain that you have already set up in route53.  This terraform will create DNS entries
  # in that domain for the application.
  top_level_dns_name = "example.com"

  # vanity_alias will drive all of the DNS entries that this terraform creates.  ie bigeye.example.com for the UI/API to access Bigeye
  vanity_alias = "bigeye"

  # Default is 10.1.0.0/16, but any /16 can be passed in as seen in this example
  # This terraform requires a /16 as it will create several /24 subnets (1 per AZ for ECS, DB subnets, etc).  To use something
  # different than a /16 subnet, see the self-managed-vpc example where you create your own VPC And subnets and pass them in as parameters.
  vpc_cidr_block = "10.252.0.0/16"

  # This is Bigeye's ECR registry.  Setting this to Bigeye's registry is simple as a hello world example, but it is recommended
  # for enterprise customers to cache our images in you own ECR repo.  See the self-managed-ecr example
  image_registry = "021451147547.dkr.ecr.us-west-2.amazonaws.com"

  # Bigeye app version.  You can list the tags available in the image_registry (using the latest is always recommended).
  image_tag = "1.34.0"
}

# This can be useful for debugging to print outputs.  Secrets will remain safe (ie passwords and such do not get printed)
output "bigeye" {
  value = module.bigeye
}
