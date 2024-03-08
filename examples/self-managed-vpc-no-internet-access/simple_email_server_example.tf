#######################################################################
# SES is optional and here to facilitate testing a BYO email server install.
# Most BYO VPC examples will not use this file and will supply an existing
# SMTP server.
#######################################################################

data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail", "ses:SendTemplatedEmail", "ses:SendBulkTemplatedEmail"]
    resources = ["*"]
  }
}

resource "aws_ses_email_identity" "from_email" {
  count = local.create_ses_from_email ? 1 : 0
  email = local.from_email
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_user" "from_email" {
  count = local.create_ses_from_email ? 1 : 0
  name  = local.ses_iam_user_name
}

resource "aws_iam_access_key" "from_email" {
  count = local.create_ses_from_email ? 1 : 0
  user  = aws_iam_user.from_email[0].name
}

resource "aws_iam_policy" "from_email" {
  count  = local.create_ses_from_email ? 1 : 0
  name   = local.ses_iam_user_name
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_user_policy_attachment" "from_email" {
  count      = local.create_ses_from_email ? 1 : 0
  user       = aws_iam_user.from_email[0].name
  policy_arn = aws_iam_policy.from_email[0].arn
}

resource "aws_route53_record" "subdomain_spf" {
  zone_id = aws_route53_zone.subdomain.zone_id
  name    = "${local.subdomain}."
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "subdomain_dmarc" {
  zone_id = aws_route53_zone.subdomain.zone_id
  name    = "_dmarc.${local.subdomain}."
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1;p=quarantine;pct=100;fo=1"]
}

# VPC Endpoint for SES is recommended when using AWS SES for mail delivery to avoid email being sent over public net.
resource "aws_security_group" "smtp_vpce" {
  name   = "${local.name}-smtp-vpce"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = local.byomailserver_smtp_port
    to_port     = local.byomailserver_smtp_port
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [local.cidr_block]
  }

  tags = {
    "Name" = "${local.name}-smtp-endpoint"
  }
}

resource "aws_vpc_endpoint" "smtp_vpce" {
  security_group_ids  = [aws_security_group.smtp_vpce.id]
  service_name        = "com.amazonaws.${local.aws_region}.email-smtp"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
  tags = {
    "Name" = "${local.name}-smtp-endpoint"
  }
  vpc_id = module.vpc.vpc_id
}
