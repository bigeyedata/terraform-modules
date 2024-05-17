module "vpc" {
  # https://github.com/terraform-aws-modules/terraform-aws-vpc
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = local.name
  azs  = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]

  enable_nat_gateway = false
  enable_ipv6        = false

  cidr = var.cidr_block

  # Public subnets
  # It can be useful to create the public_subnet as shown below in case a bastion, VPN or something similar will be used
  # to access the network.  If not required, it is recommended to leave this empty.
  public_subnets = var.bastion_enabled && var.bastion_public ? [
    format("%s.1.0/24", var.cidr_first_two_octets),
    format("%s.3.0/24", var.cidr_first_two_octets),
    format("%s.5.0/24", var.cidr_first_two_octets),
  ] : []
  public_subnet_suffix = "public"
  public_subnet_tags = merge({
    Duty   = "public"
    Public = "true"
  })

  # Internal subnets
  intra_subnets = [
    format("%s.2.0/24", var.cidr_first_two_octets),
    format("%s.4.0/24", var.cidr_first_two_octets),
    format("%s.6.0/24", var.cidr_first_two_octets),
  ]
  intra_subnet_suffix = "internal"
  intra_subnet_tags = merge({
    Duty   = "internal"
    Public = "false"
  })

  # Private subnets
  private_subnets = [
    format("%s.7.0/24", var.cidr_first_two_octets),
    format("%s.9.0/24", var.cidr_first_two_octets),
    format("%s.11.0/24", var.cidr_first_two_octets),
  ]
  private_subnet_suffix = "application"
  private_subnet_tags = merge({
    Duty   = "application"
    Public = "false"
  })

  # Database subnets
  create_database_subnet_route_table = true
  database_subnets = [
    format("%s.8.0/24", var.cidr_first_two_octets),
    format("%s.10.0/24", var.cidr_first_two_octets),
    format("%s.12.0/24", var.cidr_first_two_octets),
  ]
  database_subnet_suffix = "database"
  database_subnet_tags = merge({
    Duty   = "database"
    Public = "false"
  })

  # Cache subnets
  create_elasticache_subnet_route_table = true
  elasticache_subnets = [
    format("%s.14.0/24", var.cidr_first_two_octets),
    format("%s.16.0/24", var.cidr_first_two_octets),
    format("%s.18.0/24", var.cidr_first_two_octets),
  ]
  elasticache_subnet_suffix = "elasticache"
  elasticache_subnet_tags = merge({
    Duty   = "elasticache"
    Public = "false"
  })
}

# VPC input validation
resource "aws_security_group" "vpc_endpoint" {
  name        = format("%s-vpc-endpoints", local.name)
  description = "Allows traffic through VPC endpoint"
  vpc_id      = module.vpc.vpc_id
  tags = merge({
    Name = format("%s-vpc-endpoints", local.name)
  })

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description = "Allow HTTP traffic"
    cidr_blocks = [format("%s.0.0/16", var.cidr_first_two_octets)]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "Allow HTTPS traffic"
    cidr_blocks = [format("%s.0.0/16", var.cidr_first_two_octets)]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allow all egress"
  }
}

# Installs without an internet connection, need to use VPC Endpoints to access AWS APIs.  This is also
# a recommended practice for installs that do allow public access.
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.5.3"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.vpc_endpoint.id]

  endpoints = {
    s3_gateway = {
      service             = "s3"
      tags                = merge({ Name = format("%s-s3-endpoint", local.name) })
      service_type        = "Gateway"
      private_dns_enabled = true
      route_table_ids = concat(
        module.vpc.database_route_table_ids,
        module.vpc.elasticache_route_table_ids,
        module.vpc.intra_route_table_ids,
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids
      )
    }
    s3_interface = {
      service             = "s3"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      dns_options = {
        private_dns_only_for_inbound_resolver_endpoint = false
      }
      tags = merge({
        Name = format("%s-s3-interface-endpoint", local.name)
      })
    }
    ec2 = {
      service             = "ec2"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-ec2-endpoint", local.name)
      })
    }
    cloudformation = {
      service             = "cloudformation"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-cloudformation-endpoint", local.name)
      })
    }
    sts = {
      service             = "sts"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-sts-endpoint", local.name)
      })
    }
    ecr_api = {
      service             = "ecr.api"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-ecrapi-endpoint", local.name)
      })
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-ecrdkr-endpoint", local.name)
      })
    }
    ssm = {
      service             = "ssm"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-ssm-endpoint", local.name)
      })
    }
    ssmmessages = {
      service             = "ssmmessages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-ssmmessages-endpoint", local.name)
      })
    }
    ecs = {
      service             = "ecs"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-ecs-endpoint", local.name)
      })
    }
    elasticloadbalancing = {
      service             = "elasticloadbalancing"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-elasticloadbalancing-endpoint", local.name)
      })
    }
    rds = {
      service             = "rds"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-rds-endpoint", local.name)
      })
    }
    elasticache = {
      service             = "elasticache"
      service_type        = "Interface"
      subnet_ids          = module.vpc.intra_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-elasticache-endpoint", local.name)
      })
    }
    logs = {
      service             = "logs"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-logs-endpoint", local.name)
      })
    }
    secretsmanager = {
      service             = "secretsmanager"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      tags = merge({
        Name = format("%s-secretsmanager-endpoint", local.name)
      })
    }
  }
}

