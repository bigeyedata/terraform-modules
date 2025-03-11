# This file will be deleted with the next major version release of this module

resource "aws_security_group" "db" {
  count  = var.create_security_groups ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db"
  tags = merge(var.tags, {
    Duty = "db"
    Name = "${var.name}-db"
  })
}

resource "aws_vpc_security_group_ingress_rule" "client_sg" {
  count             = var.create_security_groups ? 1 : 0
  security_group_id = aws_security_group.db[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from client sg"
  referenced_security_group_id = aws_security_group.db_clients[0].id
}

resource "aws_vpc_security_group_ingress_rule" "other_sgs" {
  count             = var.create_security_groups ? length(var.allowed_client_security_group_ids) : 0
  security_group_id = aws_security_group.db[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from ${var.allowed_client_security_group_ids[count.index]}"
  referenced_security_group_id = var.allowed_client_security_group_ids[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "additional_cidrs" {
  count             = var.create_security_groups ? length(var.additional_ingress_cidrs) : 0
  security_group_id = aws_security_group.db[0].id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "TCP"
  description = "Allows MySQL port from ${var.additional_ingress_cidrs[count.index]}"
  cidr_ipv4   = var.additional_ingress_cidrs[count.index]
}

resource "aws_security_group" "db_clients" {
  count  = var.create_security_groups ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-clients"
  tags = merge(var.tags, {
    Duty = "dbclients"
    Name = "${var.name}-db-clients"
  })
}

resource "aws_security_group" "db_replica" {
  count  = var.create_security_groups && var.create_replica ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-replica"
  tags = merge(var.tags, {
    Duty = "db"
    Name = "${var.name}-db-replica"
  })
}

resource "aws_vpc_security_group_ingress_rule" "replica_client_sg" {
  count             = var.create_security_groups && var.create_replica ? 1 : 0
  security_group_id = aws_security_group.db_replica[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from client sg"
  referenced_security_group_id = aws_security_group.db_replica_clients[0].id
}

resource "aws_security_group" "db_replica_clients" {
  count  = var.create_security_groups && var.create_replica ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-replica-clients"
  tags = merge(var.tags, {
    Duty = "dbclients"
    Name = "${var.name}-db-replica-clients"
  })
}

resource "aws_vpc_security_group_ingress_rule" "replica_other_sgs" {
  count             = var.create_security_groups && var.create_replica ? length(var.allowed_client_security_group_ids) : 0
  security_group_id = aws_security_group.db_replica[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from ${var.allowed_client_security_group_ids[count.index]}"
  referenced_security_group_id = var.allowed_client_security_group_ids[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "replica_additional_cidrs" {
  count             = var.create_security_groups && var.create_replica ? length(var.additional_ingress_cidrs) : 0
  security_group_id = aws_security_group.db_replica[0].id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "TCP"
  description = "Allows MySQL port from ${var.additional_ingress_cidrs[count.index]}"
  cidr_ipv4   = var.additional_ingress_cidrs[count.index]
}
