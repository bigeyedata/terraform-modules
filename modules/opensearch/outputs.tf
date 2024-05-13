output "dns_name" {
  value       = aws_opensearch_domain.this.endpoint
  description = "dns hostname for opensearch"
}

output "domain_arn" {
  description = "ARN for the opensearch domain"
  value       = aws_opensearch_domain.this.arn
}
