variable "stack" {
  description = "The stack name"
  type        = string
}

variable "app" {
  description = "The app name, should not include the stack name"
  type        = string
}

variable "error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = []
}

variable "error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 40
}


variable "host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
}


variable "response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = []
}

variable "response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}
