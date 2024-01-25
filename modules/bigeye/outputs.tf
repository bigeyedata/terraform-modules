output "stack_name" {
  description = "Top level stack name for the Bigeye app resources.  This is used in tags, for AWS secrets manager access etc."
  value       = local.stack_name
}

output "vpc_id" {
  description = "The VPC ID holding resources"
  value       = local.vpc_id
}

#======================================================
# DNS - Top level
#======================================================
output "vanity_dns_name" {
  description = "DNS name for the main haproxy entrypoint service"
  value       = local.vanity_dns_name
}

output "haproxy_load_balancer_dns_name" {
  description = "The dns name of the HAProxy load balancer"
  value       = module.haproxy.dns_name
}

output "haproxy_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the HAProxy load balancer"
  value       = module.haproxy.zone_id
}

#======================================================
# DNS - RDS
#======================================================
output "datawatch_database_vanity_dns_name" {
  description = "The vanity dns name for the datawatch RDS instance"
  value       = local.datawatch_mysql_dns_name
}

output "datawatch_database_dns_name" {
  description = "The dns name of the datawatch RDS instance"
  value       = module.datawatch_rds.primary_dns_name
}

output "datawatch_database_replica_vanity_dns_name" {
  description = "The vanity dns name for the datawatch RDS replica instance"
  value       = local.datawatch_mysql_replica_dns_name
}

output "datawatch_database_replica_dns_name" {
  description = "The dns name of the datawatch RDS replica instance"
  value       = module.datawatch_rds.replica_dns_name
}

output "temporal_database_vanity_dns_name" {
  description = "The vanity domain for the temporal RDS instance"
  value       = local.temporal_mysql_dns_name
}

output "temporal_database_dns_name" {
  value = module.temporal_rds.primary_dns_name
}

#======================================================
# DNS - Services
#======================================================
output "datawatch_dns_name" {
  description = "DNS name for the datawatch service"
  value       = local.datawatch_dns_name
}

output "datawatch_load_balancer_dns_name" {
  description = "The dns name of the datawatch load balancer"
  value       = module.datawatch.dns_name
}

output "datawatch_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the datawatch load balancer"
  value       = module.datawatch.zone_id
}

output "datawork_dns_name" {
  description = "DNS name for the datawork service"
  value       = local.datawork_dns_name
}

output "datawork_load_balancer_dns_name" {
  description = "The dns name of the datawork load balancer"
  value       = module.datawork.dns_name
}

output "datawork_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the datawork load balancer"
  value       = module.datawork.zone_id
}

output "metricwork_dns_name" {
  description = "DNS name for the metricwork service"
  value       = local.metricwork_dns_name
}

output "metricwork_load_balancer_dns_name" {
  description = "The dns name of the metricwork load balancer"
  value       = module.metricwork.dns_name
}

output "metricwork_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the metricwork load balancer"
  value       = module.metricwork.zone_id
}

output "monocle_dns_name" {
  description = "DNS name for the monocle service"
  value       = local.monocle_dns_name
}

output "monocle_load_balancer_dns_name" {
  description = "The dns name of the monocle load balancer"
  value       = module.monocle.dns_name
}

output "monocle_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the monocle load balancer"
  value       = module.monocle.zone_id
}

output "scheduler_dns_name" {
  description = "DNS name for the scheduler service"
  value       = local.scheduler_dns_name
}

output "scheduler_load_balancer_dns_name" {
  description = "The dns name of the scheduler load balancer"
  value       = module.scheduler.dns_name
}

output "scheduler_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the scheduler load balancer"
  value       = module.scheduler.zone_id
}

output "temporal_dns_name" {
  description = "DNS name for the temporal service"
  value       = local.temporal_dns_name
}

output "temporal_load_balancer_dns_name" {
  description = "The dns name of the temporal load balancer"
  value       = aws_lb.temporal.dns_name
}

output "temporal_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the temporal load balancer"
  value       = aws_lb.temporal.zone_id
}

output "temporal_admin_dns_name" {
  description = "DNS name for the temporal admin service"
  value       = local.temporal_admin_dns_name
}

output "temporal_admin_load_balancer_dns_name" {
  description = "The dns name of the temporal admin load balancer"
  value       = module.temporalui.dns_name
}

output "temporal_admin_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the temporal admin load balancer"
  value       = module.temporalui.zone_id
}

output "toretto_dns_name" {
  description = "DNS name for the toretto service"
  value       = local.toretto_dns_name
}

output "toretto_load_balancer_dns_name" {
  description = "The dns name of the toretto load balancer"
  value       = module.toretto.dns_name
}

output "toretto_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the toretto load balancer"
  value       = module.toretto.zone_id
}

output "web_dns_name" {
  description = "DNS name for the web service"
  value       = local.web_dns_name
}

output "web_load_balancer_dns_name" {
  description = "The dns name of the web load balancer"
  value       = module.web.dns_name
}

output "web_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the web load balancer"
  value       = module.web.zone_id
}

output "ecs_task_role_id" {
  description = "Id of the ECS Task execution role.  This is useful for granting ECS access to secrets manager secrets."
  value       = aws_iam_role.ecs.id
}
#======================================================
# Networking bits
#======================================================

output "nat_public_ips" {
  description = "IP addresses for the NAT gateway on the NAT subnet.  This will return an empty list for BYO VPC installs regardless of if the BYO VPC has a NAT or not."
  value       = one(module.vpc) == null ? [] : module.vpc[0].nat_public_ips
}
