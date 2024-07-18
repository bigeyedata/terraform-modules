variable "stack" {
  description = "The stack name"
  type        = string
}

variable "low_urgency_sns_topic_arn" {
  description = "ARN of existing SNS topic to deliver low urgency alerts. If provided, a new one will not be created"
  default     = ""
  type        = string
}

variable "high_urgency_sns_topic_arn" {
  description = "ARN of existing SNS topic to deliver high urgency alerts. If provided, a new one will not be created"
  default     = ""
  type        = string
}

variable "rabbitmq_name" {
  description = "The name of the rabbitmq broker"
  type        = string
}

variable "redis_cluster_id" {
  description = "The redis cluster ID"
  type        = string
}

variable "datawatch_rds_identifier" {
  description = "The RDS identifier of the datawatch database"
  type        = string
}

variable "datawatch_rds_replica_identifier" {
  description = "The RDS identifier of the datawatch read replica database"
  type        = string
  default     = ""
}

variable "temporal_rds_identifier" {
  description = "The RDS identifier of the temporal database"
  type        = string
}

variable "redis_burst_balance_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "redis_burst_balance_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "redis_burst_balance_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "redis_burst_balance_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "redis_burst_balance_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "redis_burst_balance_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 150
}

variable "redis_cpu_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "redis_cpu_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "redis_cpu_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "redis_cpu_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "redis_cpu_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "redis_cpu_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 50
}

variable "redis_memory_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "redis_memory_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "redis_memory_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "redis_memory_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "redis_memory_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "redis_memory_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 60
}

variable "rabbitmq_message_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "rabbitmq_message_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rabbitmq_message_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "rabbitmq_message_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rabbitmq_message_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rabbitmq_message_count_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 100000
}

variable "rds_datawatch_burst_balance_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 6
}

variable "rds_datawatch_burst_balance_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_burst_balance_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_datawatch_burst_balance_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_burst_balance_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_burst_balance_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 25
}

variable "rds_datawatch_connections_high_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "rds_datawatch_connections_high_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_connections_high_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_datawatch_connections_high_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_connections_high_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_connections_high_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 150
}

variable "rds_datawatch_connections_low_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "rds_datawatch_connections_low_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_connections_low_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_datawatch_connections_low_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_connections_low_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_connections_low_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 5
}

variable "rds_datawatch_cpu_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 60
}

variable "rds_datawatch_cpu_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_cpu_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 120
}

variable "rds_datawatch_cpu_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_cpu_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_cpu_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 80
}

variable "rds_datawatch_disk_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 2
}

variable "rds_datawatch_disk_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_disk_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "rds_datawatch_disk_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "rds_datawatch_disk_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_disk_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 500000000
}

variable "rds_datawatch_disk_queue_depth_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "rds_datawatch_disk_queue_depth_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_disk_queue_depth_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_datawatch_disk_queue_depth_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_disk_queue_depth_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_disk_queue_depth_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 64
}

variable "rds_datawatch_load_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "rds_datawatch_load_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_load_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "rds_datawatch_load_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_load_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_load_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 20
}

variable "rds_datawatch_memory_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 2
}

variable "rds_datawatch_memory_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_memory_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "rds_datawatch_memory_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "rds_datawatch_memory_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_memory_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 50000000
}

variable "rds_datawatch_read_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 6
}

variable "rds_datawatch_read_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_read_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_datawatch_read_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_read_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_read_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 1000
}

variable "rds_datawatch_write_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 48
}

variable "rds_datawatch_write_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_write_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 50
}

variable "rds_datawatch_write_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_write_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_write_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 500
}

variable "rds_datawatch_replica_burst_balance_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 6
}

variable "rds_datawatch_replica_burst_balance_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_burst_balance_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_datawatch_replica_burst_balance_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_replica_burst_balance_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_burst_balance_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 25
}

variable "rds_datawatch_replica_cpu_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 60
}

variable "rds_datawatch_replica_cpu_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_cpu_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 120
}

variable "rds_datawatch_replica_cpu_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_replica_cpu_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_cpu_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 80
}

variable "rds_datawatch_replica_disk_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 2
}

