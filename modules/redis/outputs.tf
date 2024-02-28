output "cluster_id" {
  description = "ID of the redis cluster"
  value       = aws_elasticache_replication_group.this.id
}
output "primary_endpoint_dns_name" {
  description = "DNS name of the primary endpoint"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "port" {
  description = "Port for the redis cache endpoint"
  value       = aws_elasticache_replication_group.this.port
}

output "client_security_group_id" {
  description = "The security group ID for redis clients"
  value       = var.create_security_groups ? aws_security_group.client[0].id : ""
}
