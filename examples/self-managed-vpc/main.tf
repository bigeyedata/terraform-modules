module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v1.9.0"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  # Get this from Bigeye Sales
  image_tag = ""

  # BYOVPC
  byovpc_vpc_id                     = "vpc-XXXXXXXXXXX"
  byovpc_rabbitmq_subnet_ids        = ["subnet-01****", "subnet-02****", "subnet-03****"]
  byovpc_internal_subnet_ids        = ["subnet-11****", "subnet-12****", "subnet-13****"]
  byovpc_application_subnet_ids     = ["subnet-21****", "subnet-22****", "subnet-23****"]
  byovpc_public_subnet_ids          = ["subnet-31****", "subnet-32****", "subnet-33****"]
  byovpc_redis_subnet_group_name    = "existing-redis-subnet-group-name"
  byovpc_database_subnet_group_name = "existing-rds-subnet-group-name"
}

