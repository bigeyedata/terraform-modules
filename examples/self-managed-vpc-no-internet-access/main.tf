locals {
  environment = "test"
  instance    = "no-igw"
}

module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v1.13.0"
  environment = local.environment
  instance    = local.instance

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""
  # Get this from Bigeye Sales
  image_tag = ""

  # BYO VPC
  byovpc_vpc_id  = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block

  #  byovpc_public_subnet_ids          = module.vpc.intra_subnets
  byovpc_application_subnet_ids     = module.vpc.private_subnets
  byovpc_internal_subnet_ids        = module.vpc.intra_subnets
  byovpc_rabbitmq_subnet_ids        = module.vpc.elasticache_subnets
  byovpc_redis_subnet_group_name    = module.vpc.elasticache_subnet_group_name
  byovpc_database_subnet_group_name = module.vpc.database_subnet_group_name

  create_security_groups = false

  rabbitmq_extra_security_group_ids      = [aws_security_group.rabbitmq.id]
  datawatch_rds_extra_security_group_ids = [aws_security_group.rds.id]
  temporal_rds_extra_security_group_ids  = [aws_security_group.rds.id]
  redis_extra_security_group_ids         = [aws_security_group.redis.id]

  # LB security groups
  haproxy_lb_extra_security_group_ids    = [aws_security_group.http.id]
  web_lb_extra_security_group_ids        = [aws_security_group.http.id]
  monocle_lb_extra_security_group_ids    = [aws_security_group.http.id]
  toretto_lb_extra_security_group_ids    = [aws_security_group.http.id]
  temporalui_lb_extra_security_group_ids = [aws_security_group.http.id]
  temporal_lb_extra_security_group_ids   = [aws_security_group.http.id]
  scheduler_lb_extra_security_group_ids  = [aws_security_group.http.id]
  datawatch_lb_extra_security_group_ids  = [aws_security_group.http.id]
  datawork_lb_extra_security_group_ids   = [aws_security_group.http.id]
  metricwork_lb_extra_security_group_ids = [aws_security_group.http.id]

  # Task security groups
  haproxy_extra_security_group_ids    = [aws_security_group.services.id]
  web_extra_security_group_ids        = [aws_security_group.services.id]
  monocle_extra_security_group_ids    = [aws_security_group.services.id]
  toretto_extra_security_group_ids    = [aws_security_group.services.id]
  temporalui_extra_security_group_ids = [aws_security_group.services.id]
  temporal_extra_security_group_ids   = [aws_security_group.temporal.id]
  scheduler_extra_security_group_ids  = [aws_security_group.services.id]
  datawatch_extra_security_group_ids  = [aws_security_group.services.id]
  datawork_extra_security_group_ids   = [aws_security_group.services.id]
  metricwork_extra_security_group_ids = [aws_security_group.services.id]

  temporal_internet_facing = false
  internet_facing          = false
}
