output "dns_name" {
  value       = aws_opensearch_domain.this.endpoint
  description = "dns hostname for opensearch"
}

output "domain_arn" {
  description = "ARN for the opensearch domain"
  value       = aws_opensearch_domain.this.arn
}

output "master_user_name" {
  description = "User name for opensearch"
  value       = var.master_user_name
}
