terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33.0"
    }
  }
}

resource "aws_cloudformation_stack" "dns" {
  name = "${var.stack_name}-app-dns"
  template_body = jsonencode({
    Resources = {
      HaproxyRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.haproxy_domain_name
          ResourceRecords = [var.haproxy_load_balancer_domain_name]
        }
      }
      DatawatchRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.datawatch_domain_name
          ResourceRecords = [var.datawatch_load_balancer_domain_name]
        }
      }
      DataworkRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.datawork_domain_name
          ResourceRecords = [var.datawork_load_balancer_domain_name]
        }
      }
      LineageworkRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.lineagework_domain_name
          ResourceRecords = [var.lineagework_load_balancer_domain_name]
        }
      }
      MetricworkRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.metricwork_domain_name
          ResourceRecords = [var.metricwork_load_balancer_domain_name]
        }
      }
      SchedulerRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.scheduler_domain_name
          ResourceRecords = [var.scheduler_load_balancer_domain_name]
        }
      }
      MonocleRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.monocle_domain_name
          ResourceRecords = [var.monocle_load_balancer_domain_name]
        }
      }
      TorettoRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.toretto_domain_name
          ResourceRecords = [var.toretto_load_balancer_domain_name]
        }
      }
      TemporalRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.temporal_domain_name
          ResourceRecords = [var.temporal_load_balancer_domain_name]
        }
      }
      TemporalUIRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.temporalui_domain_name
          ResourceRecords = [var.temporalui_load_balancer_domain_name]
        }
      }
      WebRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.web_domain_name
          ResourceRecords = [var.web_load_balancer_domain_name]
        }
      }
      DatawatchMysqlRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.datawatch_mysql_vanity_domain_name
          ResourceRecords = [var.datawatch_mysql_domain_name]
        }
      }
      TemporalMysqlRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = var.zone_id
          Type            = "CNAME"
          TTL             = 300
          Name            = var.temporal_mysql_vanity_domain_name
          ResourceRecords = [var.temporal_mysql_domain_name]
        }
      }
    }
  })
}

