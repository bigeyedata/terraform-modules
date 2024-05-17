resource "aws_secretsmanager_secret" "smtp_password" {
  name                    = local.byomailserver_smtp_password_aws_secrets_manager_secret_id
  recovery_window_in_days = 0
  # The Bigeye module creates an iam role policy allowing access to all secrets with a stack = <stack name> tag set.
  tags = {
    stack = local.name
  }
}

data "external" "smtp_conversion" {
  program = [
    "python3",
    "${path.module}/secret-to-ses-smtp-password-v4.py",
    aws_cloudformation_stack.ses.outputs["SecretAccessKey"],
    var.aws_region
  ]
}

resource "aws_secretsmanager_secret_version" "smtp_password" {
  secret_id      = aws_secretsmanager_secret.smtp_password.id
  secret_string  = data.external.smtp_conversion.result["smtppassword"]
  version_stages = ["AWSCURRENT"]
}
