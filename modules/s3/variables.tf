variable "name" {
  description = "The name of the s3 bucket"
  type        = string
}

variable "tags" {
  description = "A set of tags to apply"
  type        = map(string)
  default     = {}
}

variable "retention_days" {
  description = "Retention period in days"
  type        = number
  validation {
    condition     = var.retention_days > 0
    error_message = "retention_days must be a positive integer."
  }
}

variable "random_bucket_name_suffix_enabled" {
  description = <<EOF
This appends a random suffix to the end of the bucket name.  Disabling is not recommended due to potential S3 bucket
name collisions and should only be disabled to support legacy bucket names
EOF
  type        = bool
  default     = true
}
