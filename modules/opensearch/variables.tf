variable "name" {
  description = "The stack name, this is given to the opensearch domain, and prefixes other resources"
  type        = string
}

variable "vpc_id" {
  description = "the VPC ID to create the security groups in"
  type        = string
}

variable "tags" {
  description = "A list of tags to apply resources"
  type        = map(string)
  default     = {}
}

variable "create_security_groups" {
  description = "whether or not to create security groups"
  type        = bool
  default     = true
}

variable "ingress_security_group_ids" {
  description = "The list of security group ids to grant ingress to"
  type        = list(string)
  default     = []
}

variable "extra_security_group_ids" {
  description = "A list of additional security group IDs to apply to the opensearch domain"
  type        = list(string)
  default     = []
}

variable "additional_ingress_cidrs" {
  description = "A list of additional cidrs to make ingress rules for"
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "The opensearch version to use"
  type        = string
}

variable "instance_type" {
  description = "The opensearch instance type to use"
  type        = string
}

variable "instance_count" {
  description = "The number of data nodes"
  type        = number
}

variable "master_nodes_enabled" {
  description = "Whether to enable master nodes"
  type        = bool
}

variable "master_node_instance_type" {
  description = "instance type for master nodes"
  type        = string
}

variable "subnet_ids" {
  description = "list of subnet ids to launch in to"
  type        = list(string)
}

variable "master_user_name" {
  description = "User name for the master user"
  type        = string
  default     = "temporal"
}
variable "master_user_password" {
  description = "the password for the master user"
  sensitive   = true
  type        = string
}

variable "ebs_throughput" {
  description = "The EBS provisioned throughput"
  type        = number
  default     = 125
}

variable "ebs_iops" {
  description = "The EBS provisioned IOPS"
  type        = number
  default     = 3000
}

variable "ebs_size" {
  description = "The provisioned volume size in GB for the data nodes"
  type        = number
  default     = 100
}

