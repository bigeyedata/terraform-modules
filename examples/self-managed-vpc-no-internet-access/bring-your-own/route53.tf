resource "aws_cloudformation_stack" "route53" {
  name = "${local.name}-dns"
  template_body = jsonencode({
    Outputs = {
      HostedZoneId = {
        Value = {
          "Ref" = "HostedZone"
        }
      }
      AcmCertificateArn = {
        Value = {
          "Ref" = "WildcardCertificate"
        }
      }
    }
    Resources = {
      HostedZone = {
        Type = "AWS::Route53::HostedZone"
        Properties = {
          Name = var.subdomain
        }
      }
      NSInParentZone = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId = var.parent_domain_zone_id
          Type         = "NS"
          TTL          = 300
          Name         = var.subdomain
          ResourceRecords = {
            "Fn::GetAtt" = ["HostedZone", "NameServers"]
          }
        }
      }
      WildcardCertificate = {
        Type = "AWS::CertificateManager::Certificate"
        Properties = {
          DomainName       = "*.${var.subdomain}"
          ValidationMethod = "DNS"
          DomainValidationOptions = [
            {
              DomainName = "*.${var.subdomain}"
              HostedZoneId = {
                "Ref" = "HostedZone"
              }
            }
          ]
        }
      }
    }
  })
}


