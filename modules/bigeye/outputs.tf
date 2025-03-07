output "stack_name" {
  description = "Top level stack name for the Bigeye app resources.  This is used in tags, for AWS secrets manager access etc."
  value       = local.stack_name
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
  value       = module.haproxy.lb_dns_name
}

output "haproxy_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the HAProxy load balancer"
  value       = module.haproxy.zone_id
}

#======================================================
# Resource Names
#======================================================
output "datawatch_rds_identifier" {
  description = "RDS identifier for datawatch database"
  value       = module.datawatch_rds.identifier
}

output "datawatch_rds_replica_identifier" {
  description = "RDS identifier for datawatch read replica database"
  value       = module.datawatch_rds.replica_identifier
}

output "temporal_rds_identifier" {
  description = "RDS identifier for temporal database"
  value       = module.temporal_rds.identifier
}

output "rabbitmq_name" {
  description = "Name of the RabbitMQ broker"
  value       = local.create_rabbitmq ? module.rabbitmq[0].name : ""
}

output "redis_cluster_id" {
  description = "Name of the Redis cluster ID"
  value       = module.redis.cluster_id
}

#======================================================
# DNS - RDS
#======================================================
output "datawatch_database_vanity_dns_name" {
  description = "The vanity dns name for the datawatch RDS instance"
  value       = local.datawatch_mysql_vanity_dns_name
}

output "datawatch_database_dns_name" {
  description = "The dns name of the datawatch RDS instance"
  value       = module.datawatch_rds.primary_dns_name
}

output "datawatch_database_replica_vanity_dns_name" {
  description = "The vanity dns name for the datawatch RDS replica instance"
  value       = local.datawatch_mysql_replica_vanity_dns_name
}

output "datawatch_database_replica_dns_name" {
  description = "The dns name of the datawatch RDS replica instance"
  value       = module.datawatch_rds.replica_dns_name
}

output "temporal_database_vanity_dns_name" {
  description = "The vanity domain for the temporal RDS instance"
  value       = local.temporal_mysql_vanity_dns_name
}

output "temporal_database_dns_name" {
  value = module.temporal_rds.primary_dns_name
}

#======================================================
# DNS - Services
#======================================================
output "datawatch_dns_name" {
  description = "DNS name for the datawatch service"
  value       = module.datawatch.dns_name
}

output "datawatch_load_balancer_dns_name" {
  description = "The dns name of the datawatch load balancer"
  value       = module.datawatch.lb_dns_name
}

output "datawatch_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the datawatch load balancer"
  value       = module.datawatch.zone_id
}

output "backfillwork_dns_name" {
  description = "DNS name for the backfillwork service"
  value       = module.backfillwork.dns_name
}

output "backfillwork_load_balancer_dns_name" {
  description = "The dns name of the backfillwork load balancer"
  value       = module.backfillwork.lb_dns_name
}

output "backfillwork_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the backfillwork load balancer"
  value       = module.backfillwork.zone_id
}

output "datawork_dns_name" {
  description = "DNS name for the datawork service"
  value       = module.datawork.dns_name
}

output "datawork_load_balancer_dns_name" {
  description = "The dns name of the datawork load balancer"
  value       = module.datawork.lb_dns_name
}

output "datawork_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the datawork load balancer"
  value       = module.datawork.zone_id
}

output "indexwork_dns_name" {
  description = "DNS name for the indexwork service"
  value       = module.indexwork.dns_name
}

output "indexwork_load_balancer_dns_name" {
  description = "The dns name of the indexwork load balancer"
  value       = module.indexwork.lb_dns_name
}

output "indexwork_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the indexwork load balancer"
  value       = module.indexwork.zone_id
}

output "lineagework_dns_name" {
  description = "DNS name for the lineagework service"
  value       = module.lineagework.dns_name
}

output "lineagework_load_balancer_dns_name" {
  description = "The dns name of the lineagework load balancer"
  value       = module.lineagework.lb_dns_name
}

output "lineagework_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the lineagework load balancer"
  value       = module.lineagework.zone_id
}

output "metricwork_dns_name" {
  description = "DNS name for the metricwork service"
  value       = module.metricwork.dns_name
}

output "metricwork_load_balancer_dns_name" {
  description = "The dns name of the metricwork load balancer"
  value       = module.metricwork.lb_dns_name
}

output "metricwork_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the metricwork load balancer"
  value       = module.metricwork.zone_id
}

output "rootcause_dns_name" {
  description = "DNS name for the rootcause service"
  value       = module.rootcause.dns_name
}

output "rootcause_load_balancer_dns_name" {
  description = "The dns name of the rootcause load balancer"
  value       = module.rootcause.lb_dns_name
}

output "rootcause_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the rootcause load balancer"
  value       = module.rootcause.zone_id
}

output "monocle_dns_name" {
  description = "DNS name for the monocle service"
  value       = local.monocle_dns_name
}

output "monocle_load_balancer_dns_name" {
  description = "The dns name of the monocle load balancer"
  value       = module.monocle.lb_dns_name
}

