terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

}


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


locals {
  elb_name          = format("%s-%s", var.stack, var.app)
  target_group_name = local.elb_name
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  count               = var.error_rate_disabled ? 0 : 1
  alarm_name          = "${var.stack} - ${var.app} ELB http error rate too high"
  alarm_description   = "http error rate is too high ((5xx)/total requests) at the load balancer - something is wrong with the app"
  actions_enabled     = length(var.error_rate_sns_arns) > 0
  ok_actions          = var.error_rate_sns_arns
  alarm_actions       = var.error_rate_sns_arns
  evaluation_periods  = var.error_rate_evaluation_periods
  datapoints_to_alarm = var.error_rate_datapoints_to_alarm
  threshold           = var.error_rate_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "ignore"

  metric_query {
    id          = "e1"
    label       = "Http Error Rate"
    return_data = "true"
    expression  = "100 * (m1) / m2"
  }

  metric_query {
    id          = "m1"
    return_data = false
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      period      = var.error_rate_period
      stat        = "Sum"
      dimensions = {
        LoadBalancer = local.elb_name
      }
    }
  }

  metric_query {
    id          = "m2"
    return_data = false
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      period      = var.error_rate_period
      stat        = "Sum"
      dimensions = {
        LoadBalancer = local.elb_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time" {
  count             = var.response_time_disabled ? 0 : 1
  alarm_name        = "${var.stack} - ${var.app} ELB TargetResponseTime too high"
  actions_enabled   = length(var.response_time_sns_arns) > 0
  ok_actions        = var.response_time_sns_arns
  alarm_actions     = var.response_time_sns_arns
  alarm_description = "The target response time is too high"
  metric_name       = "TargetResponseTime"
  namespace         = "AWS/ApplicationELB"
  statistic         = "Average"
  dimensions = {
    LoadBalancer = local.elb_name
  }
  period              = var.response_time_period
  evaluation_periods  = var.response_time_evaluation_periods
  datapoints_to_alarm = var.response_time_datapoints_to_alarm
  threshold           = var.response_time_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "ignore"
}

resource "aws_cloudwatch_metric_alarm" "host_count" {
  count             = var.host_count_disabled ? 0 : 1
  alarm_name        = "${var.stack} - ${var.app} ELB HealthyHostCount too low"
  actions_enabled   = length(var.host_count_sns_arns) > 0
  ok_actions        = var.host_count_sns_arns
  alarm_actions     = var.host_count_sns_arns
  alarm_description = "The healthy host count is too low"
  metric_name       = "HealthyHostCount"
  namespace         = "AWS/ApplicationELB"
  statistic         = "Average"
  dimensions = {
    LoadBalancer = local.elb_name
    TargetGroup  = local.target_group_name
  }
  period              = var.host_count_period
  evaluation_periods  = var.host_count_evaluation_periods
  datapoints_to_alarm = var.host_count_datapoints_to_alarm
  threshold           = var.host_count_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"
}
