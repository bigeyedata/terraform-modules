variable "name" {
  description = "The name of the cache"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to launch into"
  type        = string
}

variable "subnet_group_name" {
  description = "The name of the subnet group to launch the instance in"
  type        = string
}

variable "auth_token_secret_arn" {
  description = "Secret arn for an authentication token to use with the cluster"
  type        = string
}

variable "cloudwatch_loggroup_name" {
  description = "The cloudwatch log group name to send logs to"
  type        = string
}

variable "engine_version" {
  description = "The redis cache engine to use, e.g. 6.2"
  type        = string
  default     = "6.2"
}

variable "instance_type" {
  description = "The AWS elasticache instance type to use, e.g. cache.t4g.micro"
  type        = string
  default     = "cache.t4g.micro"
}

variable "instance_count" {
  description = "The number of instances to include in the replication group"
  type        = number
  default     = 2
}

variable "create_security_groups" {
  description = "Whether to create security groups for the cache and its clients"
  type        = bool
  default     = true
}

variable "extra_security_group_ids" {
  description = "List of extra security group ids for the cache to use"
  type        = list(string)
  default     = []
}

variable "maintenance_window" {
  description = "The window of time to do maintenance, e.g. wed:01:00-wed:02:00"
  type        = string
  default     = "wed:01:00-wed:02:00"
}

variable "tags" {
  description = "A set of tags to apply"
  type        = map(string)
  default     = {}
}

