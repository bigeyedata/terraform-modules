variable "subnet_id" {
  description = "VPC subnet where this instance will run."
  type        = string
}

variable "lb_subnet_ids" {
  description = "VPC subnets for ALB attachments."
  type        = list(string)
}

variable "app" {
  description = "The app name for the service, like datawatch"
  type        = string
}

variable "instance" {
  description = "The stack instance name"
  type        = string
}

variable "stack" {
  description = "The stack name"
  type        = string
}

variable "name" {
  description = "The name to use for the service, like staging-staging-datawatch"
  type        = string
}

variable "tags" {
  description = "A map of tags to put on the resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID where security group will be created."
  type        = string
}

variable "refresh_instance_on_launch_template_change" {
  description = <<EOD
    Whether or not the instance should be recreated immediately on every template change.
    If false, existing instance will continue running but new instances will use the new template.
    Note: changes happen when AWS releases new AMI, so we don't have control over that.
  EOD
  type        = bool
  default     = false
}

variable "ecs_cluster_name" {
  type = string
}

variable "availability_zone" {
  description = "AZ in which managed resources should be created. Example: us-west-2a"
  type        = string
}

variable "ebs_volume_size_os" {
  type    = string
  default = 40
}

variable "ebs_volume_size" {
  type    = string
  default = 100
}

variable "ebs_volume_iops" {
  description = "Set iops to the value supported by your instance type. https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html"
  type        = number
  default     = 3000
}

variable "ebs_volume_throughput" {
  description = "Set throughput to the value supported by your instance type. https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html"
  type        = number
  default     = 125
}

variable "instance_type" {
  description = "EC2 instance type to use as capacity provider."
  type        = string
  default     = "t3.medium"
}

variable "acm_certificate_arn" {
  description = "ARN pointing to the certificate to terminate HTTPS traffic"
  type        = string
}

variable "solr_traffic_port" {
  description = "Default solr port is 8983, but we run it on 80."
  type        = number
  default     = 80
}

variable "solr_jmx_port" {
  description = "Solr JMX port.  Used for installs with datadog etc where solr stats can be polled from the jmx port"
  type        = number
  default     = 1099
}

variable "route53_zone_id" {
  description = "DNS record will be created in this zone."
  type        = string
  default     = ""
}

variable "dns_name" {
  description = "The name for Route53 DNS record."
  type        = string
  default     = ""
}

variable "solr_cnames" {
  description = "CNAME Route53 records that will point to the main service DNS name."
  type        = list(string)
  default     = []
}

variable "elb_access_logs_bucket_config" {
  description = "S3 bucket to send ALB logs to."
  type        = map(string)
  default     = {}
}

variable "lb_access_logs_enabled" {
  description = "A boolean indicating whether access logs are enabled"
  type        = bool
  default     = false
}

variable "lb_access_logs_bucket_name" {
  description = "The name of the bucket where ALB access logs will be sent. Required if lb_access_logs_enabled is true"
  type        = string
  default     = ""
}

variable "lb_access_logs_bucket_prefix" {
  description = "If lb_access_logs_enabled is true, this is the prefix under which access logs will be written"
  type        = string
  default     = ""
}

variable "service_discovery_private_dns_namespace_id" {
  description = "Service Discovery Private DNS Namespace ID."
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the execution role"
  type        = string
}

variable "image_registry" {
  description = "The container image registry"
  type        = string
}

variable "image_repository" {
  description = "The repository name within the registry for the container"
  type        = string
}

variable "image_tag" {
  description = "The image tag of the container"
  type        = string
}

variable "solr_opts" {
  description = "Additional options to pass to solr startup script."
  type        = list(string)
  default     = []
}

variable "desired_count" {
  description = "This variable takes only 0 or 1 and is intended to allow stopping solr service for data volume maintenance."
  type        = number
  default     = 1
  validation {
    condition     = contains([0, 1], var.desired_count)
    error_message = "The value must be either 0 or 1."
  }
}

variable "solr_heap_size" {
  description = "Amount of memory to allocate for solr heap. Will be set for -Xms and -Xmx java options. Default is 80% of instance memory."
  type        = string
  default     = ""
}

variable "secret_arns" {
  description = "A map of secret names and their respective ASM Secret name"
  type        = map(string)
  default     = {}
}

variable "docker_labels" {
  description = "Additional labels to apply to the container"
  type        = map(string)
  default     = {}
}

variable "cloudwatch_log_group_name" {
  description = "Cloudwatch log group name to write container logs.  If var.awsfirelens_enabled = true, container logs are shipped via AWS firelens and not cloudwatch.  The AWS firelens side car container though is the exception and will continue to send logs to cloudwatch logs even if var.awsfirelens_enabled = true to facilitate debugging firelens issues."
  type        = string
}

variable "environment_variables" {
  description = "A map of environment variables to pass into the task"
  type        = map(string)
  default     = {}
}

variable "solr_log_level" {
  description = "Log level for solr.  Controls the SOLR_LOG_LEVEL env var"
  type        = string
  default     = "WARN"
  validation {
    condition     = contains(["INFO", "WARN", "ERROR"], var.solr_log_level)
    error_message = "solr_log_level must be one of: INFO, WARN, ERROR"
  }
}

#======================================================
# Datadog agent settings
#======================================================
variable "datadog_agent_enabled" {
  description = "Whether to include the datadog agent container in the task definition"
  type        = bool
  default     = false
}

variable "datadog_agent_image" {
  description = "The full image for datadog, e.g. registry-host-name.com/repository/name:tag"
  type        = string
  default     = ""
}

variable "datadog_agent_cpu" {
  description = "The amount of CPU to allocate to the datadog agent, in Mhz, e.g. 256"
  type        = number
  default     = 256
}

variable "datadog_agent_memory" {
  description = "The amount of Memory to allocate to the datadog agent, in MiB, e.g. 512"
  type        = number
  default     = 512
}

variable "datadog_agent_api_key_secret_arn" {
  description = "The secret ARN for the datadog agent API key"
  type        = string
  default     = ""
}

variable "datadog_additional_docker_labels" {
  description = "Additional docker labels to use if datadog is enabled"
  type        = map(string)
  default     = {}
}

variable "datadog_agent_additional_secret_arns" {
  description = "Additional secret arns for the datadog container"
  type        = map(string)
  default     = {}
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