variable "rds_datawatch_replica_disk_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_disk_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "rds_datawatch_replica_disk_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "rds_datawatch_replica_disk_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_disk_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 500000000
}

variable "rds_datawatch_replica_disk_queue_depth_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "rds_datawatch_replica_disk_queue_depth_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_disk_queue_depth_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_datawatch_replica_disk_queue_depth_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_replica_disk_queue_depth_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_disk_queue_depth_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 64
}

variable "rds_datawatch_replica_load_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "rds_datawatch_replica_load_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_load_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "rds_datawatch_replica_load_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_replica_load_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_load_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 20
}

variable "rds_datawatch_replica_memory_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 2
}

variable "rds_datawatch_replica_memory_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_memory_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "rds_datawatch_replica_memory_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "rds_datawatch_replica_memory_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_memory_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 50000000
}

variable "rds_datawatch_replica_read_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 24
}

variable "rds_datawatch_replica_read_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_read_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 24
}

variable "rds_datawatch_replica_read_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_replica_read_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_read_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 1000
}

variable "rds_datawatch_replica_replica_lag_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "rds_datawatch_replica_replica_lag_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_replica_lag_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "rds_datawatch_replica_replica_lag_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "rds_datawatch_replica_replica_lag_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_replica_lag_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 7200
}

variable "rds_datawatch_replica_write_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 48
}

variable "rds_datawatch_replica_write_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_datawatch_replica_write_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 50
}

variable "rds_datawatch_replica_write_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_datawatch_replica_write_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_datawatch_replica_write_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 500
}

variable "rds_temporal_burst_balance_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 6
}

variable "rds_temporal_burst_balance_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_burst_balance_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_temporal_burst_balance_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_temporal_burst_balance_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_burst_balance_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 25
}

variable "rds_temporal_cpu_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 60
}

variable "rds_temporal_cpu_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_cpu_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 120
}

variable "rds_temporal_cpu_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_temporal_cpu_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_cpu_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 80
}

variable "rds_temporal_disk_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 2
}

variable "rds_temporal_disk_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_disk_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "rds_temporal_disk_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "rds_temporal_disk_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_disk_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 500000000
}

variable "rds_temporal_disk_queue_depth_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "rds_temporal_disk_queue_depth_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_disk_queue_depth_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_temporal_disk_queue_depth_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_temporal_disk_queue_depth_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_disk_queue_depth_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 64
}

variable "rds_temporal_load_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "rds_temporal_load_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_load_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 3
}

variable "rds_temporal_load_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_temporal_load_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_load_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 20
}

variable "rds_temporal_memory_free_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 2
}

variable "rds_temporal_memory_free_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_memory_free_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "rds_temporal_memory_free_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "rds_temporal_memory_free_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_memory_free_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 100000000
}

variable "rds_temporal_read_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 6
}

variable "rds_temporal_read_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_read_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 6
}

variable "rds_temporal_read_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_temporal_read_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_read_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 1000
}

variable "rds_temporal_write_iops_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 48
}

variable "rds_temporal_write_iops_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "rds_temporal_write_iops_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 50
}

variable "rds_temporal_write_iops_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "rds_temporal_write_iops_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "rds_temporal_write_iops_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 500
}

variable "elb_datawatch_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_datawatch_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_datawatch_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "elb_datawatch_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_datawatch_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_datawatch_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 5
}

variable "elb_datawatch_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_datawatch_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_datawatch_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_datawatch_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_datawatch_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_datawatch_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_datawatch_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_datawatch_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_datawatch_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_datawatch_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_datawatch_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_datawatch_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "elb_datawork_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_datawork_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_datawork_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_datawork_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_datawork_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_datawork_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_haproxy_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_haproxy_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_haproxy_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_haproxy_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_haproxy_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_haproxy_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 40
}

variable "elb_haproxy_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_haproxy_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_haproxy_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_haproxy_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_haproxy_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_haproxy_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_haproxy_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_haproxy_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_haproxy_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_haproxy_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_haproxy_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_haproxy_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "elb_lineagework_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_lineagework_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_lineagework_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_lineagework_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_lineagework_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_lineagework_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_metricwork_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_metricwork_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_metricwork_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_metricwork_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_metricwork_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_metricwork_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_monocle_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_monocle_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_monocle_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_monocle_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_monocle_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_monocle_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 40
}

