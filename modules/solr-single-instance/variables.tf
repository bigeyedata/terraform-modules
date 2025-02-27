variable "subnet_id" {
  description = "VPC subnet where this instance will run."
  type        = string
}

variable "lb_subnet_ids" {
  description = "VPC subnets for ALB attachments."
  type        = list(string)
}

variable "instance" {
  description = "Name of the environment instance."
  type        = string
}

variable "name" {
  description = "Name of this service instance."
  type        = string
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

variable "ebs_volume_size" {
  type    = string
  default = 100
}
variable "ebs_volume_iops" {
  description = "Set iops to the value supported by your instance type. https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html"
  type    = number
  default = 3000
}

variable "ebs_volume_throughput" {
  description = "Set throughput to the value supported by your instance type. https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html"
  type    = number
  default = 125
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
