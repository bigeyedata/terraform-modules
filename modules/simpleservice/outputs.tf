output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "The zone that the load balancer DNS is controlled"
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "The created security group ID"
  value       = var.create_security_groups ? aws_security_group.this[0].id : ""
}
