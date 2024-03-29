terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  count             = var.cpu_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} CPU too high"
  ok_actions        = var.cpu_sns_arns
  alarm_actions     = var.cpu_sns_arns
  actions_enabled   = length(var.cpu_sns_arns) > 0
  alarm_description = "CPU Util should not stay sustained too high"
  metric_name       = "CPUUtilization"
  namespace         = "AWS/RDS"
  statistic         = "Maximum"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.cpu_period
  evaluation_periods  = var.cpu_evaluation_periods
  datapoints_to_alarm = var.cpu_datapoints_to_alarm
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "disk_free" {
  count             = var.disk_free_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} disk free space too low"
  ok_actions        = var.disk_free_sns_arns
  alarm_actions     = var.disk_free_sns_arns
  actions_enabled   = length(var.disk_free_sns_arns) > 0
  alarm_description = "Disk space should be auto-scaled so there may be something wrong"
  metric_name       = "FreeStorageSpace"
  namespace         = "AWS/RDS"
  statistic         = "Minimum"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.disk_free_period
  evaluation_periods  = var.disk_free_evaluation_periods
  datapoints_to_alarm = var.disk_free_datapoints_to_alarm
  threshold           = var.disk_free_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  count             = var.replica_lag_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} - lag too high"
  ok_actions        = var.replica_lag_sns_arns
  alarm_actions     = var.replica_lag_sns_arns
  actions_enabled   = length(var.replica_lag_sns_arns) > 0
  alarm_description = "RDS replication should not fall too far behind for an extended period of time"
  metric_name       = "ReplicaLag"
  namespace         = "AWS/RDS"
  statistic         = "Maximum"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.replica_lag_period
  evaluation_periods  = var.replica_lag_evaluation_periods
  datapoints_to_alarm = var.replica_lag_datapoints_to_alarm
  threshold           = var.replica_lag_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  count             = var.disk_queue_depth_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} disk queue depth too high"
  ok_actions        = var.disk_queue_depth_sns_arns
  alarm_actions     = var.disk_queue_depth_sns_arns
  actions_enabled   = length(var.disk_queue_depth_sns_arns) > 0
  alarm_description = "Queue depth being too high means the DB is not able to keep up with its workload"
  metric_name       = "DiskQueueDepth"
  namespace         = "AWS/RDS"
  statistic         = "Average"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.disk_queue_depth_period
  evaluation_periods  = var.disk_queue_depth_evaluation_periods
  datapoints_to_alarm = var.disk_queue_depth_datapoints_to_alarm
  threshold           = var.disk_queue_depth_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "read_iops" {
  count             = var.read_iops_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} read iops too high"
  ok_actions        = var.read_iops_sns_arns
  alarm_actions     = var.read_iops_sns_arns
  actions_enabled   = length(var.read_iops_sns_arns) > 0
  alarm_description = "Check performance insights for missing indexes or query volume"
  metric_name       = "ReadIOPS"
  namespace         = "AWS/RDS"
  statistic         = "Average"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.read_iops_period
  evaluation_periods  = var.read_iops_evaluation_periods
  datapoints_to_alarm = var.read_iops_datapoints_to_alarm
  threshold           = var.read_iops_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "write_iops" {
  count             = var.write_iops_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} write iops too high"
  ok_actions        = var.write_iops_sns_arns
  alarm_actions     = var.write_iops_sns_arns
  actions_enabled   = length(var.write_iops_sns_arns) > 0
  alarm_description = "Check performance insights for missing indexes or query volume"
  metric_name       = "WriteIOPS"
  namespace         = "AWS/RDS"
  statistic         = "Average"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.write_iops_period
  evaluation_periods  = var.write_iops_evaluation_periods
  datapoints_to_alarm = var.write_iops_datapoints_to_alarm
  threshold           = var.write_iops_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "burst_balance" {
  count             = var.burst_balance_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} EBS burst balance too low"
  ok_actions        = var.burst_balance_sns_arns
  alarm_actions     = var.burst_balance_sns_arns
  actions_enabled   = length(var.burst_balance_sns_arns) > 0
  alarm_description = "Too low is critical and DB performance can drastically degrade"
  metric_name       = "BurstBalance"
  namespace         = "AWS/RDS"
  statistic         = "Average"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.burst_balance_period
  evaluation_periods  = var.burst_balance_evaluation_periods
  datapoints_to_alarm = var.burst_balance_datapoints_to_alarm
  threshold           = var.burst_balance_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "memory_free" {
  count             = var.memory_free_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} freeable memory too low"
  ok_actions        = var.memory_free_sns_arns
  alarm_actions     = var.memory_free_sns_arns
  actions_enabled   = length(var.memory_free_sns_arns) > 0
  alarm_description = "DB eating into swapspace and is not healthy. Should be investigated"
  metric_name       = "FreeableMemory"
  namespace         = "AWS/RDS"
  statistic         = "Minimum"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.memory_free_period
  evaluation_periods  = var.memory_free_evaluation_periods
  datapoints_to_alarm = var.memory_free_datapoints_to_alarm
  threshold           = var.memory_free_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "load" {
  count             = var.load_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} load too high"
  ok_actions        = var.load_sns_arns
  alarm_actions     = var.load_sns_arns
  actions_enabled   = length(var.load_sns_arns) > 0
  alarm_description = "There are a high number of active sessions. This may indicate many transactions are blocked"
  metric_name       = "DBLoad"
  namespace         = "AWS/RDS"
  statistic         = "Average"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.load_period
  evaluation_periods  = var.load_evaluation_periods
  datapoints_to_alarm = var.load_datapoints_to_alarm
  threshold           = var.load_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "connections_low" {
  count             = var.connections_low_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} conn count too low"
  ok_actions        = var.connections_low_sns_arns
  alarm_actions     = var.connections_low_sns_arns
  actions_enabled   = length(var.connections_low_sns_arns) > 0
  alarm_description = "If connections dip for even 15 minutes, likely there is a connection issue or DB is dead"
  metric_name       = "DatabaseConnections"
  namespace         = "AWS/RDS"
  statistic         = "Sum"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.connections_low_period
  evaluation_periods  = var.connections_low_evaluation_periods
  datapoints_to_alarm = var.connections_low_datapoints_to_alarm
  threshold           = var.connections_low_threshold
  comparison_operator = "LessThanThreshold"
}

resource "aws_cloudwatch_metric_alarm" "connections_high" {
  count             = var.connections_high_disabled ? 0 : 1
  alarm_name        = "${var.alarm_prefix} conn count too high"
  ok_actions        = var.connections_high_sns_arns
  alarm_actions     = var.connections_high_sns_arns
  actions_enabled   = length(var.connections_high_sns_arns) > 0
  alarm_description = "Too many connections for extended period of time likely means either leaking or DB is processing queries too slowly"
  metric_name       = "DatabaseConnections"
  namespace         = "AWS/RDS"
  statistic         = "Average"
  dimensions = {
    DBInstanceIdentifier = var.db_identifier
  }
  period              = var.connections_high_period
  evaluation_periods  = var.connections_high_evaluation_periods
  datapoints_to_alarm = var.connections_high_datapoints_to_alarm
  threshold           = var.connections_high_threshold
  comparison_operator = "GreaterThanThreshold"
}
