variable "enabled" {
  description = "Whether to enable the admin container"
  type        = bool
}

variable "stack_name" {
  description = "The stack name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the application is installed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to place the admin container"
  type        = list(string)
}

variable "image" {
  description = "The image to use"
  type        = string
}

variable "tags" {
  description = "AWS tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "the cluster to put this into"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Where to send cloudwatch logs"
  type        = string
}

variable "fargate_version" {
  description = "The fargate version"
  type        = string
  default     = "1.4.0"
}

variable "execution_role_arn" {
  description = "The ECS execution role arn"
  type        = string
}

### Info we need for environment variables
variable "haproxy_domain_name" {
  description = "haproxy domain name"
  type        = string
}

variable "web_domain_name" {
  description = "web domain name"
  type        = string
}

variable "monocle_domain_name" {
  description = "monocle domain name"
  type        = string
}

variable "toretto_domain_name" {
  description = "toretto domain name"
  type        = string
}

variable "temporal_domain_name" {
  description = "temporal domain name"
  type        = string
}

variable "temporalui_domain_name" {
  description = "temporalui domain name"
  type        = string
}

variable "datawatch_domain_name" {
  description = "datawatch domain name"
  type        = string
}

variable "datawork_domain_name" {
  description = "datawork domain name"
  type        = string
}

variable "metricwork_domain_name" {
  description = "metricwork domain name"
  type        = string
}

variable "scheduler_domain_name" {
  description = "scheduler domain name"
  type        = string
}

variable "haproxy_resource_name" {
  description = "haproxy resource name"
  type        = string
}

variable "web_resource_name" {
  description = "web resource name"
  type        = string
}

variable "monocle_resource_name" {
  description = "monocle resource name"
  type        = string
}

variable "toretto_resource_name" {
  description = "toretto resource name"
  type        = string
}

variable "temporal_resource_name" {
  description = "temporal resource name"
  type        = string
}

variable "temporalui_resource_name" {
  description = "temporalui resource name"
  type        = string
}

variable "datawatch_resource_name" {
  description = "datawatch resource name"
  type        = string
}

variable "datawork_resource_name" {
  description = "datawork resource name"
  type        = string
}

variable "metricwork_resource_name" {
  description = "metricwork resource name"
  type        = string
}

variable "scheduler_resource_name" {
  description = "scheduler resource name"
  type        = string
}

variable "datawatch_rds_identifier" {
  description = "datawatch rds identifier"
  type        = string
}

variable "datawatch_rds_hostname" {
  description = "datawatch rds hostname"
  type        = string
}

variable "datawatch_rds_username" {
  description = "datawatch rds username"
  type        = string
}

variable "datawatch_rds_password_secret_arn" {
  description = "datawatch rds password secret ARN"
  type        = string
}

variable "datawatch_rds_db_name" {
  description = "datawatch rds db name"
  type        = string
}

variable "temporal_rds_identifier" {
  description = "temporal rds identifier"
  type        = string
}

variable "temporal_rds_hostname" {
  description = "temporal rds hostname"
  type        = string
}

variable "temporal_rds_username" {
  description = "temporal rds username"
  type        = string
}

variable "temporal_rds_password_secret_arn" {
  description = "temporal rds password secret ARN"
  type        = string
}

variable "temporal_rds_db_name" {
  description = "temporal rds db name"
  type        = string
}

variable "redis_domain_name" {
  description = "redis domain name"
  type        = string
}

variable "redis_password_secret_arn" {
  description = "redis password secret arn"
  type        = string
}

variable "temporal_port" {
  description = "temporal port"
  type        = number
}

variable "rabbitmq_endpoint" {
  description = "RabbitMQ endpoint"
  type        = string
}

variable "rabbitmq_username" {
  description = "RabbitMQ user name"
  type        = string
}

variable "rabbitmq_password_secret_arn" {
  description = "RabbitMQ password secret ARN"
  type        = string
}
