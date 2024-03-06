resource "aws_secretsmanager_secret" "smtp_password" {
  count                   = local.create_ses_from_email ? 1 : 0
  name                    = local.byomailserver_smtp_password_aws_secrets_manager_secret_id
  recovery_window_in_days = 0
  # The Bigeye module creates an iam role policy allowing access to all secrets with a stack = <stack name> tag set.
  tags = {
    stack = local.name
  }
}

resource "aws_secretsmanager_secret_version" "smtp_password" {
  count          = local.create_ses_from_email ? 1 : 0
  secret_id      = aws_secretsmanager_secret.smtp_password[0].id
  secret_string  = aws_iam_access_key.from_email[0].ses_smtp_password_v4
  version_stages = ["AWSCURRENT"]
}
