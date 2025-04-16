data "aws_lb" "external" {
  count = local.centralized_lb_installed ? 1 : 0
  arn   = var.centralized_lb_arn
}
