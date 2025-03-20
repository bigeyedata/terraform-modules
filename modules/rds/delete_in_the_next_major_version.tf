# This file will be deleted with the next major version release of this module

resource "aws_security_group" "db_v2" {
  count  = var.create_security_groups ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-v2"
  tags = merge(var.tags, {
    Duty = "db"
    Name = "${var.name}-db"
  })
}

resource "aws_vpc_security_group_ingress_rule" "client_sg_v2" {
  count             = var.create_security_groups ? 1 : 0
  security_group_id = aws_security_group.db_v2[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from client sg"
  referenced_security_group_id = aws_security_group.db_clients_v2[0].id
}

resource "aws_vpc_security_group_ingress_rule" "other_sgs_v2" {
  for_each          = var.create_security_groups ? toset(var.allowed_client_security_group_ids) : []
  security_group_id = aws_security_group.db_v2[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from ${each.key}"
  referenced_security_group_id = each.key
}

resource "aws_vpc_security_group_ingress_rule" "additional_cidrs_v2" {
  for_each          = var.create_security_groups ? toset(var.additional_ingress_cidrs) : []
  security_group_id = aws_security_group.db_v2[0].id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "TCP"
  description = "Allows MySQL port from ${each.key}"
  cidr_ipv4   = each.key
}

resource "aws_security_group" "db_clients_v2" {
  count  = var.create_security_groups ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-clients-v2"
  tags = merge(var.tags, {
    Duty = "dbclients"
    Name = "${var.name}-db-clients"
  })
}

resource "aws_security_group" "db_replica_v2" {
  count  = var.create_security_groups && var.create_replica ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-replica-v2"
  tags = merge(var.tags, {
    Duty = "db"
    Name = "${var.name}-db-replica"
  })
}

resource "aws_vpc_security_group_ingress_rule" "replica_client_sg_v2" {
  count             = var.create_security_groups && var.create_replica ? 1 : 0
  security_group_id = aws_security_group.db_replica_v2[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from client sg"
  referenced_security_group_id = aws_security_group.db_replica_clients[0].id
}

resource "aws_security_group" "db_replica_clients_v2" {
  count  = var.create_security_groups && var.create_replica ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-replica-clients-v2"
  tags = merge(var.tags, {
    Duty = "dbclients"
    Name = "${var.name}-db-replica-clients"
  })
}

resource "aws_vpc_security_group_ingress_rule" "replica_other_sgs_v2" {
  for_each          = var.create_security_groups && var.create_replica ? toset(var.allowed_client_security_group_ids) : []
  security_group_id = aws_security_group.db_replica_v2[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from ${each.key}"
  referenced_security_group_id = each.key
}

resource "aws_vpc_security_group_ingress_rule" "replica_additional_cidrs_v2" {
  for_each          = var.create_security_groups && var.create_replica ? toset(var.additional_ingress_cidrs) : []
  security_group_id = aws_security_group.db_replica_v2[0].id

  from_port   = 3306
  to_port     = 3306
  ip_protocol = "TCP"
  description = "Allows MySQL port from ${each.key}"
  cidr_ipv4   = each.key
}
