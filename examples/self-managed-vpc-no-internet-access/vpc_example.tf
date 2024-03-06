#######################################################################
# This VPC is optional and here to facilitate testing a BYO VPC install.
# Most BYO VPC examples will not use this file and will supply existing
# vpc, subnets etc to the Bigeye module in main.tf.
#######################################################################

locals {
  cidr_block = format("%s.0.0/16", local.cidr_first_two_octets)
}

module "vpc" {
  # https://github.com/terraform-aws-modules/terraform-aws-vpc
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = format("%s-byovpc", local.name)
  azs  = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]

  cidr               = local.cidr_block
  enable_nat_gateway = false

  enable_ipv6 = false

  # Public subnets
  # It can be useful to create the public_subnet as shown below in case a bastion, VPN or something similar will be used
  # to access the network.  If not required, it is recommended to leave this empty.
  public_subnets       = local.public_subnets
  public_subnet_suffix = "public"
  public_subnet_tags = merge({
    Duty   = "public"
    Public = "true"
  })

  # Internal subnets
  intra_subnets = [
    format("%s.2.0/24", local.cidr_first_two_octets),
    format("%s.4.0/24", local.cidr_first_two_octets),
    format("%s.6.0/24", local.cidr_first_two_octets),
  ]
  intra_subnet_suffix = "internal"
  intra_subnet_tags = merge({
    Duty   = "internal"
    Public = "false"
  })

  # Private subnets
  private_subnets = [
    format("%s.7.0/24", local.cidr_first_two_octets),
    format("%s.9.0/24", local.cidr_first_two_octets),
    format("%s.11.0/24", local.cidr_first_two_octets),
  ]
  private_subnet_suffix = "application"
  private_subnet_tags = merge({
    Duty   = "application"
    Public = "false"
  })

  # Database subnets
  create_database_subnet_route_table = true
  database_subnets = [
    format("%s.8.0/24", local.cidr_first_two_octets),
    format("%s.10.0/24", local.cidr_first_two_octets),
    format("%s.12.0/24", local.cidr_first_two_octets),
  ]
  database_subnet_suffix = "database"
  database_subnet_tags = merge({
    Duty   = "database"
    Public = "false"
  })

  # Cache subnets
  create_elasticache_subnet_route_table = true
  elasticache_subnets = [
    format("%s.14.0/24", local.cidr_first_two_octets),
    format("%s.16.0/24", local.cidr_first_two_octets),
    format("%s.18.0/24", local.cidr_first_two_octets),
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
    cidr_blocks = [format("%s.0.0/16", local.cidr_first_two_octets)]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description = "Allow HTTPS traffic"
    cidr_blocks = [format("%s.0.0/16", local.cidr_first_two_octets)]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all egress"
  }
}

# Installs without an internet connection, need to use VPC Endpoints to access AWS APIs.  This is also
# a recommended practice for installs that do allow public access.
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.1.2"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.vpc_endpoint.id]

  endpoints = {
    s3 = {
      service      = "s3"
      tags         = merge({ Name = format("%s-s3-endpoint", local.name) })
      service_type = "Gateway"
      route_table_ids = concat(
        module.vpc.database_route_table_ids,
        module.vpc.elasticache_route_table_ids,
        module.vpc.intra_route_table_ids,
        module.vpc.private_route_table_ids,
        module.vpc.public_route_table_ids
      )
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

resource "aws_security_group" "rabbitmq" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-rabbitmq", local.name)
  description = "Allows ingress to rabbitmq"
  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "TCP"
    cidr_blocks = [local.cidr_block]
    description = "Allow RabbitMQ traffic"
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allows egress"
  }
}

resource "aws_security_group" "temporal" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-temporal", local.name)
  tags        = { Name = format("%s-temporal", local.name) }
  description = "Allows port 7233"

  ingress {
    from_port        = 7233
    to_port          = 7233
    protocol         = "TCP"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow temporal traffic"
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allows egress"
  }
}

resource "aws_security_group" "rds" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-rds", local.name)
  tags        = { Name = format("%s-rds", local.name) }
  description = "Allows port 3306"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = [local.cidr_block]
    description = "Allow mysql traffic internally"
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allows egress"
  }
}

resource "aws_security_group" "redis" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-redis", local.name)
  tags        = { Name = format("%s-redis", local.name) }
  description = "Allows port 6379"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "TCP"
    cidr_blocks = [local.cidr_block]
    description = "Allow redis traffic internally"
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allows egress"
  }
}

resource "aws_security_group" "services" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-services", local.name)
  tags        = { Name = format("%s-services", local.name) }
  description = "Allows port 80/443"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow HTTP traffic"
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow HTTPS traffic"
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allows egress"
  }
}

resource "aws_security_group" "http" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-http", local.name)
  tags        = { Name = format("%s-http", local.name) }
  description = "Allows port 80/443"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow HTTP traffic"
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow HTTPS traffic"
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allows egress"
  }
}
