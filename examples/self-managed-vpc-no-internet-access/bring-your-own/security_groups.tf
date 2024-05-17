resource "aws_security_group" "rabbitmq" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-rabbitmq", local.name)
  description = "Allows ingress to rabbitmq"
  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allow RabbitMQ traffic"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allows egress"
  }
}

resource "aws_security_group" "temporal" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-temporal", local.name)
  tags        = { Name = format("%s-temporal", local.name) }
  description = "Allows port 7233"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    description = "allow traffic from self"
    self        = true
  }

  ingress {
    from_port   = 7233
    to_port     = 7233
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allow temporal traffic"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allows egress"
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
    cidr_blocks = [var.cidr_block]
    description = "Allow mysql traffic internally"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allows egress"
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
    cidr_blocks = [var.cidr_block]
    description = "Allow redis traffic internally"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allows egress"
  }
}

resource "aws_security_group" "services" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-services", local.name)
  tags        = { Name = format("%s-services", local.name) }
  description = "Allows port 80/443"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allow HTTPS traffic"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allows egress"
  }
}

resource "aws_security_group" "http" {
  vpc_id      = module.vpc.vpc_id
  name        = format("%s-http", local.name)
  tags        = { Name = format("%s-http", local.name) }
  description = "Allows port 80/443"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allow HTTPS traffic"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = [var.cidr_block]
    description = "Allows egress"
  }
}
