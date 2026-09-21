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

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[0]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["scheduler"]
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[1]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["datawatch"]
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[2]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["datawork"]
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[3]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["lineagework"]
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[4]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["metricwork"]
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[5]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["internalapi"]
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[6]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["indexwork"]
}

moved {
  from = module.redis.aws_vpc_security_group_ingress_rule.other_sgs[7]
  to   = module.redis.aws_vpc_security_group_ingress_rule.other_sgs["backfillwork"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[0]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs["datawatch"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[1]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs["datawork"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[2]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs["lineagework"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[3]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs["metricwork"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[4]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs["internalapi"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[5]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs["indexwork"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[6]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs["backfillwork"]
}

moved {
  from = module.temporal_rds.aws_vpc_security_group_ingress_rule.other_sgs[0]
  to   = module.temporal_rds.aws_vpc_security_group_ingress_rule.other_sgs["temporal"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[0]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs["datawatch"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[1]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs["datawork"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[2]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs["lineagework"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[3]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs["metricwork"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[4]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs["internalapi"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[5]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs["indexwork"]
}

moved {
  from = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[6]
  to   = module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs["backfillwork"]
}

# The temporal opensearch ingress rules were keyed by position until v28.0.1.
# Removing an app from the middle of that list shifted every rule after it,
# which turned a delete into a replace and let the retired app's security group
# deletion race its own ingress rule (see the v28.0.0 lineageapi removal).
# Index 6 (lineageapi) is deliberately not mapped: leaving it unmoved makes it a
# genuine destroy, which terraform orders ahead of the security group deletion.

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[0]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["temporal"]
}

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[1]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["backfillwork"]
}

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[2]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["datawatch"]
}

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[3]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["datawork"]
}

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[4]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["indexwork"]
}

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[5]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["internalapi"]
}

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[7]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["lineagework"]
}

moved {
  from = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https[8]
  to   = module.temporal_opensearch[0].aws_vpc_security_group_ingress_rule.temporal_https["metricwork"]
}
