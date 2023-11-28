variable "name" {
  description = "Name of the RabbitMQ broker"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to launch into"
  type        = string
}

variable "create_security_groups" {
  description = "Whether or not to create the security groups"
  type        = bool
  default     = true
}

variable "extra_security_groups" {
  description = "List of extra security group ids for the RabbitMQ Broker to use"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet ids for the RabbitMQ Broker to run in"
  type        = list(string)
}

variable "user_name" {
  description = "User name to interact with the queue"
  type        = string
  sensitive   = true
}

variable "user_password_secret_arn" {
  description = "ASM Secret arn for user password to interact with the queue"
  type        = string
}

variable "deployment_mode" {
  description = "Deployment mode of the broker. See - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker#deployment_mode"
  type        = string
  default     = "SINGLE_INSTANCE"
}

variable "instance_type" {
  description = "The instance type of the RabbitMQ broker"
  type        = string
  default     = "mq.t3.micro"
}

variable "engine_version" {
  description = "Engine version for RabbitMQ. See - https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/rabbitmq-version-management.html"
  type        = string
  default     = "3.11.20"
}

variable "maintenance_day" {
  description = "The day of week to schedule maintenance, e.g. WEDNESDAY"
  type        = string
  default     = "WEDNESDAY"
}

variable "maintenance_time" {
  description = "The time of day, in UTC, to schedule maintenance, e.g. 22:00"
  type        = string
  default     = "22:00"
}

variable "tags" {
  description = "A set of tags to apply"
  type        = map(string)
  default     = {}
}
