# This files should just be an implementation of the "standard" example.
module "bigeye" {
  source              = "../../modules/bigeye"
  environment         = "test"
  instance            = "tfmodulesci1"
  top_level_dns_name  = "bigeyedata.xyz"
  private_hosted_zone = true
  vanity_alias        = "tfmodulesci1"
  vpc_cidr_block      = "10.39.0.0/16"
  image_registry      = "021451147547.dkr.ecr.us-west-2.amazonaws.com"
  image_tag           = "latest"
}

provider "aws" {
  region = "us-west-2"
  assume_role {
    role_arn = var.AWS_CI_ACCOUNT_RO_ROLE_ARN
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}
