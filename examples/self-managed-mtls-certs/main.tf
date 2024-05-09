data "aws_secretsmanager_secret" "private" {
  name = "bigeye/byo-mtls-example/mtls_key"
}

data "aws_secretsmanager_secret" "public" {
  name = "bigeye/byo-mtls-example/mtls_pem"
}

data "aws_secretsmanager_secret" "ca_public" {
  name = "bigeye/byo-mtls-example/mtls_ca_pem"
}

data "aws_secretsmanager_secret" "ca_bundle" {
  name = "bigeye/byo-mtls-example/mtls_client_ca_bundle_tar_gz"
}

module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v4.1.2"
  environment = "test"
  instance    = "bigeye"

  # This is domain name of the domain that you have already set up in route53.  This terraform will create DNS entries
  # in that domain for the application.
  top_level_dns_name = "example.com"

  # This is Bigeye's ECR registry.  Setting this to Bigeye's registry is simple as a hello world example, but it is recommended
  # for enterprise customers to cache our images in you own ECR repo.  See the self-managed-ecr example
  image_registry = "021451147547.dkr.ecr.us-west-2.amazonaws.com"

  # Bigeye app version.  You can list the tags available in the image_registry (using the latest is always recommended).
  image_tag = "1.34.0"

  temporal_use_default_certificates = false

  datawatch_additional_secret_arns = {
    SECRETS_TEMPORAL_PUBLIC_MTLS_BASE64    = data.aws_secretsmanager_secret.public.arn
    SECRETS_TEMPORAL_PRIVATE_MTLS_BASE64   = data.aws_secretsmanager_secret.private.arn
    SECRETS_TEMPORAL_PUBLIC_MTLS_CA_BASE64 = data.aws_secretsmanager_secret.ca_public.arn
    SECRETS_TEMPORAL_MTLS_CA_BUNDLE_BASE64 = data.aws_secretsmanager_secret.ca_bundle.arn
  }
  temporal_additional_secret_arns = {
    SECRETS_TEMPORAL_PUBLIC_MTLS_BASE64    = data.aws_secretsmanager_secret.public.arn
    SECRETS_TEMPORAL_PRIVATE_MTLS_BASE64   = data.aws_secretsmanager_secret.private.arn
    SECRETS_TEMPORAL_PUBLIC_MTLS_CA_BASE64 = data.aws_secretsmanager_secret.ca_public.arn
    SECRETS_TEMPORAL_MTLS_CA_BUNDLE_BASE64 = data.aws_secretsmanager_secret.ca_bundle.arn
  }
  temporalui_additional_secret_arns = {
    TEMPORAL_TLS_CERT_DATA = data.aws_secretsmanager_secret.public.arn
    TEMPORAL_TLS_KEY_DATA  = data.aws_secretsmanager_secret.private.arn
    TEMPORAL_TLS_CA_DATA   = data.aws_secretsmanager_secret.ca_public.arn
  }
}

# This output is just here for debugging and can be removed if desired.  It is used to get the temporal_dns_name for use in setting up mTLS certs.
output "bigeye" {
  value = module.bigeye
}
