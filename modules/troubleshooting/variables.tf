variable "name" {
  description = "The name of the stack, usually the environment-instance combination"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the application is installed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs to place the troubleshooting container"
  type        = list(string)
}

variable "ingress_cidr" {
  description = "The CIDR range to allow ingress from for the troubleshooting instance, i.e. YOUR IP"
  type        = string
  validation {
    condition     = var.ingress_cidr != ""
    error_message = "Must provide an ingress CIDR block for the troubleshooting instance. This should be your IP address, appended by '/32'"
  }

  validation {
    condition     = var.ingress_cidr != "0.0.0.0/0"
    error_message = "Must not allow ingress cidr for troubleshooting container to be open to the world"
  }
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
