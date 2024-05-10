locals {
  # Do not use hard coded AWS credentials for production installs.  These are here for demonstration purposes for those who do not
  # have credentials set up for Terraform to access AWS already.
  aws_region     = "us-west-2"
  aws_access_key = "<your aws_access_key>"
  aws_secret_key = "<your aws_secret_key>"

  # https://whatsmyip.com can be used to get your IP if you don't have it.  This should be the IP address from where
  # you will be using a browser or making API calls to Bigeye from.
  # This is only used for access to the bastion.  Ingress is only allowed from this cidr for the bastion and only
  # outbound to this address and the vpc cidr.
  external_access_cidr = "<your ip address>/32"

  environment = "test"
  instance    = "bigeye"
  name        = "${local.environment}-${local.instance}"

  # Get this from Bigeye Support.  Typically you will want to install the latest.
  image_tag = "1.34.0"
  # This will pull images directly from Bigeye's ECR repository.  It is recommended to cache the images in your own local ECR repository.
  image_registry = "021451147547.dkr.ecr.us-west-2.amazonaws.com"

  # Your parent route53 DNS domain, e.g. example.com
  parent_domain = "example.com"

  # Using a subdomain for sending from email is illustrated in this example as domain registration for a root level domain
  # generally requires a 12 month commitment from a domain name registrar so is beyond the scope of this example.
  # Example: subdomain_prefix = "dev" will result in the subdomain of dev.example.com
  subdomain_prefix = "dev"
  subdomain        = "${local.subdomain_prefix}.${local.parent_domain}"

  # Vanity URL is optional, but recommended.  This sets the API and UI URL that you will access Bigeye from. https://bigeye.dev.example.com
  vanity_alias = "bigeye"

  # This will result in a VPC cidr 10.240.0.0/16
  # Set this to something that won't collide with an existing cidr in your account
  cidr_first_two_octets = "10.240"

  # This is the email address that Bigeye email notifications will be sent from.  Don't change this value for this example.
  from_email = "bigeye@${local.subdomain}"

  # This IAM user is created in simple_email_server_example.tf and is used by AWS SES to send email.
  ses_iam_user_name = "${local.name}-bigeye"

  # This ASM secret is created in secrets.tf and can be used as an example if you are bringing your own email server.
  byomailserver_smtp_password_aws_secrets_manager_secret_id = "bigeye/${local.name}/smtp/password"
  byomailserver_smtp_host                                   = "email-smtp.${local.aws_region}.amazonaws.com"
  byomailserver_smtp_port                                   = 587
  byomailserver_smtp_user                                   = one(aws_iam_access_key.from_email[*].id)

  # Creates the IAM and SES identity for ${from_email}
  create_ses_from_email = true

  # Set this true will create an admin host for debugging if required.  See docs/TROUBLESHOOTING.md for instructions
  # on accessing the admin container
  enable_bigeye_admin_module = false

  # The bastion will be used for an SSH tunnel for no internet installs where a VPN is not available.  This is here for
  # demonstration purposes in this example, but a VPN is recommended instead for production installs.
  bastion_enabled = true

  # If you plan to use the bastion, run ssh-keygen -t rsa -b 4096 to create a key pair first if you have not already
  bastion_ssh_public_key_file = "~/.ssh/id_rsa.pub"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
}

provider "aws" {
  region     = local.aws_region
  access_key = local.aws_access_key
  secret_key = local.aws_secret_key
}

module "bigeye" {
  source             = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v4.3.0"
  environment        = local.environment
  instance           = local.instance
  top_level_dns_name = local.subdomain
  image_tag          = local.image_tag
  image_registry     = local.image_registry
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  vanity_alias       = local.vanity_alias

  byovpc_vpc_id = module.vpc.vpc_id
  # Leave byovpc_public_subnet_ids commented out for no-public-internet installs.  The loadbalancers will be
  # internal, with no route to public net.
  # byovpc_public_subnet_ids          = module.vpc.intra_subnets
  byovpc_application_subnet_ids     = module.vpc.private_subnets
  byovpc_internal_subnet_ids        = module.vpc.intra_subnets
  byovpc_rabbitmq_subnet_ids        = module.vpc.elasticache_subnets
  byovpc_redis_subnet_group_name    = module.vpc.elasticache_subnet_group_name
  byovpc_database_subnet_group_name = module.vpc.database_subnet_group_name

  # SG's are VPC resources, so BYO VPC installs must create and pass in their own security groups.  This is done for you
  # in this example in vpc_example.tf
  create_security_groups = false

  rabbitmq_extra_security_group_ids      = [aws_security_group.rabbitmq.id]
  datawatch_rds_extra_security_group_ids = [aws_security_group.rds.id]
  temporal_rds_extra_security_group_ids  = [aws_security_group.rds.id]
  redis_extra_security_group_ids         = [aws_security_group.redis.id]

  # LB security groups
  haproxy_lb_extra_security_group_ids     = [aws_security_group.http.id]
  web_lb_extra_security_group_ids         = [aws_security_group.http.id]
  monocle_lb_extra_security_group_ids     = [aws_security_group.http.id]
  toretto_lb_extra_security_group_ids     = [aws_security_group.http.id]
  temporalui_lb_extra_security_group_ids  = [aws_security_group.http.id]
  temporal_lb_extra_security_group_ids    = [aws_security_group.http.id]
  scheduler_lb_extra_security_group_ids   = [aws_security_group.http.id]
  datawatch_lb_extra_security_group_ids   = [aws_security_group.http.id]
  datawork_lb_extra_security_group_ids    = [aws_security_group.http.id]
  lineagework_lb_extra_security_group_ids = [aws_security_group.http.id]
  metricwork_lb_extra_security_group_ids  = [aws_security_group.http.id]

  # Task security groups
  haproxy_extra_security_group_ids     = [aws_security_group.services.id]
  web_extra_security_group_ids         = [aws_security_group.services.id]
  monocle_extra_security_group_ids     = [aws_security_group.services.id]
  toretto_extra_security_group_ids     = [aws_security_group.services.id]
  temporalui_extra_security_group_ids  = [aws_security_group.services.id]
  temporal_extra_security_group_ids    = [aws_security_group.temporal.id]
  scheduler_extra_security_group_ids   = [aws_security_group.services.id]
  datawatch_extra_security_group_ids   = [aws_security_group.services.id]
  datawork_extra_security_group_ids    = [aws_security_group.services.id]
  lineagework_extra_security_group_ids = [aws_security_group.services.id]
  metricwork_extra_security_group_ids  = [aws_security_group.services.id]

  temporal_internet_facing = false
  internet_facing          = false

  enable_bigeye_admin_module = local.enable_bigeye_admin_module

  # BYO mail server is required for installs without a route to public net as Bigeye's default SMTP server will not be
  # reachable to route email notifications.
  byomailserver_smtp_host                = local.byomailserver_smtp_host
  byomailserver_smtp_port                = local.byomailserver_smtp_port
  byomailserver_smtp_user                = local.byomailserver_smtp_user
  byomailserver_smtp_from_address        = local.from_email
  byomailserver_smtp_password_secret_arn = local.create_ses_from_email ? aws_secretsmanager_secret.smtp_password[0].arn : ""
}
