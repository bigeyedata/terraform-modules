variable "alarm_prefix" {
  description = "The text to prefix the alarms with"
  type        = string
}

variable "db_identifier" {
  description = "The DB Identifier"
  type        = string
}


variable "burst_balance_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "burst_balance_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "burst_balance_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "burst_balance_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "burst_balance_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "burst_balance_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
}


variable "connections_high_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "connections_high_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "connections_high_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "connections_high_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "connections_high_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = []
}

variable "connections_high_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 150
}


variable "connections_low_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "connections_low_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "connections_low_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "connections_low_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "connections_low_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = []
}

variable "connections_low_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 5
}


variable "cpu_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "cpu_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "cpu_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "cpu_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "cpu_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "cpu_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
}


variable "disk_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "disk_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "disk_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "disk_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "disk_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "disk_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
}


variable "disk_queue_depth_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "disk_queue_depth_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "disk_queue_depth_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "disk_queue_depth_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "disk_queue_depth_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "disk_queue_depth_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
}


variable "load_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "load_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "load_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "load_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "load_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "load_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
}


variable "memory_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "memory_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "memory_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "memory_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "memory_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "memory_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
}


variable "read_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "read_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "read_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "read_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "read_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "read_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
}


variable "replica_lag_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "replica_lag_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "replica_lag_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "replica_lag_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "replica_lag_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = []
}

variable "replica_lag_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 3600
}


variable "write_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
}

variable "write_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
}

variable "write_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
}

variable "write_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
}

variable "write_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
}

variable "write_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
}
