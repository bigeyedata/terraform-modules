data "aws_lb" "external" {
  arn = var.centralized_lb_arn
}

data "aws_partition" "current" {}

data "aws_default_tags" "this" {}
