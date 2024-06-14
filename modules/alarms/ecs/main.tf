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
  name = "${var.stack}-${var.app}"
}

resource "aws_cloudwatch_metric_alarm" "mem" {
  count               = var.mem_disabled ? 0 : 1
  alarm_name          = "${local.name} Mem percent util too high"
  ok_actions          = var.mem_sns_arns
  alarm_actions       = var.mem_sns_arns
  actions_enabled     = length(var.mem_sns_arns) > 0
  alarm_description   = "Mem Util should not stay sustained too high across all containers in a service.  If it does, it's time to scale up the ECS task memory."
  evaluation_periods  = var.mem_evaluation_periods
  datapoints_to_alarm = var.mem_datapoints_to_alarm
  threshold           = var.mem_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  metric_query {
    id          = "m1"
    period      = 0
    return_data = false

    metric {
      dimensions = {
        "ClusterName" = var.stack
        "ServiceName" = local.name
      }
      metric_name = "MemoryUtilized"
      namespace   = "ECS/ContainerInsights"
      period      = var.mem_period
      stat        = "Average"
    }
  }
  metric_query {
    id          = "m2"
    period      = 0
    return_data = false

    metric {
      dimensions = {
        "ClusterName" = var.stack
        "ServiceName" = local.name
      }
      metric_name = "MemoryReserved"
      namespace   = "ECS/ContainerInsights"
      period      = var.mem_period
      stat        = "Average"
    }
  }
  metric_query {
    expression  = "100*(m1/m2)"
    id          = "e1"
    label       = "Expression1"
    period      = 0
    return_data = true
  }
}