variable "elb_monocle_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_monocle_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_monocle_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_monocle_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_monocle_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_monocle_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_monocle_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_monocle_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_monocle_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_monocle_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_monocle_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_monocle_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "elb_internalapi_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_internalapi_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_internalapi_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "elb_internalapi_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_internalapi_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_internalapi_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 5
}

variable "elb_internalapi_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_internalapi_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_internalapi_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_internalapi_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_internalapi_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_internalapi_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_internalapi_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_internalapi_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_internalapi_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_internalapi_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_internalapi_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_internalapi_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "elb_scheduler_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_scheduler_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_scheduler_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_scheduler_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_scheduler_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_scheduler_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 40
}

variable "elb_scheduler_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_scheduler_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_scheduler_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_scheduler_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_scheduler_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_scheduler_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_scheduler_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_scheduler_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_scheduler_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_scheduler_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_scheduler_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_scheduler_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "elb_temporal_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_temporal_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_temporal_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_temporal_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_temporal_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_temporal_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_temporalui_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_temporalui_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_temporalui_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_temporalui_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_temporalui_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_temporalui_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 40
}

variable "elb_temporalui_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_temporalui_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_temporalui_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_temporalui_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_temporalui_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_temporalui_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_temporalui_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_temporalui_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_temporalui_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_temporalui_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_temporalui_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_temporalui_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "elb_toretto_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 2
}

variable "elb_toretto_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_toretto_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "elb_toretto_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_toretto_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_toretto_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 40
}

variable "elb_toretto_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_toretto_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_toretto_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_toretto_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_toretto_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_toretto_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_toretto_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_toretto_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_toretto_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_toretto_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_toretto_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_toretto_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "elb_web_error_rate_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_web_error_rate_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_web_error_rate_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_web_error_rate_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "elb_web_error_rate_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_web_error_rate_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 40
}

variable "elb_web_host_count_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_web_host_count_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_web_host_count_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_web_host_count_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_web_host_count_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_web_host_count_threshold" {
  description = "Alarms when the metric is below this value"
  type        = number
  default     = 0.5
}

variable "elb_web_response_time_datapoints_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 3
}

variable "elb_web_response_time_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "elb_web_response_time_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 4
}

variable "elb_web_response_time_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 900
}

variable "elb_web_response_time_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "elb_web_response_time_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 120
}

variable "ecs_datawatch_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_datawatch_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_datawatch_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_datawatch_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_datawatch_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_datawatch_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_datawork_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_datawork_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_datawork_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_datawork_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_datawork_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_datawork_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_lineagework_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_lineagework_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_lineagework_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_lineagework_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_lineagework_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_lineagework_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_metricwork_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_metricwork_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_metricwork_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_metricwork_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_metricwork_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_metricwork_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_monocle_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_monocle_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_monocle_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_monocle_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_monocle_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_monocle_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_internalapi_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_internalapi_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_internalapi_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_internalapi_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_internalapi_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_internalapi_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_scheduler_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_scheduler_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_scheduler_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_scheduler_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_scheduler_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_scheduler_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_toretto_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_toretto_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_toretto_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_toretto_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_toretto_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_toretto_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}

variable "ecs_web_mem_disabled" {
  description = "Whether to disable the specific alarm"
  type        = bool
  default     = false
}

variable "ecs_web_mem_dataponts_to_alarm" {
  description = "The number of datapoints breaching threshold to alarm"
  type        = number
  default     = 4
}

variable "ecs_web_mem_evaluation_periods" {
  description = "The number of periods over which the metric is evaluated"
  type        = number
  default     = 5
}

variable "ecs_web_mem_period" {
  description = "The number of seconds over which the metric is evaluated"
  type        = number
  default     = 300
}

variable "ecs_web_mem_sns_arns" {
  description = "The SNS topic arns to notify when the alarm fires"
  type        = list(string)
  default     = null
}

variable "ecs_web_mem_threshold" {
  description = "Alarms when the metric is above this value"
  type        = number
  default     = 70
}
