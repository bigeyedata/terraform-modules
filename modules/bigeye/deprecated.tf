output "models_bucket_name" {
  description = "DEPRECATED - S3 bucket name for models"
  value       = module.s3_buckets["models"].id
}

output "models_bucket_arn" {
  description = "DEPRECATED - ARN for models bucket"
  value       = module.s3_buckets["models"].arn
}

output "large_payload_bucket_name" {
  description = "DEPRECATED - S3 bucket name for large payloads"
  value       = module.s3_buckets["large-payload"].id
}

output "large_payload_bucket_arn" {
  description = "DEPRECATED - ARN for large payloads bucket"
  value       = module.s3_buckets["large-payload"].arn
}

moved {
  from = aws_s3_bucket.models
  to   = module.s3_buckets["models"].aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.models
  to   = module.s3_buckets["models"].aws_s3_bucket_lifecycle_configuration.this
}

moved {
  from = aws_s3_bucket_public_access_block.models
  to   = module.s3_buckets["models"].aws_s3_bucket_public_access_block.this
}

moved {
  from = random_string.models_bucket_suffix
  to   = module.s3_buckets["models"].random_string.this[0]
}

moved {
  from = aws_s3_bucket.large_payload
  to   = module.s3_buckets["large-payload"].aws_s3_bucket.this
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.large_payload
  to   = module.s3_buckets["large-payload"].aws_s3_bucket_lifecycle_configuration.this
}

moved {
  from = aws_s3_bucket_public_access_block.large_payload
  to   = module.s3_buckets["large-payload"].aws_s3_bucket_public_access_block.this
}

moved {
  from = random_string.large_payload
  to   = module.s3_buckets["large-payload"].random_string.this[0]
}
