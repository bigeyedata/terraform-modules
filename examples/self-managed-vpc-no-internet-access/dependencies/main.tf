terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33.0"
    }
  }
}

provider "aws" {
  # Configure your provider accordingly
  # e.g.
  # region = "<your region here>"
  # access_key = "<your access key - IAM Role is recommended instead>"
  # secret_key = "<your secret key - IAM Role is recommended instead>"
}

locals {
  bucket_prefix = "bigeye-install"
}

resource "aws_s3_bucket" "public_dependencies" {
  bucket = format("%s-public-dependencies", local.bucket_prefix)
}

resource "aws_s3_bucket_versioning" "public_dependencies" {
  bucket = aws_s3_bucket.public_dependencies.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_dependencies" {
  bucket                  = aws_s3_bucket.public_dependencies.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "public_dependencies" {
  bucket = aws_s3_bucket.public_dependencies.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket" "private_dependencies" {
  bucket = format("%s-private-dependencies", local.bucket_prefix)
}

resource "aws_s3_bucket_versioning" "private_dependencies" {
  bucket = aws_s3_bucket.private_dependencies.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "private_dependencies" {
  bucket                  = aws_s3_bucket.private_dependencies.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "public_dependencies_bucket_name" {
  value = aws_s3_bucket.public_dependencies.id
}

output "private_dependencies_bucket_name" {
  value = aws_s3_bucket.private_dependencies.id
}

