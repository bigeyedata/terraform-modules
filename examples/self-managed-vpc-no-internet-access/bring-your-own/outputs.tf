output "ecs_service_iam_role_arn" {
  value = aws_cloudformation_stack.iam.outputs["ECSRoleArn"]
}

output "admin_container_iam_role_arn" {
  value = aws_cloudformation_stack.iam.outputs["AdminContainerRoleArn"]
}

output "datawatch_iam_role_arn" {
  value = aws_cloudformation_stack.iam.outputs["DatawatchRoleArn"]
}

output "monocle_iam_role_arn" {
  value = aws_cloudformation_stack.iam.outputs["MonocleRoleArn"]
}
output "rabbitmq_endpoint" {
  value = split(",", aws_cloudformation_stack.mq.outputs["Endpoints"])[0]
}
output "rabbitmq_password_secret_arn" {
  value = aws_secretsmanager_secret.rabbitmq_user_password.arn
}
output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
output "redis_security_group_id" {
  value = aws_security_group.redis.id
}
output "http_security_group_id" {
  value = aws_security_group.http.id
}
output "services_security_group_id" {
  value = aws_security_group.services.id
}
output "temporal_security_group_id" {
  value = aws_security_group.temporal.id
}
output "rabbitmq_security_group_id" {
  value = aws_security_group.rabbitmq.id
}
output "ses_hostname" {
  value = format("email-smtp.%s.amazonaws.com", var.aws_region)
}
output "ses_port" {
  value = 587
}
output "ses_user" {
  value = aws_cloudformation_stack.ses.outputs["AccessKeyId"]
}
output "ses_password_arn" {
  value = aws_secretsmanager_secret.smtp_password.arn
}
output "zone_id" {
  value = aws_cloudformation_stack.route53.outputs["HostedZoneId"]
}
output "acm_certificate_arn" {
  value = aws_cloudformation_stack.route53.outputs["AcmCertificateArn"]
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
output "internal_subnet_ids" {
  value = module.vpc.intra_subnets
}
output "elasticache_subnet_ids" {
  value = module.vpc.elasticache_subnets
}
output "redis_subnet_group_name" {
  value = module.vpc.elasticache_subnet_group_name
}
output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}
output "bastion_ip" {
  value = var.bastion_enabled ? aws_instance.bastion[0].public_ip : ""
}
output "bastion_user" {
  value = "ec2-user"
}
