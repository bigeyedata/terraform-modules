variable "subnet" {
  description = "VPC subnet where this instance will run."
  type        = string
}

variable "resource_name" {
  description = "This name will be used by all managed resource."
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
