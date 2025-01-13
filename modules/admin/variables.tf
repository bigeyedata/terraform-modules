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
  description = "Cloudwatch log group name to write container logs.  If var.awsfirelens_enabled = true, container logs are shipped via AWS firelens and not cloudwatch.  The AWS firelens side car container though is the exception and will continue to send logs to cloudwatch logs even if var.awsfirelens_enabled = true to facilitate debugging firelens issues."
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

variable "efs_volume_id" {
  description = "Use in conjunction with var.access_point_id to mount an EFS volume on the app container"
  type        = string
  default     = ""
}

variable "efs_access_point_id" {
  description = "Use in conjunction with var.efs_volume_id to mount an EFS volume on the app container"
  type        = string
  default     = ""
}

variable "efs_mount_point" {
  description = "Container path where the EFS volume will be mounted."
  type        = string
  default     = ""
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

variable "backfillwork_domain_name" {
  description = "backfillwork domain name"
  type        = string
}

variable "datawork_domain_name" {
  description = "datawork domain name"
  type        = string
}

variable "indexwork_domain_name" {
  description = "indexwork domain name"
  type        = string
}

variable "lineagework_domain_name" {
  description = "lineagework domain name"
  type        = string
}

variable "metricwork_domain_name" {
  description = "metricwork domain name"
  type        = string
}

variable "rootcause_domain_name" {
  description = "rootcause domain name"
  type        = string
}

variable "internalapi_domain_name" {
  description = "internalapi domain name"
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

variable "backfillwork_resource_name" {
  description = "backfillwork resource name"
  type        = string
}

variable "datawork_resource_name" {
  description = "datawork resource name"
  type        = string
}

variable "indexwork_resource_name" {
  description = "indexwork resource name"
  type        = string
}

variable "lineagework_resource_name" {
  description = "lineagework resource name"
  type        = string
}

variable "metricwork_resource_name" {
  description = "metricwork resource name"
  type        = string
}

variable "rootcause_resource_name" {
  description = "rootcause resource name"
  type        = string
}

variable "internalapi_resource_name" {
  description = "internalapi resource name"
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

variable "task_iam_role_arn" {
  description = "The ECS Task IAM Role, will create if not specified"
  type        = string
  default     = ""
}

#======================================================
# AWS Firelens settings
#======================================================
variable "awsfirelens_enabled" {
  description = "Whether to include the awsfirelens container in the task definition"
  type        = bool
  default     = false
}

variable "awsfirelens_image" {
  description = "The full image for aws firelens, e.g. registry-host-name.com/repository/name:tag.  It is recommended to pin this to a specific tag for production systems vs relying on latest."
  type        = string
  default     = ""
}

variable "awsfirelens_cpu" {
  description = "The amount of CPU to allocate to the AWS firelens container, in Mhz, e.g. 256"
  type        = number
  default     = null
}

variable "awsfirelens_memory" {
  description = "The amount of Memory to allocate to the AWS firelens container, in MiB, e.g. 512"
  type        = number
  default     = null
}

variable "awsfirelens_host" {
  description = "The hostname of the destination for awsfirelens to deliver logs to.  Example: logs-endpoint.example.com"
  type        = string
  default     = ""
}

variable "awsfirelens_uri" {
  description = "The URI of the destination for awsfirelens to deliver logs to.  Example: /receiver/v1/http/<token>"
  type        = string
  default     = ""
}
