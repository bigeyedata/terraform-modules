module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v8.0.0"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  # This is Bigeye's ECR registry.  Setting this to Bigeye's registry is simple as a hello world example, but it is recommended
  # for enterprise customers to cache our images in you own ECR repo.  See the self-managed-ecr example
  image_registry = "021451147547.dkr.ecr.us-west-2.amazonaws.com"

  # Bigeye app version.  You can list the tags available in the image_registry (using the latest is always recommended).
  image_tag = "1.34.0"

  # BYOVPC
  byovpc_vpc_id                     = "vpc-XXXXXXXXXXX"
  byovpc_rabbitmq_subnet_ids        = ["subnet-01****", "subnet-02****", "subnet-03****"]
  byovpc_internal_subnet_ids        = ["subnet-11****", "subnet-12****", "subnet-13****"]
  byovpc_application_subnet_ids     = ["subnet-21****", "subnet-22****", "subnet-23****"]
  byovpc_public_subnet_ids          = ["subnet-31****", "subnet-32****", "subnet-33****"]
  byovpc_redis_subnet_group_name    = "existing-redis-subnet-group-name"
  byovpc_database_subnet_group_name = "existing-rds-subnet-group-name"
}

