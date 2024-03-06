# This example registers a subdomain in your already registered domain.
# Registering a root level domain name involves a commitment from a Domain Name Registrar
# for a minimum of 12 months so is beyond the scope of this example.
data "aws_route53_zone" "parent_domain" {
  name         = local.parent_domain
  private_zone = false
}

resource "aws_route53_zone" "subdomain" {
  name          = local.subdomain
  force_destroy = true
}

# Record in the parent domain for the nameservers in the subdomain must be created
resource "aws_route53_record" "subdomain_ns_record" {
  type    = "NS"
  zone_id = data.aws_route53_zone.parent_domain.zone_id
  name    = local.subdomain_prefix
  ttl     = 300
  records = aws_route53_zone.subdomain.name_servers
}
