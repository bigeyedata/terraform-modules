variable "stack" {
  description = "The stack name"
  type        = string
}

variable "app" {
  description = "The app name, should not include the stack name"
  type        = string
}

#======================================================
# Mem util
#======================================================
variable "mem_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
}
