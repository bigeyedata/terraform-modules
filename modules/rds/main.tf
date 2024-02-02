terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
}

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

resource "aws_vpc_security_group_ingress_rule" "replica_other_sgs" {
  count             = var.create_security_groups && var.create_replica ? length(var.allowed_client_security_group_ids) : 0
  security_group_id = aws_security_group.db_replica[0].id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "TCP"
  description                  = "Allows MySQL port from ${var.allowed_client_security_group_ids[count.index]}"
  referenced_security_group_id = var.allowed_client_security_group_ids[count.index]
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

data "aws_secretsmanager_secret" "root_user_password" {
  arn = var.root_user_password_secret_arn
}
data "aws_secretsmanager_secret_version" "root_user_password" {
  secret_id = data.aws_secretsmanager_secret.root_user_password.id
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
  password                            = data.aws_secretsmanager_secret_version.root_user_password.secret_string
  manage_master_user_password         = false
  deletion_protection                 = var.deletion_protection
  iam_database_authentication_enabled = true

  publicly_accessible    = false
  port                   = 3306
  create_db_subnet_group = false
  db_subnet_group_name   = var.db_subnet_group_name
  multi_az               = var.enable_multi_az
  vpc_security_group_ids = var.create_security_groups ? concat([aws_security_group.db[0].id], var.extra_security_group_ids) : var.extra_security_group_ids

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.performance_insights_retention_period
  monitoring_interval                   = var.enhanced_monitoring_interval
  monitoring_role_arn                   = var.enhanced_monitoring_role_arn
  backup_window                         = var.backup_window
  backup_retention_period               = var.backup_retention_period
  maintenance_window                    = var.maintenance_window
  enabled_cloudwatch_logs_exports       = var.enabled_logs

  create_db_option_group = var.create_option_group
  option_group_name      = var.option_group_name
  options                = var.options

  family                      = "mysql8.0"
  create_db_parameter_group   = var.create_parameter_group
  parameter_group_name        = var.parameter_group_name
  parameter_group_description = "Bigeye RDS parameter group with recommendations"
  parameters                  = var.parameters

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
  engine_version                      = var.engine_version
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
  vpc_security_group_ids = var.create_security_groups ? concat([aws_security_group.db_replica[0].id], var.extra_security_group_ids) : var.extra_security_group_ids

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  performance_insights_enabled          = var.replica_enable_performance_insights
  performance_insights_retention_period = var.performance_insights_retention_period
  monitoring_interval                   = var.enhanced_monitoring_interval
  monitoring_role_arn                   = var.enhanced_monitoring_role_arn
  backup_window                         = var.backup_window
  backup_retention_period               = var.replica_backup_retention_period
  maintenance_window                    = var.maintenance_window
  enabled_cloudwatch_logs_exports       = var.enabled_logs

  create_db_parameter_group = false
  parameter_group_name      = module.this.db_parameter_group_id
  create_db_option_group    = false
  option_group_name         = module.this.db_option_group_id

  tags = merge(var.tags, var.replica_additional_tags)
}

