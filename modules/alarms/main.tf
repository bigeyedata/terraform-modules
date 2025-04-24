terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

}

locals {
  low_urgency_sns_topic_arn  = var.low_urgency_sns_topic_arn == "" ? aws_sns_topic.low_urgency[0].arn : var.low_urgency_sns_topic_arn
  high_urgency_sns_topic_arn = var.high_urgency_sns_topic_arn == "" ? aws_sns_topic.high_urgency[0].arn : var.high_urgency_sns_topic_arn
}

resource "aws_sns_topic" "low_urgency" {
  count = var.low_urgency_sns_topic_arn == "" ? 1 : 0
  name  = "${var.stack}-low-urgency-cloudwatch-alarm"
}

resource "aws_sns_topic" "high_urgency" {
  count = var.high_urgency_sns_topic_arn == "" ? 1 : 0
  name  = "${var.stack}-high-urgency-cloudwatch-alarm"
}

locals {
  rabbitmq_message_count_sns_arns = coalesce(var.rabbitmq_message_count_sns_arns, [local.low_urgency_sns_topic_arn])
  redis_cpu_sns_arns              = coalesce(var.redis_cpu_sns_arns, [local.low_urgency_sns_topic_arn])
  redis_burst_balance_sns_arns    = coalesce(var.redis_burst_balance_sns_arns, [local.low_urgency_sns_topic_arn])
  redis_memory_sns_arns           = coalesce(var.redis_memory_sns_arns, [local.low_urgency_sns_topic_arn])
}

resource "aws_cloudwatch_metric_alarm" "rabbitmq_message_count" {
  count               = var.rabbitmq_message_count_disabled ? 0 : 1
  alarm_name          = "${var.stack} - MQ total message count too high"
  ok_actions          = local.rabbitmq_message_count_sns_arns
  alarm_actions       = local.rabbitmq_message_count_sns_arns
  actions_enabled     = length(local.rabbitmq_message_count_sns_arns) > 0
  evaluation_periods  = coalesce(var.rabbitmq_message_count_evaluation_periods, 1)
  datapoints_to_alarm = coalesce(var.rabbitmq_message_count_datapoints_to_alarm, 1)
  threshold           = var.rabbitmq_message_count_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"
  metric_query {
    id          = "q1"
    label       = "${var.stack}_mq_message_count"
    period      = coalesce(var.rabbitmq_message_count_period, 300)
    return_data = "true"
    expression  = <<EOF
SELECT AVG(MessageCount) FROM SCHEMA("AWS/AmazonMQ", Broker) WHERE Broker = '${var.rabbitmq_name}'
and Queue != 'dataset_index_op_v2'
and Queue != 'backfill'
EOF
  }
}

