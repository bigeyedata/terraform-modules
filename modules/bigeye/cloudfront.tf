locals {
  static_object_path_patterns = [
    "/*.js",
    "/*.jpg",
    "/*.jpeg",
    "/*.gif",
    "/*.css",
    "/*.png",
    "/*.svg",
    "/*.webp",
    "/*.woff2",
  ]
  cloudfront_ordered_cache_behavior_defaults = {
    target_origin_id             = "bigeye"
    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-CORS-CustomOrigin"
    response_headers_policy_name = "Managed-CORS-With-Preflight"
    viewer_protocol_policy       = "redirect-to-https"
    compress                     = true
    use_forwarded_values         = false
    allowed_methods              = ["GET", "HEAD", "OPTIONS"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
  }
  cloudfront_ordered_cache_behavior = [
    for path_pattern in local.static_object_path_patterns : merge(
      { path_pattern = path_pattern }, local.cloudfront_ordered_cache_behavior_defaults
    )
  ]
}

module "cloudfront" {
  count   = var.cloudfront_enabled ? 1 : 0
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "5.2.0"

  aliases             = [local.static_asset_dns_name]
  comment             = local.name
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  http_version        = "http2and3"
  wait_for_deployment = true
  logging_config = var.cloudfront_logging_bucket != "" ? {
    bucket = var.cloudfront_logging_bucket
    prefix = "bigeye.com"
  } : {}

  origin = {
    bigeye = {
      domain_name         = local.vanity_dns_name
      connection_attempts = 3
      connection_timeout  = 10
      custom_origin_config = {
        http_port                = 80
        https_port               = 443
        origin_keepalive_timeout = 5
        origin_protocol_policy   = "https-only"
        origin_read_timeout      = var.cloudfront_origin_read_timeout
        origin_ssl_protocols     = ["TLSv1.2"]
      }
    }
  }

  ordered_cache_behavior = local.cloudfront_ordered_cache_behavior

  default_cache_behavior = {
    target_origin_id           = "bigeye"
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = var.cloudfront_compression_enabled
    use_forwarded_values       = false
    cache_policy_name          = "UseOriginCacheControlHeaders"
    origin_request_policy_name = "Managed-AllViewer"

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
  }

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.cloudfront_acm_certificate_arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}
