output "identifier" {
  description = "RDS identifier of database"
  value       = module.this.db_instance_identifier
}

output "replica_identifier" {
  description = "RDS identifier of database replica"
  value       = var.create_replica ? module.replica[0].db_instance_identifier : ""
}

output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "master_user_name" {
  description = "Master user name"
  value       = var.root_user_name
}

output "client_security_group_id" {
  description = "Security group id for clients"
  value       = var.create_security_groups ? aws_security_group.db_clients[0].id : ""
}

output "replica_client_security_group_id" {
  description = "Security group ID for the replica"
  value       = var.create_replica && var.create_security_groups ? aws_security_group.db_replica[0].id : ""
}

output "primary_dns_name" {
  description = "DNS name of the primary db"
  value       = module.this.db_instance_address
}

output "replica_dns_name" {
  description = "DNS name of the replica db"
  value       = var.create_replica ? module.replica[0].db_instance_address : ""
}