output "monocle_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the monocle load balancer"
  value       = module.monocle.zone_id
}

output "internalapi_dns_name" {
  description = "DNS name for the internalapi service"
  value       = local.internalapi_dns_name
}

output "internalapi_load_balancer_dns_name" {
  description = "The dns name of the internalapi load balancer"
  value       = module.internalapi.lb_dns_name
}

output "internalapi_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the internalapi load balancer"
  value       = module.internalapi.zone_id
}

output "scheduler_dns_name" {
  description = "DNS name for the scheduler service"
  value       = local.scheduler_dns_name
}

output "scheduler_load_balancer_dns_name" {
  description = "The dns name of the scheduler load balancer"
  value       = module.scheduler.lb_dns_name
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

output "temporalui_dns_name" {
  description = "DNS name for the temporal user interface"
  value       = local.temporalui_dns_name
}

output "temporalui_load_balancer_dns_name" {
  description = "The dns name of the temporal user interface service load balancer"
  value       = module.temporalui.lb_dns_name
}

output "temporalui_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the temporal user interface service load balancer"
  value       = module.temporalui.zone_id
}

output "toretto_dns_name" {
  description = "DNS name for the toretto service"
  value       = local.toretto_dns_name
}

output "toretto_load_balancer_dns_name" {
  description = "The dns name of the toretto load balancer"
  value       = module.toretto.lb_dns_name
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
  value       = module.web.lb_dns_name
}

output "web_load_balancer_zone_id" {
  description = "The Route53 Zone ID of the web load balancer"
  value       = module.web.zone_id
}

output "ecs_task_role_id" {
  description = "Id of the ECS Task execution role.  This is useful for granting ECS access to secrets manager secrets."
  value       = local.create_ecs_role ? aws_iam_role.ecs[0].id : ""
}

#======================================================
# Networking bits
#======================================================
output "vpc_id" {
  description = "The VPC ID holding resources"
  value       = local.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the vpc"
  value       = one(module.vpc) == null ? "" : module.vpc[0].vpc_cidr_block
}

output "nat_public_ips" {
  description = "IP addresses for the NAT gateway on the NAT subnet.  This will return an empty list for BYO VPC installs regardless of if the BYO VPC has a NAT or not."
  value       = one(module.vpc) == null ? [] : module.vpc[0].nat_public_ips
}

output "all_route_table_ids" {
  value = one(module.vpc) == null ? [] : concat(
    module.vpc[0].database_route_table_ids,
    module.vpc[0].elasticache_route_table_ids,
    module.vpc[0].intra_route_table_ids,
    module.vpc[0].private_route_table_ids,
    module.vpc[0].public_route_table_ids,
  )
}

output "public_alb_subnet_ids" {
  description = "List of subnet IDs where public load balancers live"
  value       = local.public_alb_subnet_ids
}

output "internal_alb_subnet_ids" {
  description = "List of subnet IDs where internal load balancers live"
  value       = local.internal_service_alb_subnet_ids
}

output "application_subnet_ids" {
  description = "List of subnet IDs where the applications live"
  value       = local.application_subnet_ids
}

output "database_subnet_ids" {
  description = "List of subnet IDs for databases, only output if a VPC was created by this module"
  value       = local.create_vpc ? module.vpc[0].database_subnets : []
}

output "misc_subnet_ids" {
  description = "List of subnet IDs for miscellaneous services, e.g. elasticache. Only output if a VPC was created by this module"
  value       = local.create_vpc ? module.vpc[0].elasticache_subnets : []
}

output "elasticache_subnet_group_name" {
  description = "Elasticache subnet group name"
  value       = local.elasticache_subnet_group_name
}

output "database_subnet_group_name" {
  description = "Database subnet group name"
  value       = local.database_subnet_group_name
}

#======================================================
# Cloudwatch Log Groups
#======================================================
output "cloudwatch_log_group_name" {
  description = "Name of log group where application logs are sent"
  value       = aws_cloudwatch_log_group.bigeye.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of log group where application logs are sent"
  value       = aws_cloudwatch_log_group.bigeye.arn
}

output "cloudwatch_temporal_log_group_name" {
  description = "Name of log group where temporal logs are sent"
  value       = aws_cloudwatch_log_group.temporal.name
}

output "cloudwatch_temporal_log_group_arn" {
  description = "ARN of log group where temporal logs are sent"
  value       = aws_cloudwatch_log_group.temporal.arn
}

#======================================================
# S3
#======================================================
output "models_bucket_name" {
  description = "S3 bucket name for models"
  value       = aws_s3_bucket.models.id
}

output "models_bucket_arn" {
  description = "ARN for models bucket"
  value       = aws_s3_bucket.models.arn
}

output "large_payload_bucket_name" {
  description = "S3 bucket name for large payloads"
  value       = aws_s3_bucket.large_payload.id
}

output "large_payload_bucket_arn" {
  description = "ARN for large payloads bucket"
  value       = aws_s3_bucket.large_payload.arn
}
