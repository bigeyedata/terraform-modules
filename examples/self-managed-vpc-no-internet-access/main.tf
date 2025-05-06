terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

provider "aws" {
  region = local.aws_region
  # Configure your AWS provider
  # e.g.
  # access_key = local.aws_access_key
  # secret_key = local.aws_secret_key
}

locals {
  aws_region     = "<your region>"
  aws_account_id = "<your aws account ID>"

  environment = "test"
  instance    = "bigeye"


  # This is computed
  name = format("%s-%s", local.environment, local.instance)

  # This example registers a subdomain in your already registered domain.
  # Registering a root level domain name involves a commitment from a Domain Name Registrar
  # for a minimum of 12 months so is beyond the scope of this example.
  parent_domain_hosted_zone_id = ""
  parent_domain_name           = "example.com"
  # Using a subdomain for sending from email is illustrated in this example as domain registration for a root level domain
  # generally requires a 12 month commitment from a domain name registrar so is beyond the scope of this example.
  # Example: subdomain_prefix = "dev" will result in the subdomain of dev.example.com
  subdomain_prefix = "dev"
  domain_name      = format("%s.%s", local.subdomain_prefix, local.parent_domain_name)
  # Vanity URL is optional, but recommended.  This sets the API and UI URL that you will access Bigeye from. https://bigeye.dev.example.com
  vanity_alias = "bigeye"

  # Get this from Bigeye Support.  Typically you will want to install the latest.
  image_tag = "1.50.0"
  # This will pull images directly from Bigeye's ECR repository.  It is recommended to cache the images in your own local ECR repository.
  # If you receive an error for image unavailable, contact Bigeye support, we likely do not have our images in your region yet and
  # will need to publish them.
  image_registry = "021451147547.dkr.ecr.${local.aws_region}.amazonaws.com"

  # This is the email address that Bigeye email notifications will be sent from.  Don't change this value for this example.
  from_email = format("bigeye@%s", local.domain_name)

  # This will result in a VPC cidr 10.100.0.0/16
  # Set this to something that won't collide with an existing cidr in your account
  cidr_first_two_octets = "10.0"
  cidr_block            = format("%s.0.0/16", local.cidr_first_two_octets)

  # The bastion will be used for an SSH tunnel for no internet installs where a VPN is not available.  This is here for
  # demonstration purposes in this example, but a VPN is recommended instead for production installs.
  bastion_enabled = true

  # Use this if you want to connect to the bastion over public IP. Otherwise, you should be able to connect over SSM
  bastion_public = true

  # https://whatsmyip.com can be used to get your IP if you don't have it.  This should be the IP address from where
  # you will be using a browser or making API calls to Bigeye from.
  # This is only used for access to the bastion.  Ingress is only allowed from this cidr for the bastion and only
  # outbound to this address and the vpc cidr.
  bastion_ingress_cidr = "<Your public IP here>/32"

  # If you plan to use the bastion, run ssh-keygen -t rsa -b 4096 to create a key pair first if you have not already
  bastion_ssh_public_key_file = "~/.ssh/id_rsa.pub"
}

module "bringyourown" {
  source = "./bring-your-own"

  aws_region            = local.aws_region
  aws_account_id        = local.aws_account_id
  stack_name            = local.name
  parent_domain_zone_id = local.parent_domain_hosted_zone_id
  subdomain             = local.domain_name
  subdomain_prefix      = local.subdomain_prefix
  from_email            = local.from_email

  cidr_first_two_octets       = local.cidr_first_two_octets
  cidr_block                  = local.cidr_block
  bastion_enabled             = local.bastion_enabled
  bastion_public              = local.bastion_public
  bastion_ingress_cidr        = local.bastion_ingress_cidr
  bastion_ssh_public_key_file = local.bastion_ssh_public_key_file
}

module "bigeye" {
  source             = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v20.5.0"
  environment        = local.environment
  instance           = local.instance
  top_level_dns_name = local.domain_name
  image_tag          = local.image_tag
  image_registry     = local.image_registry
  vpc_cidr_block     = module.bringyourown.vpc_id
  vanity_alias       = local.vanity_alias

  byovpc_vpc_id            = module.bringyourown.vpc_id
  temporal_internet_facing = false
  internet_facing          = false

  # Leave byovpc_public_subnet_ids commented out for no-public-internet installs.  The loadbalancers will be
  # internal, with no route to public net.
  # byovpc_public_subnet_ids          = module.vpc.intra_subnets
  byovpc_application_subnet_ids     = module.bringyourown.private_subnet_ids
  byovpc_internal_subnet_ids        = module.bringyourown.internal_subnet_ids
  byovpc_rabbitmq_subnet_ids        = module.bringyourown.elasticache_subnet_ids
  byovpc_redis_subnet_group_name    = module.bringyourown.redis_subnet_group_name
  byovpc_database_subnet_group_name = module.bringyourown.database_subnet_group_name

  # SG's are VPC resources, so BYO VPC installs must create and pass in their own security groups.  This is done for you
  # in this example in vpc_example.tf
  create_security_groups = false

  # IAM
  ecs_service_role_arn              = module.bringyourown.ecs_service_iam_role_arn
  admin_container_ecs_task_role_arn = module.bringyourown.admin_container_iam_role_arn
  datawatch_task_role_arn           = module.bringyourown.datawatch_iam_role_arn
  monocle_task_role_arn             = module.bringyourown.monocle_iam_role_arn

