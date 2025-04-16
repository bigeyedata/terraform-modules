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
  cloudwatch_load_balancer_value = data.aws_lb.this.arn_suffix
  cloudwatch_target_group_value  = data.aws_lb_target_group.this.arn_suffix
}

data "aws_lb" "this" {
  name = var.lb_name
}

data "aws_lb_target_group" "this" {
  name = var.target_group_name
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
        LoadBalancer = local.cloudwatch_load_balancer_value
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
        LoadBalancer = local.cloudwatch_load_balancer_value
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
    LoadBalancer = local.cloudwatch_load_balancer_value
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
    LoadBalancer = local.cloudwatch_load_balancer_value
    TargetGroup  = local.cloudwatch_target_group_value
  }
  period              = var.host_count_period
  evaluation_periods  = var.host_count_evaluation_periods
  datapoints_to_alarm = var.host_count_datapoints_to_alarm
  threshold           = var.host_count_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"
}
