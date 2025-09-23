terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22.0, < 6.0.0"
    }
  }
}

resource "random_string" "this" {
  count   = var.random_bucket_name_suffix_enabled ? 1 : 0
  length  = 8
  special = false
  numeric = false
  upper   = false
}

resource "aws_s3_bucket" "this" {
  bucket = format("%s%s", var.name, var.random_bucket_name_suffix_enabled ? "-${random_string.this[0].result}" : "")
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    id     = "ExpireOld"
    status = "Enabled"
    expiration {
      days = var.retention_days
    }
    noncurrent_version_expiration {
      noncurrent_days = var.retention_days
    }
    filter {}
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}
