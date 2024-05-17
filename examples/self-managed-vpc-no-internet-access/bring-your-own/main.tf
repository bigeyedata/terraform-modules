terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.3"
    }
  }
}

locals {
  # Do not use hard coded AWS credentials for production installs.  These are here for demonstration purposes for those who do not
  # have credentials set up for Terraform to access AWS already.
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  name = var.stack_name

  # This IAM user is created in simple_email_server_example.tf and is used by AWS SES to send email.
  ses_iam_user_name = "${var.stack_name}-bigeye"

  # This ASM secret is created in secrets.tf and can be used as an example if you are bringing your own email server.
  byomailserver_smtp_password_aws_secrets_manager_secret_id = "bigeye/${local.name}/smtp/password"
  byomailserver_smtp_port                                   = 587
}

