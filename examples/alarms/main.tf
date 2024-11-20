module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v14.1.0"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  # Get this from Bigeye Sales
  image_tag = "1.34.0"
}

# Alarms module
module "alarms" {
  source                           = "git::https://github.com/bigeyedata/terraform-modules//modules/alarms?ref=v14.1.0"
  stack                            = module.bigeye.stack_name
  datawatch_rds_identifier         = module.bigeye.datawatch_rds_identifier
  datawatch_rds_replica_identifier = module.bigeye.datawatch_rds_replica_identifier
  temporal_rds_identifier          = module.bigeye.temporal_rds_identifier
  rabbitmq_name                    = module.bigeye.rabbitmq_name
  redis_cluster_id                 = module.bigeye.redis_cluster_id
}

