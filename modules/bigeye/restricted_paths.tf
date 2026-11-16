resource "aws_lb_listener_rule" "external_restricted_paths_allow" {
  count        = length(var.external_restricted_paths) > 0 && length(var.external_restricted_paths_allowed_cidrs) > 0 ? 1 : 0
  listener_arn = aws_lb_listener.https_external.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = module.haproxy.target_group_arn
  }

  condition {
    host_header {
      values = [module.haproxy.dns_name]
    }
  }

  condition {
    path_pattern {
      values = var.external_restricted_paths
    }
  }

  condition {
    source_ip {
      values = var.external_restricted_paths_allowed_cidrs
    }
  }

  tags = merge({ "Name" = "${local.name}-restricted-paths-allow" }, local.tags)

  lifecycle {
    precondition {
      condition     = length(var.external_restricted_paths) + length(var.external_restricted_paths_allowed_cidrs) <= 4
      error_message = "ALB rules allow 5 condition values; the host header takes one, so external_restricted_paths and external_restricted_paths_allowed_cidrs together can have at most 4"
    }
  }
}

resource "aws_lb_listener_rule" "external_restricted_paths_deny" {
  count        = length(var.external_restricted_paths) > 0 ? 1 : 0
  listener_arn = aws_lb_listener.https_external.arn
  priority     = 2

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    host_header {
      values = [module.haproxy.dns_name]
    }
  }

  condition {
    path_pattern {
      values = var.external_restricted_paths
    }
  }

  tags = merge({ "Name" = "${local.name}-restricted-paths-deny" }, local.tags)
}