  # BYO Rabbit
  byo_rabbitmq_endpoint             = module.bringyourown.rabbitmq_endpoint
  rabbitmq_user_password_secret_arn = module.bringyourown.rabbitmq_password_secret_arn

  datawatch_rds_extra_security_group_ids = [module.bringyourown.rds_security_group_id]
  temporal_rds_extra_security_group_ids  = [module.bringyourown.rds_security_group_id]
  redis_extra_security_group_ids         = [module.bringyourown.redis_security_group_id]
  rabbitmq_extra_security_group_ids      = [module.bringyourown.rabbitmq_security_group_id]

  temporal_opensearch_enabled = false
  create_dns_records          = false
  acm_certificate_arn         = module.bringyourown.acm_certificate_arn

  # LB security groups
  haproxy_lb_extra_security_group_ids     = [module.bringyourown.http_security_group_id]
  web_lb_extra_security_group_ids         = [module.bringyourown.http_security_group_id]
  monocle_lb_extra_security_group_ids     = [module.bringyourown.http_security_group_id]
  toretto_lb_extra_security_group_ids     = [module.bringyourown.http_security_group_id]
  temporalui_lb_extra_security_group_ids  = [module.bringyourown.http_security_group_id]
  temporal_lb_extra_security_group_ids    = [module.bringyourown.http_security_group_id]
  scheduler_lb_extra_security_group_ids   = [module.bringyourown.http_security_group_id]
  datawatch_lb_extra_security_group_ids   = [module.bringyourown.http_security_group_id]
  datawork_lb_extra_security_group_ids    = [module.bringyourown.http_security_group_id]
  lineagework_lb_extra_security_group_ids = [module.bringyourown.http_security_group_id]
  metricwork_lb_extra_security_group_ids  = [module.bringyourown.http_security_group_id]

  # Task security groups
  haproxy_extra_security_group_ids     = [module.bringyourown.services_security_group_id]
  web_extra_security_group_ids         = [module.bringyourown.services_security_group_id]
  monocle_extra_security_group_ids     = [module.bringyourown.services_security_group_id]
  toretto_extra_security_group_ids     = [module.bringyourown.services_security_group_id]
  temporalui_extra_security_group_ids  = [module.bringyourown.services_security_group_id]
  temporal_extra_security_group_ids    = [module.bringyourown.temporal_security_group_id]
  scheduler_extra_security_group_ids   = [module.bringyourown.services_security_group_id]
  datawatch_extra_security_group_ids   = [module.bringyourown.services_security_group_id]
  datawork_extra_security_group_ids    = [module.bringyourown.services_security_group_id]
  lineagework_extra_security_group_ids = [module.bringyourown.services_security_group_id]
  metricwork_extra_security_group_ids  = [module.bringyourown.services_security_group_id]

  # BYO mail server is required for installs without a route to public net as Bigeye's default SMTP server will not be
  # reachable to route email notifications.
  byomailserver_smtp_host                = module.bringyourown.ses_hostname
  byomailserver_smtp_port                = module.bringyourown.ses_port
  byomailserver_smtp_user                = module.bringyourown.ses_user
  byomailserver_smtp_from_address        = local.from_email
  byomailserver_smtp_password_secret_arn = module.bringyourown.ses_password_arn
}

module "dns" {
  source = "./dns"

  zone_id    = module.bringyourown.zone_id
  stack_name = local.name

  haproxy_domain_name                   = module.bigeye.vanity_dns_name
  haproxy_load_balancer_domain_name     = module.bigeye.haproxy_load_balancer_dns_name
  datawatch_domain_name                 = module.bigeye.datawatch_dns_name
  datawatch_load_balancer_domain_name   = module.bigeye.datawatch_load_balancer_dns_name
  datawork_domain_name                  = module.bigeye.datawork_dns_name
  datawork_load_balancer_domain_name    = module.bigeye.datawork_load_balancer_dns_name
  lineagework_domain_name               = module.bigeye.lineagework_dns_name
  lineagework_load_balancer_domain_name = module.bigeye.lineagework_load_balancer_dns_name
  metricwork_domain_name                = module.bigeye.metricwork_dns_name
  metricwork_load_balancer_domain_name  = module.bigeye.metricwork_load_balancer_dns_name
  scheduler_domain_name                 = module.bigeye.scheduler_dns_name
  scheduler_load_balancer_domain_name   = module.bigeye.scheduler_load_balancer_dns_name
  monocle_domain_name                   = module.bigeye.monocle_dns_name
  monocle_load_balancer_domain_name     = module.bigeye.monocle_load_balancer_dns_name
  toretto_domain_name                   = module.bigeye.toretto_dns_name
  toretto_load_balancer_domain_name     = module.bigeye.toretto_load_balancer_dns_name
  web_domain_name                       = module.bigeye.web_dns_name
  web_load_balancer_domain_name         = module.bigeye.web_load_balancer_dns_name
  temporalui_domain_name                = module.bigeye.temporalui_dns_name
  temporalui_load_balancer_domain_name  = module.bigeye.temporalui_load_balancer_dns_name
  temporal_domain_name                  = module.bigeye.temporal_dns_name
  temporal_load_balancer_domain_name    = module.bigeye.temporal_load_balancer_dns_name
  datawatch_mysql_vanity_domain_name    = module.bigeye.datawatch_database_vanity_dns_name
  datawatch_mysql_domain_name           = module.bigeye.datawatch_database_dns_name
  temporal_mysql_vanity_domain_name     = module.bigeye.temporal_database_vanity_dns_name
  temporal_mysql_domain_name            = module.bigeye.temporal_database_dns_name
}
