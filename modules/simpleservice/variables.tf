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

variable "lb_additional_ingress_cidrs" {
  description = "A list of additional cidrs to apply to the load balancer"
  type        = list(string)
  default     = []
}

variable "task_additional_ingress_cidrs" {
  description = "A list of additional cidrs to apply to the task"
  type        = list(string)
  default     = []
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

variable "control_desired_count" {
  description = "whether to control the desired count. If autoscaling, this should be false. Otherwise it should be true. If you change this value, you will need to run 'terraform state mv' to move resource from the controlled_count resource to uncontrolled_count"
  type        = bool
  default     = true
}

variable "cpu" {
  description = "The number of CPU units required by the Fargate task, e.g. 2. See - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size"
  type        = number
}

variable "memory" {
  description = "The amount of memory required by the Fargate task, in MiB, e.g. 4096. See - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-tasks-services.html#fargate-tasks-size"
  type        = number
}

variable "stop_timeout" {
  description = "Duration in seconds to wait before container is killed if it doesn't exit on its own. Max is 120"
  type        = number
  default     = null
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

variable "enable_execute_command" {
  description = "Whether or not to enable executing commands"
  type        = bool
  default     = false
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
  description = "Cloudwatch log group name to write container logs.  If var.awsfirelens_enabled = true, container logs are shipped via AWS firelens and not cloudwatch.  The AWS firelens side car container though is the exception and will continue to send logs to cloudwatch logs even if var.awsfirelens_enabled = true to facilitate debugging firelens issues."
  type        = string
}

variable "fargate_version" {
  description = "The ECS fargate version"
  type        = string
  default     = "1.4.0"
}

variable "spot_instance_config" {
  description = "Increase the spot_weight to control the ratio of spot instances to use on ECS.  spot_base_count should not exceed *_desired_count.  Typically anything above 2 will be a configuration mistake"
  type = object({
    on_demand_weight = number
    spot_weight      = number
  })
  default = {
    on_demand_weight = 1
    spot_weight      = 0
  }
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

variable "availability_zone_rebalancing" {
  description = "Set to DISABLED or ENABLED to let ECS redistribute tasks across AZs if there ends up being an imbalance due to spot removals/failures etc"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.availability_zone_rebalancing)
    error_message = "availability_zone_rebalancing must be either ENABLED or DISABLED"
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

#======================================================
# Load balancer settings
#======================================================
variable "centralized_lb_security_group_ids" {
  description = "This is the SG attached to the LB being passed in.  It needs to be attached to the ECS service to allow access from the LB"
  type        = list(string)
  default     = []
}

variable "centralized_lb_arn" {
  description = "external LB to import and create target groups and listeners for"
  type        = string
}

variable "centralized_lb_https_listener_rule_arn" {
  description = "external LB listener to attach a routing rule for.  The routing rule will be based on hostname of this service"
  type        = string
  default     = ""
}

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

variable "healthcheck_healthy_threshold" {
  description = "Number of successful healthchecks required to mark app as healthy"
  type        = number
  default     = 2
}

variable "healthcheck_unhealthy_threshold" {
  description = "Number of failed healthchecks required to mark app as unhealthy"
  type        = number
  default     = 10
}

variable "healthcheck_timeout" {
  description = "Timeout in seconds for healthcheck"
  type        = number
  default     = 10
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

variable "load_balancing_anomaly_mitigation" {
  description = "Enable Anomaly mitigation LB algorithm on target groups.  LeastOutstandingRequests routing algorithm is used if set to false.  Cannot be used with session stickiness"
  type        = bool
  default     = true
}

variable "create_dns_records" {
  description = "Whether to set up DNS records"
  type        = bool
  default     = false
}

variable "dns_name" {
  description = <<EOD
    Service DNS name. It will be used to create a CNAME pointing at the LB
    If var.create_dns_records = false this name will be directly plugged in the output.dns_name
  EOD
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "ID of the route53 zone in which RRs should be created. "
  default     = ""
}
