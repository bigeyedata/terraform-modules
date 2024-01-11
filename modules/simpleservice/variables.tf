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
  description = "The VPC ID that the resources belong, should be the owner of the subnet_ids and alb_subnet_ids"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC, used for making security groups"
  type        = string
}

variable "create_security_groups" {
  description = "Whether to create security groups"
  type        = bool
  default     = true
}

variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

#======================================================
# Application settings
#======================================================
variable "traffic_port" {
  description = "The port that the application receives traffic"
  type        = number
}

variable "environment_variables" {
  description = "A map of environment variables to pass into the task"
  type        = map(string)
  default     = {}
}

variable "secret_arns" {
  description = "A map of secret names and their respective ASM Secret name"
  type        = map(string)
  default     = {}
}

variable "desired_count" {
  description = "The desired count of the tasks"
  type        = number
}

variable "cpu" {
  description = "The number of CPU units required by the Fargate task, e.g. 2. See - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size"
  type        = number
}

variable "memory" {
  description = "The amount of memory required by the Fargate task, in MiB, e.g. 4096. See - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size"
  type        = number
}

variable "task_role_arn" {
  description = "The ARN of the role the task should use"
  type        = string
  default     = null
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

variable "subnet_ids" {
  description = "List of subnet IDs to run the application in"
  type        = list(string)
}

variable "additional_security_group_ids" {
  description = "List of additional security group IDs to give to the application"
  type        = list(string)
  default     = []
}

variable "docker_labels" {
  description = "Additional labels to apply to the container"
  type        = map(string)
  default     = {}
}

variable "cloudwatch_log_group_name" {
  description = "Cloudwatch log group name to write container logs"
  type        = string
}

variable "fargate_version" {
  description = "The ECS fargate version"
  type        = string
  default     = "1.4.0"
}

variable "on_demand_base_count" {
  description = "For scaling, this is the base amount of on-demand instances to use before using spot"
  type        = number
  default     = 1
}

variable "on_demand_weight" {
  description = "How much to weigh on-demand instances"
  type        = number
  default     = 1
}

variable "spot_base_count" {
  description = "For scaling, this is the base amount of spot instances"
  type        = number
  default     = 0
}

variable "spot_weight" {
  description = "How much to weigh spot instances"
  type        = number
  default     = 0
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

variable "datadog_agent_api_key" {
  description = "The DataDog API key to use for the datadog agent"
  type        = string
  sensitive   = true
  default     = ""
}

#======================================================
# Load balancer settings
#======================================================
variable "internet_facing" {
  description = "Whether the load balancer will be internet facing"
  type        = bool
  default     = false
}

variable "healthcheck_grace_period" {
  description = "Seconds task is allowed to fail after start before ELB considers it failing"
  type        = number
  default     = 0
}

variable "healthcheck_path" {
  description = "The path to check health for the service, e.g. /health"
  type        = string
}

variable "healthcheck_interval" {
  description = "Seconds between healthchecks"
  type        = number
  default     = 30
}

variable "ssl_policy" {
  description = "The SSL Policy to use for TLS termination"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN pointing to the certificate to terminate HTTPS traffic"
  type        = string
}

variable "lb_subnet_ids" {
  description = "A list of subnet IDs to house the load balancer"
  type        = list(string)
}

variable "lb_additional_security_group_ids" {
  description = "A list of additional security group ids to put on the load balancer"
  type        = list(string)
  default     = []
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

variable "lb_idle_timeout" {
  description = "The idle timeout in seconds"
  type        = number
  default     = 60
}

variable "lb_stickiness_enabled" {
  description = "Whether or not to use sticky cookies"
  type        = bool
  default     = false
}

variable "lb_deregistration_delay" {
  description = "The number of seconds the load balancer will drain the target"
  type        = number
  default     = 60
}
