variable "name" {
  description = "The name to give to the database"
  type        = string
}

variable "allocated_storage" {
  description = "The amount of storage to allocate in GB"
  type        = number
  default     = 20
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection on the database"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "The database name"
  type        = string
}

variable "root_user_name" {
  description = "The root user name"
  type        = string
  default     = "bigeye"
}

variable "root_user_password" {
  description = "master user password"
  type        = string
  sensitive   = true
}

variable "max_allocated_storage" {
  description = "Allows storage autoscaling up to this amount"
  type        = number
  default     = 1024
}

variable "storage_type" {
  description = "The storage type for the db, e.g. gp3"
  type        = string
  default     = "gp3"
}

variable "db_subnet_group_name" {
  description = "The name of the subnet group to put the database instance"
  type        = string
}

variable "snapshot_identifier" {
  description = "The identifier of the snapshot to create the database from"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "The MYSQL engine version, e.g. 8.0.32"
  type        = string
  default     = "8.0.32"
}

variable "instance_class" {
  description = "The instance class size to use"
  type        = string
  default     = "db.t4g.small"
}

variable "backup_window" {
  description = "The window for backup"
  type        = string
  default     = "08:01-09:00"
}

variable "backup_retention_period" {
  description = "days to keep backups"
  type        = number
  default     = 30
}

variable "replica_backup_retention_period" {
  description = "days to keep backups for the replica"
  type        = number
  default     = 1
}

variable "maintenance_window" {
  description = "The window for maintenance"
  type        = string
  default     = "wed:01:01-wed:02:00"
}

variable "enable_multi_az" {
  description = "Whether to enable a Multi-AZ standby"
  type        = bool
  default     = false
}

variable "enable_performance_insights" {
  description = "Whether to enable performance insights"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "days to keep performance insights"
  type        = number
  default     = 7
}

variable "enhanced_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds, 0 means off"
  type        = number
  default     = 0
}

variable "enhanced_monitoring_role_arn" {
  description = "The Role ARN to associate with the enhanced monitoring role"
  type        = string
  default     = ""
}

variable "enabled_logs" {
  description = "Which logs to enable, defaults to error."
  type        = list(string)
  default     = ["error"]
}

variable "create_option_group" {
  description = "Whether or not to create a custom option group"
  type        = bool
  default     = false
}

variable "option_group_name" {
  description = "Name for the option group"
  type        = string
  default     = ""
}

variable "options" {
  description = "A list of maps containing options, maps should have keys 'name' and 'value'"
  type        = list(map(string))
  default     = []
}

variable "create_parameter_group" {
  description = "Whether to create a custom parameter group"
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Name for the parameter group"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "A list of maps containing parameters. Maps should have keys 'name' and 'value'"
  type        = list(map(string))
  default     = []
}

variable "extra_security_group_ids" {
  description = "A list of additional security group IDs to apply to the database"
  type        = list(string)
  default     = []
}

variable "create_replica" {
  description = "Whether to create a read-only replica"
  type        = bool
  default     = false
}

variable "replica_engine_version" {
  description = "Defaults to engine_version.  This is primarily used for engine upgrades as the replica has to be upgraded first."
  type        = string
  default     = ""
}

variable "replica_instance_class" {
  description = "Instance class of the replica"
  type        = string
  default     = "db.t4g.small"
}

variable "replica_enable_performance_insights" {
  description = "Whether to enable performance insights on the replica"
  type        = bool
  default     = false
}

variable "replica_performance_insights_retention_period" {
  description = "days to keep performance insights on the replica"
  type        = number
  default     = 7
}

variable "replica_create_parameter_group" {
  description = "Whether to create a parameter group for the replica"
  type        = bool
  default     = false
}

variable "replica_parameters" {
  description = "A list of maps containing parameters. Maps should have keys 'name' and 'value'"
  type        = list(map(string))
  default     = []
}

variable "replica_parameter_group_name" {
  description = "Name for the replica parameter group"
  type        = string
  default     = ""
}

variable "create_security_groups" {
  description = "whether or not to create security groups for the database and their workers"
  type        = bool
  default     = true
}

variable "additional_ingress_cidrs" {
  description = "A list of additional cidrs to make ingress rules for"
  type        = list(string)
  default     = []
}

variable "allowed_client_security_group_ids" {
  description = "A list of security groups to allow ingress from"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "the VPC ID to create the security groups in"
  type        = string
}

variable "tags" {
  description = "A list of tags to apply to RDS resources"
  type        = map(string)
  default     = {}
}

variable "primary_additional_tags" {
  description = "A list of tags to apply to the RDS primary DB.  This is merged with var.tags for the primary db"
  type        = map(string)
  default     = {}
}

variable "replica_additional_tags" {
  description = "Tags to apply to the RDS replica DB (if a replica is enabled).  This is merged with var.tags for the replica"
  type        = map(string)
  default     = {}
}
