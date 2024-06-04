#######################################################################
# SES is optional and here to facilitate testing a BYO email server install.
# Most BYO VPC examples will not use this file and will supply an existing
# SMTP server.
#######################################################################

resource "aws_cloudformation_stack" "ses" {
  name = "${local.name}-ses-support"
  capabilities = [
    "CAPABILITY_IAM",
    "CAPABILITY_NAMED_IAM"
  ]
  template_body = jsonencode({
    Outputs = {
      AccessKeyId = {
        Value = {
          "Ref" = "UserKeys"
        }
      }
      SecretAccessKey = {
        Value = {
          "Fn::GetAtt" = ["UserKeys", "SecretAccessKey"]
        }
      }
    }
    Resources = {
      User = {
        Type = "AWS::IAM::User"
        Properties = {
          UserName = local.ses_iam_user_name
        }
      }
      UserPolicy = {
        Type = "AWS::IAM::UserPolicy"
        Properties = {
          UserName = {
            "Ref" = "User"
          }
          PolicyName = "AccessSES"
          PolicyDocument = {
            Version = "2012-10-17"
            Statement = [
              {
                Effect = "Allow"
                Action = [
                  "ses:SendEmail",
                  "ses:SendRawEmail",
                  "ses:SendTemplatedEmail",
                  "ses:SendBulkTemplatedEmail"
                ]
                Resource = "*"
              }
            ]
          }
        }
      }
      UserKeys = {
        Type = "AWS::IAM::AccessKey"
        Properties = {
          UserName = {
            "Ref" = "User"
          }
        }
      }
      SPFRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = aws_cloudformation_stack.route53.outputs["HostedZoneId"]
          Type            = "TXT"
          TTL             = 300
          Name            = "${var.subdomain}."
          ResourceRecords = ["\"v=spf1 include:amazonses.com ~all\""]
        }
      }
      DMARCRecord = {
        Type = "AWS::Route53::RecordSet"
        Properties = {
          HostedZoneId    = aws_cloudformation_stack.route53.outputs["HostedZoneId"]
          Type            = "TXT"
          TTL             = 300
          Name            = "_dmarc.${var.subdomain}."
          ResourceRecords = ["\"v=DMARC1;p=quarantine;pct=100;fo=1\""]
        }
      }
      FromEmail = {
        Type = "AWS::SES::EmailIdentity"
        Properties = {
          EmailIdentity = var.from_email
        }
      }
    }
  })
}

resource "aws_security_group" "smtp_vpce" {
  name   = "${local.name}-smtp-vpce"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = local.byomailserver_smtp_port
    to_port     = local.byomailserver_smtp_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = local.byomailserver_smtp_port
    to_port     = local.byomailserver_smtp_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  tags = {
    "Name" = "${local.name}-smtp-endpoint"
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/462
# Not all VPC endpoint services are supported in all availability zones.
# example SES isn't available in us-east-1a
data "aws_vpc_endpoint_service" "ses" {
  service = "email-smtp"
}

data "aws_subnets" "ses_vpce_subnets" {
  filter {
    name   = "subnet-id"
    values = module.vpc.private_subnets
  }

  filter {
    name   = "availability-zone"
    values = data.aws_vpc_endpoint_service.ses.availability_zones
  }
}

resource "aws_vpc_endpoint" "smtp_vpce" {
  security_group_ids  = [aws_security_group.smtp_vpce.id]
  service_name        = "com.amazonaws.${local.aws_region}.email-smtp"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.ses_vpce_subnets.ids
  private_dns_enabled = true
  tags = {
    "Name" = "${local.name}-smtp-endpoint"
  }
  vpc_id = module.vpc.vpc_id
}
