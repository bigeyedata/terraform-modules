data "aws_secretsmanager_secret" "byomailserver_smtp_password" {
  name = "bigeye/example/byomailserver-smtp-password"
}

module "bigeye" {
  source      = "git::https://github.com/bigeyedata/terraform-modules//modules/bigeye?ref=v2.4.0"
  environment = "test"
  instance    = "bigeye"

  # Your parent DNS name here, e.g. bigeye.my-company.com
  top_level_dns_name = ""

  # Get this from Bigeye Sales
  image_tag = ""

  # byo mail server
  byomailserver_smtp_host                = "smtp.example.com"
  byomailserver_smtp_port                = "587"
  byomailserver_smtp_user                = "smtp.user@mail.example.com"
  byomailserver_smtp_password_secret_arn = data.aws_secretsmanager_secret.byomailserver_smtp_password.arn
}

