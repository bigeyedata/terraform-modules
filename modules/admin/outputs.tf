output "client_security_group_id" {
  value       = aws_security_group.client.id
  description = "Id for security group that allows all traffic from troubleshooting instance"
}
