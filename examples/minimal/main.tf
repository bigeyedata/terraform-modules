module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v17.1.3"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  # This is Bigeye's ECR registry.  Setting this to Bigeye's registry is simple as a hello world example, but it is recommended
  # for enterprise customers to cache our images in you own ECR repo.  See the self-managed-ecr example
  image_registry = "021451147547.dkr.ecr.us-west-2.amazonaws.com"

  # Bigeye app version.  You can list the tags available in the image_registry (using the latest is always recommended).
  image_tag = "1.34.0"
}

