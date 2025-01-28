variable "solr_subnet" {
  description = "VPC subnet where this instance will run."
  type        = string
}

variable "alb_subnets" {
  description = "VPC subnets for ALB attachments."
  type        = list(string)
}

variable "env_instance_name" {
  description = "Name of the environment instance."
  type        = string
}

variable "service_name" {
  description = "Name of this service instance."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security group will be created."
  type        = string
}

variable "solr_clients_sgs" {
  description = "List of security group IDs that will have access to this solr server."
  type        = list(string)
  default     = []
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
  type    = number
  default = 8983
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

variable "service_discovery_private_dns_namespace_name" {
  description = "Service Discovery Private DNS Namespace ID."
  type        = string
}
