terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
}

locals {
  general_log_param = {
    general_log = {
      value = contains(var.enabled_logs, "general") ? 1 : 0
    }
  }
  slow_log_param = {
    slow_query_log = {
      value = contains(var.enabled_logs, "slowquery") ? 1 : 0
    }
  }
  create_option_group = length(var.options) > 0
  option_group_name   = local.create_option_group ? var.option_group_name : "default:mysql-8-0"
  parameters_object = merge(
    local.general_log_param,
    local.slow_log_param,
    var.parameters
  )
  parameters_list = [
    for k, v in local.parameters_object : {
      name         = k
      value        = v["value"]
      apply_method = lookup(v, "apply_method", null)
    }
  ]
  replica_create_option_group = length(var.replica_options) > 0
  replica_option_group_name   = local.replica_create_option_group ? var.replica_option_group_name : "default:mysql-8-0"
  replica_parameters_object = merge(
    local.general_log_param,
    local.slow_log_param,
    var.replica_parameters
  )
  replica_parameters_list = [
    for k, v in local.replica_parameters_object : {
      name         = k
      value        = v["value"]
      apply_method = lookup(v, "apply_method", null)
    }
  ]
}

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
  referenced_security_group_id = aws_security_group.db_replica_clients_v2[0].id
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

resource "aws_security_group" "db_replica_clients_v2" {
  count  = var.create_security_groups && var.create_replica ? 1 : 0
  vpc_id = var.vpc_id
  name   = "${var.name}-db-replica-clients-v2"
  tags = merge(var.tags, {
    Duty = "dbclients"
    Name = "${var.name}-db-replica-clients"
  })
}

module "this" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  apply_immediately                   = var.apply_immediately
  snapshot_identifier                 = var.snapshot_identifier
  identifier                          = var.name
  engine                              = "mysql"
  engine_version                      = var.engine_version
  auto_minor_version_upgrade          = false
  instance_class                      = var.instance_class
  db_name                             = var.db_name
  username                            = var.root_user_name
  password                            = var.root_user_password
  manage_master_user_password         = false
  deletion_protection                 = var.deletion_protection
  iam_database_authentication_enabled = true

  publicly_accessible    = false
  port                   = 3306
  create_db_subnet_group = false
  db_subnet_group_name   = var.db_subnet_group_name
  multi_az               = var.enable_multi_az
  vpc_security_group_ids = var.create_security_groups ? concat([aws_security_group.db_v2[0].id], var.extra_security_group_ids) : var.extra_security_group_ids

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  iops                  = var.iops

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.performance_insights_retention_period
  monitoring_interval                   = var.enhanced_monitoring_interval
  monitoring_role_arn                   = var.enhanced_monitoring_role_arn
  backup_window                         = var.backup_window
  backup_retention_period               = var.backup_retention_period
  maintenance_window                    = var.maintenance_window
  enabled_cloudwatch_logs_exports       = var.enabled_logs

  create_db_option_group = local.create_option_group
  option_group_name      = local.option_group_name
  options                = var.options
  major_engine_version   = "8.0"

  family                      = "mysql8.0"
  create_db_parameter_group   = var.create_parameter_group
  parameter_group_name        = var.parameter_group_name
  parameter_group_description = "Bigeye RDS parameter group with recommendations"
  parameters                  = local.parameters_list

  tags = merge(var.tags, var.primary_additional_tags)
}

module "replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  count      = var.create_replica ? 1 : 0
  depends_on = [module.this.db_instance_identifier]

  apply_immediately                   = var.apply_immediately
  identifier                          = "${var.name}-ro"
  engine                              = "mysql"
  engine_version                      = var.replica_engine_version != "" ? var.replica_engine_version : var.engine_version
  auto_minor_version_upgrade          = false
  instance_class                      = var.replica_instance_class
  deletion_protection                 = var.deletion_protection
  iam_database_authentication_enabled = true
  skip_final_snapshot                 = true

  replicate_source_db    = module.this.db_instance_identifier
  publicly_accessible    = false
  port                   = 3306
  create_db_subnet_group = false
  multi_az               = false
  vpc_security_group_ids = var.create_security_groups ? concat([aws_security_group.db_replica_v2[0].id], var.extra_security_group_ids) : var.extra_security_group_ids

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  iops                  = var.replica_iops

  performance_insights_enabled          = var.replica_enable_performance_insights
  performance_insights_retention_period = var.replica_performance_insights_retention_period
  monitoring_interval                   = var.enhanced_monitoring_interval
  monitoring_role_arn                   = var.enhanced_monitoring_role_arn
  backup_window                         = var.backup_window
  backup_retention_period               = var.replica_backup_retention_period
  maintenance_window                    = var.maintenance_window
  enabled_cloudwatch_logs_exports       = var.enabled_logs

  create_db_option_group = local.replica_create_option_group
  option_group_name      = local.replica_option_group_name
  options                = var.replica_options
  major_engine_version   = "8.0"

  family                      = "mysql8.0"
  create_db_parameter_group   = var.replica_create_parameter_group
  parameter_group_name        = var.replica_parameter_group_name == "" ? module.this.db_parameter_group_id : var.replica_parameter_group_name
  parameter_group_description = var.replica_create_parameter_group ? "Parameter group for ${var.name}" : ""
  parameters                  = local.replica_parameters_list

  tags = merge(var.tags, var.replica_additional_tags)
}

