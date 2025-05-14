data "aws_secretsmanager_secret" "byomailserver_smtp_password" {
  name = "bigeye/example/byomailserver-smtp-password"
}

module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v20.5.1"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  # This is Bigeye's ECR registry.  Setting this to Bigeye's registry is simple as a hello world example, but it is recommended
  # for enterprise customers to cache our images in you own ECR repo.  See the self-managed-ecr example
  image_registry = "021451147547.dkr.ecr.us-west-2.amazonaws.com"

  # Bigeye app version.  You can list the tags available in the image_registry (using the latest is always recommended).
  image_tag = "1.34.0"

  # byo mail server
  byomailserver_smtp_host                = "smtp.example.com"
  byomailserver_smtp_port                = "587"
  byomailserver_smtp_user                = "smtp.user@mail.example.com"
  byomailserver_smtp_password_secret_arn = data.aws_secretsmanager_secret.byomailserver_smtp_password.arn
}