resource "aws_cloudwatch_metric_alarm" "redis_cpu" {
  count             = var.redis_cpu_disabled ? 0 : 1
  alarm_name        = "${var.stack} - Redis CPU util too high"
  ok_actions        = local.redis_cpu_sns_arns
  alarm_actions     = local.redis_cpu_sns_arns
  actions_enabled   = length(local.redis_cpu_sns_arns) > 0
  alarm_description = "If this is triggering, should scale up vs trying to be HW efficient"
  metric_name       = "EngineCPUUtilization"
  namespace         = "AWS/ElastiCache"
  statistic         = "Average"
  dimensions = {
    CacheClusterId = format("%s-001", var.redis_cluster_id)
  }
  period              = coalesce(var.redis_cpu_period, 300)
  evaluation_periods  = coalesce(var.redis_cpu_evaluation_periods, 2)
  datapoints_to_alarm = coalesce(var.redis_cpu_datapoints_to_alarm, 2)
  threshold           = var.redis_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "redis_burst_balance" {
  count             = var.redis_burst_balance_disabled ? 0 : 1
  alarm_name        = "${var.stack} - Redis CPU burst balance too low"
  ok_actions        = local.redis_burst_balance_sns_arns
  alarm_actions     = local.redis_burst_balance_sns_arns
  actions_enabled   = length(local.redis_burst_balance_sns_arns) > 0
  alarm_description = "Once the CPU burst balance runs out, app response time may suffer"
  metric_name       = "CPUCreditBalance"
  namespace         = "AWS/ElastiCache"
  statistic         = "Minimum"
  dimensions = {
    CacheClusterId = format("%s-001", var.redis_cluster_id)
    CacheNodeId    = "0001"
  }
  period              = coalesce(var.redis_burst_balance_period, 300)
  evaluation_periods  = coalesce(var.redis_burst_balance_evaluation_periods, 6)
  datapoints_to_alarm = coalesce(var.redis_burst_balance_datapoints_to_alarm, 6)
  threshold           = var.redis_burst_balance_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"
}

resource "aws_cloudwatch_metric_alarm" "redis_memory" {
  count             = var.redis_memory_disabled ? 0 : 1
  alarm_name        = "${var.stack} - Redis memory util too high"
  ok_actions        = local.redis_memory_sns_arns
  alarm_actions     = local.redis_memory_sns_arns
  actions_enabled   = length(local.redis_memory_sns_arns) > 0
  alarm_description = "Increase the HW type to get more memory"
  metric_name       = "DatabaseMemoryUsagePercentage"
  namespace         = "AWS/ElastiCache"
  statistic         = "Maximum"
  dimensions = {
    CacheClusterId = format("%s-001", var.redis_cluster_id)
  }
  period              = coalesce(var.redis_memory_period, 300)
  evaluation_periods  = coalesce(var.redis_memory_evaluation_periods, 2)
  datapoints_to_alarm = coalesce(var.redis_memory_datapoints_to_alarm, 2)
  threshold           = var.redis_memory_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
}

#======================================================
# RDS Datawatch Replica
#======================================================
module "datawatch_rds" {
  source        = "./rds"
  alarm_prefix  = "${var.stack} - Datawatch DB"
  db_identifier = var.datawatch_rds_identifier

  burst_balance_disabled            = var.rds_datawatch_burst_balance_disabled
  burst_balance_datapoints_to_alarm = var.rds_datawatch_burst_balance_datapoints_to_alarm
  burst_balance_evaluation_periods  = var.rds_datawatch_burst_balance_evaluation_periods
  burst_balance_period              = var.rds_datawatch_burst_balance_period
  burst_balance_sns_arns            = coalesce(var.rds_datawatch_burst_balance_sns_arns, [local.high_urgency_sns_topic_arn])
  burst_balance_threshold           = var.rds_datawatch_burst_balance_threshold

  connections_low_disabled            = var.rds_datawatch_connections_low_disabled
  connections_low_datapoints_to_alarm = var.rds_datawatch_connections_low_datapoints_to_alarm
  connections_low_evaluation_periods  = var.rds_datawatch_connections_low_evaluation_periods
  connections_low_period              = var.rds_datawatch_connections_low_period
  connections_low_sns_arns            = coalesce(var.rds_datawatch_connections_low_sns_arns, [local.high_urgency_sns_topic_arn])
  connections_low_threshold           = var.rds_datawatch_connections_low_threshold

  connections_high_disabled            = var.rds_datawatch_connections_high_disabled
  connections_high_datapoints_to_alarm = var.rds_datawatch_connections_high_datapoints_to_alarm
  connections_high_evaluation_periods  = var.rds_datawatch_connections_high_evaluation_periods
  connections_high_period              = var.rds_datawatch_connections_high_period
  connections_high_sns_arns            = coalesce(var.rds_datawatch_connections_high_sns_arns, [local.high_urgency_sns_topic_arn])
  connections_high_threshold           = var.rds_datawatch_connections_high_threshold

  cpu_disabled            = var.rds_datawatch_cpu_disabled
  cpu_datapoints_to_alarm = var.rds_datawatch_cpu_datapoints_to_alarm
  cpu_evaluation_periods  = var.rds_datawatch_cpu_evaluation_periods
  cpu_period              = var.rds_datawatch_cpu_period
  cpu_sns_arns            = coalesce(var.rds_datawatch_cpu_sns_arns, [local.low_urgency_sns_topic_arn])
  cpu_threshold           = var.rds_datawatch_cpu_threshold

  disk_free_disabled            = var.rds_datawatch_disk_free_disabled
  disk_free_datapoints_to_alarm = var.rds_datawatch_disk_free_datapoints_to_alarm
  disk_free_evaluation_periods  = var.rds_datawatch_disk_free_evaluation_periods
  disk_free_period              = var.rds_datawatch_disk_free_period
  disk_free_sns_arns            = coalesce(var.rds_datawatch_disk_free_sns_arns, [local.high_urgency_sns_topic_arn])
  disk_free_threshold           = var.rds_datawatch_disk_free_threshold

  disk_queue_depth_disabled            = var.rds_datawatch_disk_queue_depth_disabled
  disk_queue_depth_datapoints_to_alarm = var.rds_datawatch_disk_queue_depth_datapoints_to_alarm
  disk_queue_depth_evaluation_periods  = var.rds_datawatch_disk_queue_depth_evaluation_periods
  disk_queue_depth_period              = var.rds_datawatch_disk_queue_depth_period
  disk_queue_depth_sns_arns            = coalesce(var.rds_datawatch_disk_queue_depth_sns_arns, [local.low_urgency_sns_topic_arn])
  disk_queue_depth_threshold           = var.rds_datawatch_disk_queue_depth_threshold

  load_disabled            = var.rds_datawatch_load_disabled
  load_datapoints_to_alarm = var.rds_datawatch_load_datapoints_to_alarm
  load_evaluation_periods  = var.rds_datawatch_load_evaluation_periods
  load_period              = var.rds_datawatch_load_period
  load_sns_arns            = coalesce(var.rds_datawatch_load_sns_arns, [local.low_urgency_sns_topic_arn])
  load_threshold           = var.rds_datawatch_load_threshold

  memory_free_disabled            = var.rds_datawatch_memory_free_disabled
  memory_free_datapoints_to_alarm = var.rds_datawatch_memory_free_datapoints_to_alarm
  memory_free_evaluation_periods  = var.rds_datawatch_memory_free_evaluation_periods
  memory_free_period              = var.rds_datawatch_memory_free_period
  memory_free_sns_arns            = coalesce(var.rds_datawatch_memory_free_sns_arns, [local.low_urgency_sns_topic_arn])
  memory_free_threshold           = var.rds_datawatch_memory_free_threshold

  replica_lag_disabled = true

  read_iops_disabled            = var.rds_datawatch_read_iops_disabled
  read_iops_datapoints_to_alarm = var.rds_datawatch_read_iops_datapoints_to_alarm
  read_iops_evaluation_periods  = var.rds_datawatch_read_iops_evaluation_periods
  read_iops_period              = var.rds_datawatch_read_iops_period
  read_iops_sns_arns            = coalesce(var.rds_datawatch_read_iops_sns_arns, [])
  read_iops_threshold           = var.rds_datawatch_read_iops_threshold

  write_iops_disabled            = var.rds_datawatch_write_iops_disabled
  write_iops_datapoints_to_alarm = var.rds_datawatch_write_iops_datapoints_to_alarm
  write_iops_evaluation_periods  = var.rds_datawatch_write_iops_evaluation_periods
  write_iops_period              = var.rds_datawatch_write_iops_period
  write_iops_sns_arns            = coalesce(var.rds_datawatch_write_iops_sns_arns, [local.high_urgency_sns_topic_arn])
  write_iops_threshold           = var.rds_datawatch_write_iops_threshold
}

module "temporal_rds" {
  source        = "./rds"
  alarm_prefix  = "${var.stack} - Temporal DB"
  db_identifier = var.temporal_rds_identifier

  burst_balance_disabled            = var.rds_temporal_burst_balance_disabled
  burst_balance_datapoints_to_alarm = var.rds_temporal_burst_balance_datapoints_to_alarm
  burst_balance_evaluation_periods  = var.rds_temporal_burst_balance_evaluation_periods
  burst_balance_period              = var.rds_temporal_burst_balance_period
  burst_balance_sns_arns            = coalesce(var.rds_temporal_burst_balance_sns_arns, [local.low_urgency_sns_topic_arn])
  burst_balance_threshold           = var.rds_temporal_burst_balance_threshold

  connections_low_disabled  = true
  connections_high_disabled = true

  cpu_disabled            = var.rds_temporal_cpu_disabled
  cpu_datapoints_to_alarm = var.rds_temporal_cpu_datapoints_to_alarm
  cpu_evaluation_periods  = var.rds_temporal_cpu_evaluation_periods
  cpu_period              = var.rds_temporal_cpu_period
  cpu_sns_arns            = coalesce(var.rds_temporal_cpu_sns_arns, [local.low_urgency_sns_topic_arn])
  cpu_threshold           = var.rds_temporal_cpu_threshold

  disk_free_disabled            = var.rds_temporal_disk_free_disabled
  disk_free_datapoints_to_alarm = var.rds_temporal_disk_free_datapoints_to_alarm
  disk_free_evaluation_periods  = var.rds_temporal_disk_free_evaluation_periods
  disk_free_period              = var.rds_temporal_disk_free_period
  disk_free_sns_arns            = coalesce(var.rds_temporal_disk_free_sns_arns, [local.low_urgency_sns_topic_arn])
  disk_free_threshold           = var.rds_temporal_disk_free_threshold

  disk_queue_depth_disabled            = var.rds_temporal_disk_queue_depth_disabled
  disk_queue_depth_datapoints_to_alarm = var.rds_temporal_disk_queue_depth_datapoints_to_alarm
  disk_queue_depth_evaluation_periods  = var.rds_temporal_disk_queue_depth_evaluation_periods
  disk_queue_depth_period              = var.rds_temporal_disk_queue_depth_period
  disk_queue_depth_sns_arns            = coalesce(var.rds_temporal_disk_queue_depth_sns_arns, [local.low_urgency_sns_topic_arn])
  disk_queue_depth_threshold           = var.rds_temporal_disk_queue_depth_threshold

  load_disabled            = var.rds_temporal_load_disabled
  load_datapoints_to_alarm = var.rds_temporal_load_datapoints_to_alarm
  load_evaluation_periods  = var.rds_temporal_load_evaluation_periods
  load_period              = var.rds_temporal_load_period
  load_sns_arns            = coalesce(var.rds_temporal_load_sns_arns, [local.low_urgency_sns_topic_arn])
  load_threshold           = var.rds_temporal_load_threshold

  memory_free_disabled            = var.rds_temporal_memory_free_disabled
  memory_free_datapoints_to_alarm = var.rds_temporal_memory_free_datapoints_to_alarm
  memory_free_evaluation_periods  = var.rds_temporal_memory_free_evaluation_periods
  memory_free_period              = var.rds_temporal_memory_free_period
  memory_free_sns_arns            = coalesce(var.rds_temporal_memory_free_sns_arns, [local.low_urgency_sns_topic_arn])
  memory_free_threshold           = var.rds_temporal_memory_free_threshold

  replica_lag_disabled = true

  read_iops_disabled            = var.rds_temporal_read_iops_disabled
  read_iops_datapoints_to_alarm = var.rds_temporal_read_iops_datapoints_to_alarm
  read_iops_evaluation_periods  = var.rds_temporal_read_iops_evaluation_periods
  read_iops_period              = var.rds_temporal_read_iops_period
  read_iops_sns_arns            = coalesce(var.rds_temporal_read_iops_sns_arns, [])
  read_iops_threshold           = var.rds_temporal_read_iops_threshold

  write_iops_disabled            = var.rds_temporal_write_iops_disabled
  write_iops_datapoints_to_alarm = var.rds_temporal_write_iops_datapoints_to_alarm
  write_iops_evaluation_periods  = var.rds_temporal_write_iops_evaluation_periods
  write_iops_period              = var.rds_temporal_write_iops_period
  write_iops_sns_arns            = coalesce(var.rds_temporal_write_iops_sns_arns, [local.low_urgency_sns_topic_arn])
  write_iops_threshold           = var.rds_temporal_write_iops_threshold
}

module "datawatch_rds_replica" {
  count         = length(var.datawatch_rds_replica_identifier) > 0 ? 1 : 0
  source        = "./rds"
  alarm_prefix  = "${var.stack} - DB Replica"
  db_identifier = var.datawatch_rds_replica_identifier

  burst_balance_disabled            = var.rds_datawatch_replica_burst_balance_disabled
  burst_balance_datapoints_to_alarm = var.rds_datawatch_replica_burst_balance_datapoints_to_alarm
  burst_balance_evaluation_periods  = var.rds_datawatch_replica_burst_balance_evaluation_periods
  burst_balance_period              = var.rds_datawatch_replica_burst_balance_period
  burst_balance_sns_arns            = coalesce(var.rds_datawatch_replica_burst_balance_sns_arns, [local.low_urgency_sns_topic_arn])
  burst_balance_threshold           = var.rds_datawatch_replica_burst_balance_threshold

  connections_low_disabled  = true
  connections_high_disabled = true

  cpu_disabled            = var.rds_datawatch_replica_cpu_disabled
  cpu_datapoints_to_alarm = var.rds_datawatch_replica_cpu_datapoints_to_alarm
  cpu_evaluation_periods  = var.rds_datawatch_replica_cpu_evaluation_periods
  cpu_period              = var.rds_datawatch_replica_cpu_period
  cpu_sns_arns            = coalesce(var.rds_datawatch_replica_cpu_sns_arns, [local.low_urgency_sns_topic_arn])
  cpu_threshold           = var.rds_datawatch_replica_cpu_threshold

  disk_free_disabled            = var.rds_datawatch_replica_disk_free_disabled
  disk_free_datapoints_to_alarm = var.rds_datawatch_replica_disk_free_datapoints_to_alarm
  disk_free_evaluation_periods  = var.rds_datawatch_replica_disk_free_evaluation_periods
  disk_free_period              = var.rds_datawatch_replica_disk_free_period
  disk_free_sns_arns            = coalesce(var.rds_datawatch_replica_disk_free_sns_arns, [local.low_urgency_sns_topic_arn])
  disk_free_threshold           = var.rds_datawatch_replica_disk_free_threshold

  disk_queue_depth_disabled            = var.rds_datawatch_replica_disk_queue_depth_disabled
  disk_queue_depth_datapoints_to_alarm = var.rds_datawatch_replica_disk_queue_depth_datapoints_to_alarm
  disk_queue_depth_evaluation_periods  = var.rds_datawatch_replica_disk_queue_depth_evaluation_periods
  disk_queue_depth_period              = var.rds_datawatch_replica_disk_queue_depth_period
  disk_queue_depth_sns_arns            = coalesce(var.rds_datawatch_replica_disk_queue_depth_sns_arns, [local.low_urgency_sns_topic_arn])
  disk_queue_depth_threshold           = var.rds_datawatch_replica_disk_queue_depth_threshold

  load_disabled            = var.rds_datawatch_replica_load_disabled
  load_datapoints_to_alarm = var.rds_datawatch_replica_load_datapoints_to_alarm
  load_evaluation_periods  = var.rds_datawatch_replica_load_evaluation_periods
  load_period              = var.rds_datawatch_replica_load_period
  load_sns_arns            = coalesce(var.rds_datawatch_replica_load_sns_arns, [local.low_urgency_sns_topic_arn])
  load_threshold           = var.rds_datawatch_replica_load_threshold

  memory_free_disabled            = var.rds_datawatch_replica_memory_free_disabled
  memory_free_datapoints_to_alarm = var.rds_datawatch_replica_memory_free_datapoints_to_alarm
  memory_free_evaluation_periods  = var.rds_datawatch_replica_memory_free_evaluation_periods
  memory_free_period              = var.rds_datawatch_replica_memory_free_period
  memory_free_sns_arns            = coalesce(var.rds_datawatch_replica_memory_free_sns_arns, [local.low_urgency_sns_topic_arn])
  memory_free_threshold           = var.rds_datawatch_replica_memory_free_threshold

  replica_lag_disabled            = var.rds_datawatch_replica_replica_lag_disabled
  replica_lag_datapoints_to_alarm = var.rds_datawatch_replica_replica_lag_datapoints_to_alarm
  replica_lag_evaluation_periods  = var.rds_datawatch_replica_replica_lag_evaluation_periods
  replica_lag_period              = var.rds_datawatch_replica_replica_lag_period
  replica_lag_sns_arns            = coalesce(var.rds_datawatch_replica_replica_lag_sns_arns, [local.high_urgency_sns_topic_arn])
  replica_lag_threshold           = var.rds_datawatch_replica_replica_lag_threshold

  read_iops_disabled            = var.rds_datawatch_replica_read_iops_disabled
  read_iops_datapoints_to_alarm = var.rds_datawatch_replica_read_iops_datapoints_to_alarm
  read_iops_evaluation_periods  = var.rds_datawatch_replica_read_iops_evaluation_periods
  read_iops_period              = var.rds_datawatch_replica_read_iops_period
  read_iops_sns_arns            = coalesce(var.rds_datawatch_replica_read_iops_sns_arns, [])
  read_iops_threshold           = var.rds_datawatch_replica_read_iops_threshold

  write_iops_disabled            = var.rds_datawatch_replica_write_iops_disabled
  write_iops_datapoints_to_alarm = var.rds_datawatch_replica_write_iops_datapoints_to_alarm
  write_iops_evaluation_periods  = var.rds_datawatch_replica_write_iops_evaluation_periods
  write_iops_period              = var.rds_datawatch_replica_write_iops_period
  write_iops_sns_arns            = coalesce(var.rds_datawatch_replica_write_iops_sns_arns, [local.low_urgency_sns_topic_arn])
  write_iops_threshold           = var.rds_datawatch_replica_write_iops_threshold
}

#======================================================
# ELB
#======================================================
module "elb_temporalui" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "temporalui"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-temporalui" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-temporalui" : "${var.stack}-temporalui2"
  host_count_disabled            = var.elb_temporalui_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_temporalui_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_temporalui_host_count_evaluation_periods
  host_count_period              = var.elb_temporalui_host_count_period
  host_count_sns_arns            = coalesce(var.elb_temporalui_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_temporalui_host_count_threshold

  response_time_disabled            = var.elb_temporalui_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_temporalui_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_temporalui_response_time_evaluation_periods
  response_time_period              = var.elb_temporalui_response_time_period
  response_time_sns_arns            = coalesce(var.elb_temporalui_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_temporalui_response_time_threshold

  error_rate_disabled            = var.elb_temporalui_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_temporalui_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_temporalui_error_rate_evaluation_periods
  error_rate_period              = var.elb_temporalui_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_temporalui_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_temporalui_error_rate_threshold
}

module "elb_temporal" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "temporal"
  lb_name                        = "${var.stack}-temporal"
  target_group_name              = "${var.stack}-temporal"
  host_count_disabled            = var.elb_temporal_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_temporal_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_temporal_host_count_evaluation_periods
  host_count_period              = var.elb_temporal_host_count_period
  host_count_sns_arns            = coalesce(var.elb_temporal_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_temporal_host_count_threshold

  response_time_disabled = true
  error_rate_disabled    = true
}

module "elb_monocle" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "monocle"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-monocle" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-monocle" : "${var.stack}-monocle2"
  host_count_disabled            = var.elb_monocle_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_monocle_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_monocle_host_count_evaluation_periods
  host_count_period              = var.elb_monocle_host_count_period
  host_count_sns_arns            = coalesce(var.elb_monocle_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_monocle_host_count_threshold

  response_time_disabled            = var.elb_monocle_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_monocle_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_monocle_response_time_evaluation_periods
  response_time_period              = var.elb_monocle_response_time_period
  response_time_sns_arns            = coalesce(var.elb_monocle_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_monocle_response_time_threshold

  error_rate_disabled            = var.elb_monocle_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_monocle_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_monocle_error_rate_evaluation_periods
  error_rate_period              = var.elb_monocle_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_monocle_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_monocle_error_rate_threshold
}

module "elb_toretto" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "toretto"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-toretto" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-toretto" : "${var.stack}-toretto2"
  host_count_disabled            = var.elb_toretto_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_toretto_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_toretto_host_count_evaluation_periods
  host_count_period              = var.elb_toretto_host_count_period
  host_count_sns_arns            = coalesce(var.elb_toretto_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_toretto_host_count_threshold

  response_time_disabled            = var.elb_toretto_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_toretto_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_toretto_response_time_evaluation_periods
  response_time_period              = var.elb_toretto_response_time_period
  response_time_sns_arns            = coalesce(var.elb_toretto_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_toretto_response_time_threshold

  error_rate_disabled            = var.elb_toretto_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_toretto_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_toretto_error_rate_evaluation_periods
  error_rate_period              = var.elb_toretto_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_toretto_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_toretto_error_rate_threshold
}

module "elb_datawatch" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "datawatch"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-datawatch" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-datawatch" : "${var.stack}-datawatch2"
  host_count_disabled            = var.elb_datawatch_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_datawatch_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_datawatch_host_count_evaluation_periods
  host_count_period              = var.elb_datawatch_host_count_period
  host_count_sns_arns            = coalesce(var.elb_datawatch_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_datawatch_host_count_threshold

  response_time_disabled            = var.elb_datawatch_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_datawatch_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_datawatch_response_time_evaluation_periods
  response_time_period              = var.elb_datawatch_response_time_period
  response_time_sns_arns            = coalesce(var.elb_datawatch_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_datawatch_response_time_threshold

  error_rate_disabled            = var.elb_datawatch_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_datawatch_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_datawatch_error_rate_evaluation_periods
  error_rate_period              = var.elb_datawatch_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_datawatch_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_datawatch_error_rate_threshold
}

module "elb_backfillwork" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "backfillwork"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-backfillwork" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-backfillwork" : "${var.stack}-backfillwork2"
  host_count_disabled            = var.elb_backfillwork_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_backfillwork_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_backfillwork_host_count_evaluation_periods
  host_count_period              = var.elb_backfillwork_host_count_period
  host_count_sns_arns            = coalesce(var.elb_backfillwork_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_backfillwork_host_count_threshold

  response_time_disabled = true
  error_rate_disabled    = true
}

module "elb_datawork" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "datawork"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-datawork" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-datawork" : "${var.stack}-datawork2"
  host_count_disabled            = var.elb_datawork_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_datawork_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_datawork_host_count_evaluation_periods
  host_count_period              = var.elb_datawork_host_count_period
  host_count_sns_arns            = coalesce(var.elb_datawork_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_datawork_host_count_threshold

  response_time_disabled = true
  error_rate_disabled    = true
}

module "elb_indexwork" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "indexwork"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-indexwork" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-indexwork" : "${var.stack}-indexwork2"
  host_count_disabled            = var.elb_indexwork_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_indexwork_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_indexwork_host_count_evaluation_periods
  host_count_period              = var.elb_indexwork_host_count_period
  host_count_sns_arns            = coalesce(var.elb_indexwork_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_indexwork_host_count_threshold

  response_time_disabled = true
  error_rate_disabled    = true
}

module "elb_lineagework" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "lineagework"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-lineagework" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-lineagework" : "${var.stack}-lineagework2"
  host_count_disabled            = var.elb_lineagework_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_lineagework_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_lineagework_host_count_evaluation_periods
  host_count_period              = var.elb_lineagework_host_count_period
  host_count_sns_arns            = coalesce(var.elb_lineagework_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_lineagework_host_count_threshold

  response_time_disabled = true
  error_rate_disabled    = true
}

module "elb_metricwork" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "metricwork"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-metricwork" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-metricwork" : "${var.stack}-metricwork2"
  host_count_disabled            = var.elb_metricwork_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_metricwork_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_metricwork_host_count_evaluation_periods
  host_count_period              = var.elb_metricwork_host_count_period
  host_count_sns_arns            = coalesce(var.elb_metricwork_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_metricwork_host_count_threshold

  response_time_disabled = true
  error_rate_disabled    = true
}

module "elb_rootcause" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "rootcause"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-rootcause" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-rootcause" : "${var.stack}-rootcause2"
  host_count_disabled            = var.elb_rootcause_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_rootcause_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_rootcause_host_count_evaluation_periods
  host_count_period              = var.elb_rootcause_host_count_period
  host_count_sns_arns            = coalesce(var.elb_rootcause_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_rootcause_host_count_threshold

  response_time_disabled = true
  error_rate_disabled    = true
}

module "elb_internalapi" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "internalapi"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-internalapi" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-internalapi" : "${var.stack}-internalapi2"
  host_count_disabled            = var.elb_internalapi_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_internalapi_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_internalapi_host_count_evaluation_periods
  host_count_period              = var.elb_internalapi_host_count_period
  host_count_sns_arns            = coalesce(var.elb_internalapi_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_internalapi_host_count_threshold

  response_time_disabled            = var.elb_internalapi_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_internalapi_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_internalapi_response_time_evaluation_periods
  response_time_period              = var.elb_internalapi_response_time_period
  response_time_sns_arns            = coalesce(var.elb_internalapi_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_internalapi_response_time_threshold

  error_rate_disabled            = var.elb_internalapi_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_internalapi_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_internalapi_error_rate_evaluation_periods
  error_rate_period              = var.elb_internalapi_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_internalapi_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_internalapi_error_rate_threshold
}

module "elb_lineageapi" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "lineageapi"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-lineageapi" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-lineageapi" : "${var.stack}-lineageapi2"
  host_count_disabled            = var.elb_lineageapi_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_lineageapi_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_lineageapi_host_count_evaluation_periods
  host_count_period              = var.elb_lineageapi_host_count_period
  host_count_sns_arns            = coalesce(var.elb_lineageapi_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_lineageapi_host_count_threshold

  response_time_disabled            = var.elb_lineageapi_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_lineageapi_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_lineageapi_response_time_evaluation_periods
  response_time_period              = var.elb_lineageapi_response_time_period
  response_time_sns_arns            = coalesce(var.elb_lineageapi_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_lineageapi_response_time_threshold

  error_rate_disabled            = var.elb_lineageapi_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_lineageapi_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_lineageapi_error_rate_evaluation_periods
  error_rate_period              = var.elb_lineageapi_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_lineageapi_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_lineageapi_error_rate_threshold
}

module "elb_scheduler" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "scheduler"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-scheduler" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-scheduler" : "${var.stack}-scheduler2"
  host_count_disabled            = var.elb_scheduler_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_scheduler_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_scheduler_host_count_evaluation_periods
  host_count_period              = var.elb_scheduler_host_count_period
  host_count_sns_arns            = coalesce(var.elb_scheduler_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_scheduler_host_count_threshold

  response_time_disabled            = var.elb_scheduler_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_scheduler_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_scheduler_response_time_evaluation_periods
  response_time_period              = var.elb_scheduler_response_time_period
  response_time_sns_arns            = coalesce(var.elb_scheduler_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_scheduler_response_time_threshold

  error_rate_disabled            = var.elb_scheduler_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_scheduler_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_scheduler_error_rate_evaluation_periods
  error_rate_period              = var.elb_scheduler_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_scheduler_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_scheduler_error_rate_threshold
}

module "elb_web" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "web"
  lb_name                        = var.monitor_individual_internal_lbs ? "${var.stack}-web" : "${var.stack}-internal"
  target_group_name              = var.monitor_individual_internal_lbs ? "${var.stack}-web" : "${var.stack}-web2"
  host_count_disabled            = var.elb_web_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_web_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_web_host_count_evaluation_periods
  host_count_period              = var.elb_web_host_count_period
  host_count_sns_arns            = coalesce(var.elb_web_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_web_host_count_threshold

  response_time_disabled            = var.elb_web_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_web_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_web_response_time_evaluation_periods
  response_time_period              = var.elb_web_response_time_period
  response_time_sns_arns            = coalesce(var.elb_web_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_web_response_time_threshold

  error_rate_disabled            = var.elb_web_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_web_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_web_error_rate_evaluation_periods
  error_rate_period              = var.elb_web_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_web_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_web_error_rate_threshold
}

module "elb_haproxy" {
  source                         = "./elb"
  stack                          = var.stack
  app                            = "haproxy"
  lb_name                        = "${var.stack}-haproxy"
  target_group_name              = "${var.stack}-haproxy"
  host_count_disabled            = var.elb_haproxy_host_count_disabled
  host_count_datapoints_to_alarm = var.elb_haproxy_host_count_datapoints_to_alarm
  host_count_evaluation_periods  = var.elb_haproxy_host_count_evaluation_periods
  host_count_period              = var.elb_haproxy_host_count_period
  host_count_sns_arns            = coalesce(var.elb_haproxy_host_count_sns_arns, [local.high_urgency_sns_topic_arn])
  host_count_threshold           = var.elb_haproxy_host_count_threshold

  response_time_disabled            = var.elb_haproxy_response_time_disabled
  response_time_datapoints_to_alarm = var.elb_haproxy_response_time_datapoints_to_alarm
  response_time_evaluation_periods  = var.elb_haproxy_response_time_evaluation_periods
  response_time_period              = var.elb_haproxy_response_time_period
  response_time_sns_arns            = coalesce(var.elb_haproxy_response_time_sns_arns, [local.low_urgency_sns_topic_arn])
  response_time_threshold           = var.elb_haproxy_response_time_threshold

  error_rate_disabled            = var.elb_haproxy_error_rate_disabled
  error_rate_datapoints_to_alarm = var.elb_haproxy_error_rate_datapoints_to_alarm
  error_rate_evaluation_periods  = var.elb_haproxy_error_rate_evaluation_periods
  error_rate_period              = var.elb_haproxy_error_rate_period
  error_rate_sns_arns            = coalesce(var.elb_haproxy_error_rate_sns_arns, [local.low_urgency_sns_topic_arn])
  error_rate_threshold           = var.elb_haproxy_error_rate_threshold
}

#======================================================
# ELB
#======================================================

module "ecs_datawatch" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "datawatch"
  mem_disabled            = var.ecs_datawatch_mem_disabled
  mem_datapoints_to_alarm = var.ecs_datawatch_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_datawatch_mem_evaluation_periods
  mem_period              = var.ecs_datawatch_mem_period
  mem_sns_arns            = coalesce(var.ecs_datawatch_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_datawatch_mem_threshold
}

module "ecs_backfillwork" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "backfillwork"
  mem_disabled            = var.ecs_backfillwork_mem_disabled
  mem_datapoints_to_alarm = var.ecs_backfillwork_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_backfillwork_mem_evaluation_periods
  mem_period              = var.ecs_backfillwork_mem_period
  mem_sns_arns            = coalesce(var.ecs_backfillwork_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_backfillwork_mem_threshold
}

module "ecs_datawork" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "datawork"
  mem_disabled            = var.ecs_datawork_mem_disabled
  mem_datapoints_to_alarm = var.ecs_datawork_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_datawork_mem_evaluation_periods
  mem_period              = var.ecs_datawork_mem_period
  mem_sns_arns            = coalesce(var.ecs_datawork_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_datawork_mem_threshold
}

module "ecs_indexwork" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "indexwork"
  mem_disabled            = var.ecs_indexwork_mem_disabled
  mem_datapoints_to_alarm = var.ecs_indexwork_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_indexwork_mem_evaluation_periods
  mem_period              = var.ecs_indexwork_mem_period
  mem_sns_arns            = coalesce(var.ecs_indexwork_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_indexwork_mem_threshold
}

module "ecs_lineagework" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "lineagework"
  mem_disabled            = var.ecs_lineagework_mem_disabled
  mem_datapoints_to_alarm = var.ecs_lineagework_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_lineagework_mem_evaluation_periods
  mem_period              = var.ecs_lineagework_mem_period
  mem_sns_arns            = coalesce(var.ecs_lineagework_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_lineagework_mem_threshold
}

module "ecs_metricwork" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "metricwork"
  mem_disabled            = var.ecs_metricwork_mem_disabled
  mem_datapoints_to_alarm = var.ecs_metricwork_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_metricwork_mem_evaluation_periods
  mem_period              = var.ecs_metricwork_mem_period
  mem_sns_arns            = coalesce(var.ecs_metricwork_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_metricwork_mem_threshold
}

module "ecs_rootcause" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "rootcause"
  mem_disabled            = var.ecs_rootcause_mem_disabled
  mem_datapoints_to_alarm = var.ecs_rootcause_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_rootcause_mem_evaluation_periods
  mem_period              = var.ecs_rootcause_mem_period
  mem_sns_arns            = coalesce(var.ecs_rootcause_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_rootcause_mem_threshold
}

module "ecs_monocle" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "monocle"
  mem_disabled            = var.ecs_monocle_mem_disabled
  mem_datapoints_to_alarm = var.ecs_monocle_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_monocle_mem_evaluation_periods
  mem_period              = var.ecs_monocle_mem_period
  mem_sns_arns            = coalesce(var.ecs_monocle_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_monocle_mem_threshold
}

module "ecs_internalapi" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "internalapi"
  mem_disabled            = var.ecs_internalapi_mem_disabled
  mem_datapoints_to_alarm = var.ecs_internalapi_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_internalapi_mem_evaluation_periods
  mem_period              = var.ecs_internalapi_mem_period
  mem_sns_arns            = coalesce(var.ecs_internalapi_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_internalapi_mem_threshold
}

module "ecs_lineageapi" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "lineageapi"
  mem_disabled            = var.ecs_lineageapi_mem_disabled
  mem_datapoints_to_alarm = var.ecs_lineageapi_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_lineageapi_mem_evaluation_periods
  mem_period              = var.ecs_lineageapi_mem_period
  mem_sns_arns            = coalesce(var.ecs_lineageapi_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_lineageapi_mem_threshold
}

module "ecs_scheduler" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "scheduler"
  mem_disabled            = var.ecs_scheduler_mem_disabled
  mem_datapoints_to_alarm = var.ecs_scheduler_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_scheduler_mem_evaluation_periods
  mem_period              = var.ecs_scheduler_mem_period
  mem_sns_arns            = coalesce(var.ecs_scheduler_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_scheduler_mem_threshold
}

module "ecs_toretto" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "toretto"
  mem_disabled            = var.ecs_toretto_mem_disabled
  mem_datapoints_to_alarm = var.ecs_toretto_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_toretto_mem_evaluation_periods
  mem_period              = var.ecs_toretto_mem_period
  mem_sns_arns            = coalesce(var.ecs_toretto_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_toretto_mem_threshold
}

module "ecs_web" {
  source                  = "./ecs"
  stack                   = var.stack
  app                     = "web"
  mem_disabled            = var.ecs_web_mem_disabled
  mem_datapoints_to_alarm = var.ecs_web_mem_datapoints_to_alarm
  mem_evaluation_periods  = var.ecs_web_mem_evaluation_periods
  mem_period              = var.ecs_web_mem_period
  mem_sns_arns            = coalesce(var.ecs_web_mem_sns_arns, [local.low_urgency_sns_topic_arn])
  mem_threshold           = var.ecs_web_mem_threshold
}

# TODO temporal ECS mem alarms
