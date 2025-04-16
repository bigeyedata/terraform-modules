variable "environment" {
  description = "Runtime Environment, i.e. test, prod, staging"
  type        = string
}

variable "instance" {
  description = "The name of the instance, e.g. adhoc01"
  type        = string
}

variable "tags_global" {
  description = "A set of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "internet_facing" {
  description = "Whether the entrypoint for the application should be available on the internet"
  type        = bool
  default     = true
}

variable "redundant_infrastructure" {
  description = "Whether or not to create redundant database, cache, and broker infrastructure"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
  default     = true
}

variable "enable_bigeye_admin_module" {
  description = "Whether to enable the bigeye-admin container"
  type        = bool
  default     = false
}

#======================================================
# Access Logs
#======================================================
variable "elb_access_logs_enabled" {
  description = "Whether to enable access logs for load balancers"
  type        = bool
  default     = false
}

variable "elb_access_logs_bucket" {
  description = "S3 bucket to send load balancer access logs"
  type        = string
  default     = ""
}

variable "elb_access_logs_prefix" {
  description = "S3 path prefix under which alb access logs should go."
  type        = string
  default     = ""
  validation {
    condition     = endswith(var.elb_access_logs_prefix, "/") == false
    error_message = "elb_access_logs_prefix should not end with a trailing slash"
  }
}

#======================================================
# Security Groups
#======================================================
variable "create_security_groups" {
  description = "Whether to create the security groups"
  type        = bool
  default     = true
}

variable "additional_ingress_cidrs" {
  description = "This setting allows additional CIDR blocks to ingress to the load balancers for the application. A common use case here is when the internet_facing is false, and ingress from a VPN must be allowed"
  type        = list(string)
  default     = []
}

variable "internal_additional_ingress_cidrs" {
  description = "This setting is similar to additional_ingress_cidrs, except it applies to internal resources. It is not recommended to use this, instead you should use the admin module using enable_bigeye_admin_module"
  type        = list(string)
  default     = []
}

variable "internal_extra_security_group_ids" {
  description = "Additional security group ids to attach to internal load balancers"
  type        = list(string)
  default     = []
}

#======================================================
# VPC
#======================================================
variable "vpc_availability_zones" {
  description = "The availability zones the subnets will be created in. If blank, they will be auto-created"
  type        = list(string)
  default     = []
}

variable "vpc_cidr_block" {
  description = "The CIDR block to allocate to the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_single_nat_gateway" {
  description = "Whether to create only a single NAT Gateway"
  type        = bool
  default     = true
}

variable "vpc_flow_logs_bucket_arn" {
  description = "ARN of the bucket to send flow logs to"
  type        = string
  default     = ""
}

#======================================================
# Bring your own IAM Roles
#======================================================
variable "ecs_service_role_arn" {
  description = "IAM Role ARN for the ECS execution role. If not specified, it will be created"
  type        = string
  default     = ""
}

variable "admin_container_ecs_task_role_arn" {
  description = "IAM Role ARN for the Admin container. If not specified, it will be created"
  type        = string
  default     = ""
}

variable "datawatch_task_role_arn" {
  description = "IAM Role ARN for the Datawatch services. If not specified, it will be created"
  type        = string
  default     = ""
}

variable "monocle_task_role_arn" {
  description = "IAM Role ARN for the Monocle/Toretto services. If not specified, it will be created"
  type        = string
  default     = ""
}

#======================================================
# Bring your own VPC
#======================================================
variable "byovpc_vpc_id" {
  description = "ID of the existing VPC to launch into"
  type        = string
  default     = ""
}

variable "byovpc_rabbitmq_subnet_ids" {
  description = "List of subnet IDs to launch RabbitMQ in. These do not need internet access."
  type        = list(string)
  default     = []
}

variable "byovpc_internal_subnet_ids" {
  description = "List of subnet IDs where internal load balancers will go. These do not need internet access."
  type        = list(string)
  default     = []
}

variable "byovpc_application_subnet_ids" {
  description = "List of subnet IDs where applications will operate. These should have egress to the internet."
  type        = list(string)
  default     = []
}

variable "byovpc_public_subnet_ids" {
  description = "List of subnet IDs to put web ALB. These should be internet-facing."
  type        = list(string)
  default     = []
}

variable "byovpc_redis_subnet_group_name" {
  description = "The name of the subnet group to launch Redis"
  type        = string
  default     = ""
}

variable "byovpc_database_subnet_group_name" {
  description = "The name of the database subnet group to launch databases"
  type        = string
  default     = ""
}

#======================================================
# DNS
#======================================================
variable "create_dns_records" {
  description = "Whether to set up DNS records"
  type        = bool
  default     = true
}

variable "top_level_dns_name" {
  description = "The top-level dns name. DNS records will be created in this Route53 hosted zone. The wildcard TLS certificate will be created for this dns name. All other dns names will be created as subdomains of this dns name"
  type        = string
  validation {
    condition     = length(var.top_level_dns_name) > 0
    error_message = "top_level_dns_name must be specified"
  }
}

variable "private_hosted_zone" {
  description = "Whether the top level hosted zone is private or not"
  type        = bool
  default     = false
}

variable "vanity_alias" {
  description = "If specified, will serve as a prefix for domain names"
  type        = string
  default     = ""
}

variable "use_top_level_dns_apex_as_vanity" {
  description = "If true, the top-level entrypoint domain for the application will be the APEX record of the Hosted Zone"
  type        = bool
  default     = false
}

#======================================================
# ECS
#======================================================
variable "ecs_enable_container_insights" {
  description = "Whether to enable container insights on the ECS cluster"
  type        = bool
  default     = false
}

variable "image_registry" {
  description = "The hostname of the image registry to pull from"
  type        = string
  default     = ""
}

variable "image_tag" {
  description = "The image tag to use"
  type        = string
  default     = "latest"
  validation {
    condition     = length(var.image_tag) > 0
    error_message = "image_tag must be specified"
  }
}

variable "image_repository_suffix" {
  description = "The repository suffix. For example if the repository is datawatch/test, the suffix is /test"
  type        = string
  default     = ""
}

variable "fargate_version" {
  description = "The ECS fargate version"
  type        = string
  default     = "1.4.0"
}

variable "efs_volume_enabled_services" {
  description = "A shared EFS volume can be mounted on core service containers.  This can be useful for containers to persist a heap dump on OOM for example.  Service names: datawatch, datawork, metricwork, lineagework, etc"
  type        = list(string)
  default     = []
}

variable "efs_volume_extra_security_group_ids" {
  description = "A list of additional security group ids to put onto the EFS volume"
  type        = list(string)
  default     = []
}

variable "efs_mount_point" {
  description = "Container path where the EFS volume will be mounted."
  type        = string
  default     = "/mnt"
}

#======================================================
# Datadog
#======================================================
variable "datadog_agent_enabled" {
  description = "Whether to run datadog agents alongside the main containers"
  type        = bool
  default     = false
}

variable "datadog_agent_image" {
  description = "The fully qualified image for the datadog agent"
  type        = string
  default     = "public.ecr.aws/bigeye/datadog/agent:7.49.0"
}

variable "datadog_agent_cpu" {
  description = "The amount of CPU to allocate to the datadog agent, in Mhz, e.g. 256"
  type        = number
  default     = 256
}

variable "datadog_agent_memory" {
  description = "The amount of Memory to allocate to the datadog agent, in MiB, e.g. 512"
  type        = number
  default     = 512
}

variable "datadog_agent_api_key_secret_arn" {
  description = "Secret ARN holding the datadog agent API Key"
  type        = string
  default     = ""
}

#======================================================
# AWS Firelens settings
#======================================================
variable "awsfirelens_enabled" {
  description = "If set to true, container logs are shipped via AWS firelens and not cloudwatch.  The AWS firelens side car container though is the exception and will continue to send logs to cloudwatch logs even if var.awsfirelens_enabled = true to facilitate debugging firelens issues."
  type        = bool
  default     = false
}

variable "awsfirelens_image" {
  description = "The full image for aws firelens, e.g. registry-host-name.com/repository/name:tag.  It is recommended to pin this to a specific tag for production systems vs relying on latest."
  type        = string
  default     = "amazon/aws-for-fluent-bit:latest"
}

variable "awsfirelens_cpu" {
  description = "The amount of CPU to allocate to the AWS firelens container, in Mhz, e.g. 256"
  type        = number
  default     = 256
}

variable "awsfirelens_memory" {
  description = "The amount of Memory to allocate to the AWS firelens container, in MiB, e.g. 512"
  type        = number
  default     = 256
}

variable "awsfirelens_host" {
  description = "The hostname of the destination for awsfirelens to deliver logs to.  Example: logs-endpoint.example.com"
  type        = string
  default     = ""
}

variable "awsfirelens_uri" {
  description = "The URI of the destination for awsfirelens to deliver logs to.  Example: /receiver/v1/http/<token>"
  type        = string
  default     = ""
}

#======================================================
# Redis
#======================================================
variable "redis_extra_security_group_ids" {
  description = "A list of additional security group ids to put onto redis"
  type        = list(string)
  default     = []
}

variable "redis_auth_token_secret_arn" {
  description = "The auth token to use with redis. If not provided, one will be generated"
  type        = string
  default     = ""
}

variable "redis_instance_type" {
  description = "Instance type for redis"
  type        = string
  default     = "cache.t4g.micro"
}

variable "redis_engine_version" {
  description = "Engine version for redis"
  type        = string
  default     = "6.2"
}

variable "redis_maintenance_window" {
  description = "The window of time to do maintenance, e.g. wed:01:00-wed:02:00"
  type        = string
  default     = "wed:01:00-wed:02:00"
}


#======================================================
# RabbitMQ
#======================================================
variable "byo_rabbitmq_endpoint" {
  description = "If managing your own RabbitMQ broker, use this variable to specify its endpoint (e.g. amqps://<host>:port). An Amazon MQ RabbitMQ broker will be managed in this module if byo_rabbitmq_endpoint is not set"
  type        = string
  default     = ""
}

variable "rabbitmq_user_name" {
  description = "The user name to log into RabbitMQ with"
  type        = string
  default     = "bigeye"
}

variable "rabbitmq_user_password_secret_arn" {
  description = "The ARN holding the password to log into RabbitMQ with. One will be created if not provided"
  type        = string
  default     = ""
}

variable "rabbitmq_extra_security_group_ids" {
  description = "A list of additional security group IDs to apply to the RabbitMQ broker.  See also rabbitmq_extra_ingress_cidr_blocks"
  type        = list(string)
  default     = []
}

variable "rabbitmq_extra_ingress_cidr_blocks" {
  description = "A list of additional ingress cidrs to allow access to both the AMQPS port and the HTTPS admin port.  This is necessary to use in cases where it is required to grant access to RabbitMQ externally as AWS MQ does not allow modifying security groups after MQ creation."
  type        = list(string)
  default     = []
}

variable "rabbitmq_instance_type" {
  description = "The instance type of the RabbitMQ broker"
  type        = string
  default     = "mq.t3.micro"
}

variable "rabbitmq_cluster_enabled" {
  description = "Whether to use the Multi-AZ Cluster mode. If unset, it will defer to the redundant_infrastructure variable"
  type        = bool
  default     = null
}

variable "rabbitmq_engine_version" {
  description = "Engine version for RabbitMQ. See - https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/rabbitmq-version-management.html"
  type        = string
  default     = "3.13"
}

variable "rabbitmq_maintenance_day" {
  description = "The day of week to schedule maintenance, e.g. WEDNESDAY"
  type        = string
  default     = "WEDNESDAY"
}

variable "rabbitmq_maintenance_time" {
  description = "The time of day, in UTC, to schedule maintenance, e.g. 22:00"
  type        = string
  default     = "22:00"
}

#======================================================
# Security
#======================================================
variable "alb_ssl_policy" {
  description = "Name of the SSL Policy for the listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "acm_certificate_arn" {
  description = "If you are bringing your own certificate, specify its arn here. It should be a wildcard certificate for '*.{top_level_dns_name}'"
  type        = string
  default     = ""
}

#======================================================
# Application Variables - General
#======================================================
variable "sentry_event_level" {
  description = "The event level for sentry"
  type        = string
  default     = ""
}

variable "sentry_dsn_secret_arn" {
  description = "ARN for secret holding sentry DSN"
  type        = string
  default     = ""
}

variable "temporal_namespace" {
  description = ""
  type        = string
  default     = "default"
}

variable "temporal_use_default_certificates" {
  description = "whether to use default certificates"
  type        = bool
  default     = true
}

variable "auth0_domain" {
  description = "domain for the Auth0 OAuth flow"
  type        = string
  default     = ""
}

variable "auth0_client_id_secretsmanager_arn" {
  description = "secrets manager ARN for the Auth0 client ID"
  type        = string
  default     = ""
}

variable "auth0_client_secret_secretsmanager_arn" {
  description = "secrets manager ARN for the Auth0 client secret"
  type        = string
  default     = ""
}

variable "slack_client_id_secretsmanager_arn" {
  description = "secrets manager ARN for the slack client ID"
  type        = string
  default     = ""
}

variable "slack_client_secret_secretsmanager_arn" {
  description = "secrets manager ARN for the slack client secret"
  type        = string
  default     = ""
}

variable "slack_client_signing_secret_secretsmanager_arn" {
  description = "secrets manager ARN for the slack client signing secret"
  type        = string
  default     = ""
}

variable "stitch_api_token_secretsmanager_arn" {
  description = "secrets manager arn for stitch API token"
  type        = string
  default     = ""
}

variable "byomailserver_smtp_host" {
  description = "Hostname of SMTP server.  This is for routing email notifications through your customer SMTP server vs using Bigeye's.  Ex. smtp.example.com"
  type        = string
  default     = ""
}

variable "byomailserver_smtp_port" {
  description = "Port for the SMTP server.  This is for routing email notifications through your customer SMTP server vs using Bigeye's."
  type        = string
  default     = ""
}

variable "byomailserver_smtp_user" {
  description = "SMTP credentials for your custom SMPT server."
  type        = string
  default     = ""
}


variable "byomailserver_smtp_from_address" {
  description = "Set the from address for email notifications from Bigeye.  This should be from a domain the mail server is verified to be able to send emails as, ie bigeye@example.com."
  type        = string
  default     = ""
}

variable "byomailserver_smtp_password_secret_arn" {
  description = "secrets manager ARN for the SMTP password."
  type        = string
  default     = ""
}

#======================================================
# Application Variables - Monocle
#======================================================
variable "monocle_image_tag" {
  description = "The image tag to use for monocle, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "monocle_desired_count" {
  description = "Initial capacity before autoscaling adjustments"
  type        = number
  default     = 2
}

variable "monocle_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "monocle_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 2048
}

variable "monocle_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "monocle_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "monocle_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "monocle_extra_security_group_ids" {
  description = "Additional security group ids to monocle"
  type        = list(string)
  default     = []
}

variable "monocle_lb_extra_security_group_ids" {
  description = "Additional security group ids to monocle ALB"
  type        = list(string)
  default     = []
}

variable "ml_models_s3_bucket_name_override" {
  description = "Override for the monocle ML models bucket. Use of this variable is not recommended."
  type        = string
  default     = ""
}

variable "monocle_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

variable "monocle_autoscaling_config" {
  type = object({
    min_capacity       = number
    max_capacity       = number
    type               = string
    target_utilization = number
  })
  default = {
    min_capacity       = 2
    max_capacity       = 10
    type               = "request_count_per_target"
    target_utilization = 15
  }
  validation {
    condition     = contains(["none", "cpu_utilization", "request_count_per_target"], var.monocle_autoscaling_config.type)
    error_message = "Must be one of: none, cpu_utilization, request_count_per_target"
  }
}

#======================================================
# Application Variables - Toretto
#======================================================
variable "toretto_image_tag" {
  description = "The image tag to use for toretto, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "toretto_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "toretto_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "toretto_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 2048
}

variable "toretto_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "toretto_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "toretto_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "toretto_extra_security_group_ids" {
  description = "Additional security group ids to toretto"
  type        = list(string)
  default     = []
}

variable "toretto_lb_extra_security_group_ids" {
  description = "Additional security group ids to toretto ALB"
  type        = list(string)
  default     = []
}

variable "toretto_autoscaling_enabled" {
  description = "Whether toretto autoscaling is enabled. Note - if you change this variable, it changes the terraform resource that is created. You must run 'terraform state mv' in order to gracefully make this change"
  type        = bool
  default     = false
}

variable "toretto_autoscaling_threshold_step1" {
  description = "The first autothreshold metric step"
  type        = number
  default     = 20
}

variable "toretto_autoscaling_threshold_step2" {
  description = "The second autothreshold metric step"
  type        = number
  default     = 500
}

variable "toretto_autoscaling_threshold_step3" {
  description = "The third and final autothreshold metric step"
  type        = number
  default     = 1000
}

variable "toretto_desired_count_step1" {
  description = "How many toretto tasks to run after reaching the first autoscaling step, if not specified it will be twice the toretto_desired_count"
  type        = number
  default     = null
}

variable "toretto_desired_count_step2" {
  description = "How many toretto tasks to run after reaching the second autoscaling step, if not specified it will be three times the toretto_desired_count"
  type        = number
  default     = null
}

variable "toretto_desired_count_step3" {
  description = "How many toretto tasks to run after reaching the third and final autoscaling step, if not specified it will be four times the toretto_desired_count"
  type        = number
  default     = null
}

variable "toretto_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

#======================================================
# RDS Maintenance
#======================================================
variable "rds_backup_window" {
  description = "The window of time to take daily backups"
  type        = string
  default     = "08:00-09:00"
}

variable "rds_maintenance_window" {
  description = "The window of time during the week to perform maintenance"
  type        = string
  default     = "wed:01:00-wed:02:00"
}

variable "rds_performance_insights_retention_period" {
  description = "Days to keep performance insights"
  type        = number
  default     = 7
}

variable "rds_apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = false
}

variable "replica_rds_performance_insights_retention_period" {
  description = "Days to keep performance insights for the replica"
  type        = number
  default     = 7
}

#======================================================
# Application Variables - HAProxy
#======================================================
variable "haproxy_image_tag" {
  description = "The image tag to use for haproxy, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "haproxy_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "haproxy_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "haproxy_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 2048
}

variable "haproxy_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "haproxy_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "haproxy_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "haproxy_extra_security_group_ids" {
  description = "Additional security group ids to haproxy"
  type        = list(string)
  default     = []
}

variable "haproxy_lb_extra_security_group_ids" {
  description = "Additional security group ids to haproxy ALB"
  type        = list(string)
  default     = []
}

#======================================================
# Application Variables - Web
#======================================================
variable "web_image_tag" {
  description = "The image tag to use for web, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "web_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "web_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "web_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 2048
}

variable "web_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "web_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "web_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "web_extra_security_group_ids" {
  description = "Additional security group ids to web"
  type        = list(string)
  default     = []
}

variable "web_lb_extra_security_group_ids" {
  description = "Additional security group ids to web ALB"
  type        = list(string)
  default     = []
}

#======================================================
# Application Variables - TemporalUI
#======================================================
variable "temporalui_image_tag" {
  description = "The image tag to use for temporalui, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "temporalui_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "temporalui_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "temporalui_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 2048
}

variable "temporalui_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "temporalui_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "temporalui_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "temporalui_extra_security_group_ids" {
  description = "Additional security group ids to temporalui"
  type        = list(string)
  default     = []
}

variable "temporalui_lb_extra_security_group_ids" {
  description = "Additional security group ids to temporalui ALB"
  type        = list(string)
  default     = []
}

#======================================================
# Application Variables - Temporal
#======================================================
variable "temporal_image_tag" {
  description = "The image tag to use for temporal, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "temporal_rds_db_name" {
  description = "The database name for Temporal's application DB"
  type        = string
  default     = "temporal"
}

variable "temporal_rds_snapshot_identifier" {
  description = "The snapshot identifier of the snapshot to create the database from"
  type        = string
  default     = null
}

variable "temporal_rds_allocated_storage" {
  description = "The amount of storage to allocate to the DB"
  type        = number
  default     = 20
}

variable "temporal_rds_max_allocated_storage" {
  description = "The maximum amount of storage to allocate to the DB"
  type        = number
  default     = 1024
}

variable "temporal_rds_iops" {
  description = "iops for the temporal primary DB.  Null will use the defaults for gp3 which is recommended."
  type        = number
  default     = null
}

variable "temporal_rds_instance_type" {
  description = "The instance type to use for RDS"
  type        = string
  default     = "db.t4g.small"
}

variable "temporal_rds_root_user_password_secret_arn" {
  description = "The secrets manager arn for the root user password for temporal. One will be created if not provided"
  type        = string
  default     = ""
}

variable "temporal_rds_engine_version" {
  description = "The mysql engine version"
  type        = string
  default     = "8.0.40"
}

variable "temporal_rds_enable_performance_insights" {
  description = "Whether to enable performance insights. Default to true if the database type supports it"
  type        = bool
  default     = true
}

variable "temporal_rds_backup_retention_period" {
  description = "Days to keep backups.  Workflow data is basically what was in the queue and is not mission critical to restore in the event of an extended downtime or DR event."
  type        = number
  default     = 10
}

variable "temporal_rds_enabled_logs" {
  description = "A list of log types to enable. By default only error logs are enabled"
  type        = list(string)
  default     = ["error"]
}

variable "temporal_rds_extra_security_group_ids" {
  description = "Extra security groups to put on the RDS instance"
  type        = list(string)
  default     = []
}

variable "temporal_rds_additional_tags" {
  description = "Additional tags to apply to the temporal RDS resources"
  type        = map(string)
  default     = {}
}

variable "temporal_rds_options" {
  description = "A list of maps containing db option group options, maps should have keys 'name' and 'value'.  If no values are set, the default option group is used."
  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

variable "temporal_rds_default_parameters" {
  description = "Default parameters to use. These provide a baseline set of parameters. Can add to them using temporal_rds_parameters variable."
  type = map(object({
    value        = any
    apply_method = optional(string)
  }))
  default = {
    log_output = {
      value        = "FILE"
      apply_method = "immediate"
    }
  }
}

variable "temporal_rds_parameters" {
  description = "Database parameters to use."
  type = map(object({
    value        = any
    apply_method = optional(string)
  }))
  default = {}
}

variable "temporal_rds_primary_additional_tags" {
  description = "Additional tags to apply to the temporal RDS primary DB.  This is merged with temporal_rds_additional_tags for the primary"
  type        = map(string)
  default     = {}
}

variable "temporal_rds_replica_additional_tags" {
  description = "Additional tags to apply to the temporal RDS replica DB.  This is merged with temporal_rds_additional_tags for the replica"
  type        = map(string)
  default     = {}
}

variable "temporal_opensearch_enabled" {
  description = "Whether opensearch is enabled for temporal visibility store. If false, temporal uses instead. Opensearch is recommended for all systems. Using SQL will degrade performance in systems with modest amounts of traffic."
  type        = bool
  default     = true
}

variable "temporal_opensearch_engine_version" {
  description = "The opensearch engine version"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "temporal_opensearch_instance_type" {
  description = "The opensearch instance type to use"
  type        = string
  default     = "t3.medium.search"
}

variable "temporal_opensearch_master_user_password_secret_arn" {
  description = "ARN for secretsmanager secret holding the opensearch master user password. One will be created if not provided."
  type        = string
  default     = ""
}

variable "temporal_opensearch_extra_security_group_ids" {
  description = "Additional security group IDs to give to temporal opensearch"
  type        = list(string)
  default     = []
}

variable "temporal_opensearch_master_instance_type" {
  description = "The opensearch instance type to use for master nodes.  Only applicable if var.redundant_infrastructure = true"
  type        = string
  default     = "t3.medium.search"
}

#======================================================
# Application Variables - Temporal Components
#======================================================
variable "temporal_desired_count" {
  description = "The desired number of temporal components, applies to frontend, internal_frontend, history, matching, and worker services if those are not set"
  type        = number
  default     = 1
}

variable "temporal_frontend_desired_count" {
  description = "The desired number of temporal frontend services, defaults to temporal_desired_count if not set"
  type        = number
  default     = null
}

variable "temporal_internal_frontend_desired_count" {
  description = "The desired number of temporal internal-frontend services, defaults to temporal_desired_count if not set"
  type        = number
  default     = null
}

variable "temporal_history_desired_count" {
  description = "The desired number of temporal history services, defaults to temporal_desired_count if not set"
  type        = number
  default     = null
}

variable "temporal_matching_desired_count" {
  description = "The desired number of temporal matching services, defaults to temporal_desired_count if not set"
  type        = number
  default     = null
}

variable "temporal_worker_desired_count" {
  description = "The desired number of temporal worker services, defaults to temporal_desired_count if not set"
  type        = number
  default     = null
}

variable "temporal_cpu" {
  description = "Amount of CPU to allocate for temporal. Applies to temporal frontend, internal_frontend, history, matching, and worker services if those are not specified"
  type        = number
  default     = 1024
}

variable "temporal_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 2048
}

variable "temporal_frontend_cpu" {
  description = "Amount of CPU to allocate to the temporal frontend service. Defaults to temporal_cpu if not set"
  type        = number
  default     = null
}

variable "temporal_frontend_memory" {
  description = "Amount of Memory in MB to allocate to the temporal frontend service. Defaults to temporal_memory if not set"
  type        = number
  default     = null
}

variable "temporal_internal_frontend_cpu" {
  description = "Amount of CPU to allocate to the temporal internal-frontend service. Defaults to temporal_cpu if not set"
  type        = number
  default     = null
}

variable "temporal_internal_frontend_memory" {
  description = "Amount of Memory in MB to allocate to the temporal internal-frontend service. Defaults to temporal_memory if not set"
  type        = number
  default     = null
}

variable "temporal_history_cpu" {
  description = "Amount of CPU to allocate to the temporal history service. Defaults to temporal_cpu if not set"
  type        = number
  default     = null
}

variable "temporal_history_memory" {
  description = "Amount of Memory in MB to allocate to the temporal history service. Defaults to temporal_memory if not set"
  type        = number
  default     = null
}

variable "temporal_matching_cpu" {
  description = "Amount of CPU to allocate to the temporal matching service. Defaults to temporal_cpu if not set"
  type        = number
  default     = null
}

variable "temporal_matching_memory" {
  description = "Amount of Memory in MB to allocate to the matching frontend service. Defaults to temporal_memory if not set"
  type        = number
  default     = null
}

variable "temporal_worker_cpu" {
  description = "Amount of CPU to allocate to the temporal worker service. Defaults to temporal_cpu if not set"
  type        = number
  default     = null
}

variable "temporal_worker_memory" {
  description = "Amount of Memory in MB to allocate to the temporal worker service. Defaults to temporal_memory if not set"
  type        = number
  default     = null
}

variable "temporal_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "temporal_frontend_additional_environment_vars" {
  description = "Additional enviromnent variables to give the temporal frontend application"
  type        = map(string)
  default     = {}
}

variable "temporal_internal_frontend_additional_environment_vars" {
  description = "Additional enviromnent variables to give the temporal internal-frontend application"
  type        = map(string)
  default     = {}
}

variable "temporal_history_additional_environment_vars" {
  description = "Additional enviromnent variables to give the temporal history application"
  type        = map(string)
  default     = {}
}

variable "temporal_matching_additional_environment_vars" {
  description = "Additional enviromnent variables to give the temporal matching application"
  type        = map(string)
  default     = {}
}

variable "temporal_worker_additional_environment_vars" {
  description = "Additional enviromnent variables to give the temporal worker application"
  type        = map(string)
  default     = {}
}

variable "temporal_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "temporal_extra_security_group_ids" {
  description = "Additional security group IDs to give to temporal"
  type        = list(string)
  default     = []
}

variable "temporal_lb_extra_security_group_ids" {
  description = "Additional security group IDs to give to temporal LB"
  type        = list(string)
  default     = []
}

variable "temporal_per_namespace_worker_count" {
  description = "Controls number of per-ns (scheduler, batcher, etc.) workers to run per namespace"
  type        = string
  default     = null
}

variable "temporal_max_concurrent_workflow_task_pollers" {
  description = "Number of pollers performing poll requests waiting on Workflow / Activity task queue and delivering the tasks to the executors"
  type        = string
  default     = null
}

variable "temporal_num_history_shards" {
  description = "Number of history shards"
  type        = number
  default     = 512
}

variable "temporal_internet_facing" {
  description = "Whether the temporal network load balancer needs to be public facing or not. Only necessary when using agent"
  type        = bool
  default     = false
}

variable "temporal_logging_enabled" {
  description = "Set to false to disable awslogs log driver for the temporal container.  This can be useful to save Cloudwatch logging costs if you never look at the Temporal server logs, which are occasionally for debugging."
  type        = bool
  default     = true
}

variable "temporal_frontend_persistence_max_qps" {
  description = "Maximum number queries per second that the Frontend Service host can send to the Persistence store."
  type        = string
  default     = 2000
}

variable "temporal_history_persistence_max_qps" {
  description = "Maximum number queries per second that the History Service host can send to the Persistence store."
  type        = string
  default     = 9000
}

variable "temporal_matching_persistence_max_qps" {
  description = "Maximum number queries per second that the Matching Service host can send to the Persistence store."
  type        = string
  default     = 9000
}

variable "temporal_worker_persistence_max_qps" {
  description = "Maximum number queries per second that the Worker Service host can send to the Persistence store."
  type        = string
  default     = 1000
}

variable "temporal_system_visibility_persistence_max_read_qps" {
  description = "Maximum number queries per second that Visibility database can receive for read operations."
  type        = string
  default     = 9000
}

variable "temporal_system_visibility_persistence_max_write_qps" {
  description = "Maximum number queries per second that Visibility database can receive for write operations."
  type        = string
  default     = 9000
}

#======================================================
# Application Variables - Temporal Clients (job executor)
#======================================================
variable "temporal_client_agent_heartbeat_wf_exec_size" {
  description = "Controls agent-heartbeat workflow execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_agent_heartbeat_act_exec_size" {
  description = "Controls agent-heartbeat activity execution thread count"
  type        = number
  default     = 20
}

variable "temporal_client_collect_lineage_wf_exec_size" {
  description = "Controls collect-lineage workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_collect_lineage_act_exec_size" {
  description = "Controls collect-lineage activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_run_metrics_wf_exec_size" {
  description = "Controls run-metrics.v1 workflow execution thread count"
  type        = number
  default     = 8
}

variable "temporal_client_run_metrics_act_exec_size" {
  description = "Controls run-metrics.v1 activity execution thread count"
  type        = number
  default     = 10
}

variable "temporal_client_delete_source_wf_exec_size" {
  description = "Controls delete-source.v1 workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_delete_source_act_exec_size" {
  description = "Controls delete-source.v1 activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_external_ticket_wf_exec_size" {
  description = "Controls external-ticket workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_external_ticket_act_exec_size" {
  description = "Controls external-ticket activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_get_samples_wf_exec_size" {
  description = "Controls get-samples.v1 workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_get_samples_act_exec_size" {
  description = "Controls get-samples.v1 activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_indexing_wf_exec_size" {
  description = "Controls indexing.v1 workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_indexing_act_exec_size" {
  description = "Controls indexing.v1 activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_issue_ai_overview_wf_exec_size" {
  description = "Controls issue-ai-overview workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_issue_ai_overview_act_exec_size" {
  description = "Controls issue-ai-overview activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_issue_notify_wf_exec_size" {
  description = "Controls issue-notify workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_issue_notify_act_exec_size" {
  description = "Controls issue-notify activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_issue_root_cause_wf_exec_size" {
  description = "Controls issue-root-cause workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_issue_root_cause_act_exec_size" {
  description = "Controls issue-root-cause activity execution thread count"
  type        = number
  default     = 10
}

variable "temporal_client_issue_update_wf_exec_size" {
  description = "Controls issue-update workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_issue_update_act_exec_size" {
  description = "Controls issue-update activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_reconciliation_wf_exec_size" {
  description = "Controls reconciliation workflow execution thread count.  This is used for reconciling metric run schedules."
  type        = number
  default     = 2
}

variable "temporal_client_reconciliation_act_exec_size" {
  description = "Controls reconciliation activity execution thread count.  This is used for reconciling metric run schedules."
  type        = number
  default     = 5
}

variable "temporal_client_trigger_batch_metric_run_wf_exec_size" {
  description = "Controls trigger-batch-metric-run workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_trigger_batch_metric_run_act_exec_size" {
  description = "Controls trigger-batch-metric-run activity execution thread count"
  type        = number
  default     = 100
}

variable "temporal_client_source_lineage_wf_exec_size" {
  description = "Controls source-lineage workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_source_lineage_act_exec_size" {
  description = "Controls source-lineage activity execution thread count"
  type        = number
  default     = 5
}

variable "temporal_client_mc_lineage_wf_exec_size" {
  description = "Controls metacenter-lineage workflow execution thread count"
  type        = number
  default     = 2
}

variable "temporal_client_mc_lineage_act_exec_size" {
  description = "Controls metacenter-lineage activity execution thread count"
  type        = number
  default     = 10
}

variable "temporal_client_refresh_scorecard_wf_exec_size" {
  description = "Controls refresh-scorecards workflow execution thread count.  This is used for refreshing data used in scorecards."
  type        = number
  default     = 2
}

variable "temporal_client_refresh_scorecard_act_exec_size" {
  description = "Controls refresh-scorecards activity execution thread count.  This is used for refreshing data used in scorecards."
  type        = number
  default     = 10
}

variable "temporal_client_monocle_invalidation_wf_exec_size" {
  description = "Controls monocle-invalidation workflow execution thread count.  This is used for invalidating Monocle ML models for serving autothresholds."
  type        = number
  default     = 2
}

variable "temporal_client_monocle_invalidation_act_exec_size" {
  description = "Controls monocle-invalidation activity execution thread count.  This is used for invalidating Monocle ML models for serving autothresholds."
  type        = number
  default     = 5
}

#======================================================
# Application Variables - Datawatch
#======================================================
variable "datawatch_image_tag" {
  description = "The image tag to use for datawatch, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "adminpages_password_secret_arn" {
  description = "Secret arn holding the password for the adminpages. One will be created if not provided"
  type        = string
  default     = ""
}

variable "datawatch_robot_password_secret_arn" {
  description = "ARN for the secretsmanager secret holding the robot password. One will be created if not provided"
  type        = string
  default     = ""
}

variable "datawatch_robot_agent_api_key_secret_arn" {
  description = "ARN for the secretsmanager secret holding the Robot Agent API Key. If providing it yourself, format it with 'bigeye_agent_' followed by 40 random alphanumeric characters. One will be created if not provided"
  type        = string
  default     = ""
}

variable "datawatch_base_encryption_secret_arn" {
  description = "ARN for secretsmanager secret holding the base encryption secret. This will be used for securely storing sensitive information such as connection info. One will be created if not provided."
  type        = string
  default     = ""
}

variable "datawatch_base_salt_secret_arn" {
  description = "ARN for secretsmanager secret holding the base salt value. This will be used for securely storing sensitive information such as connection info. One will be created if not provided."
  type        = string
  default     = ""
}

variable "datawatch_encrypt_secrets_with_kms_enabled" {
  description = "Flag for enabling KMS secret encryption. Setting this value to false after it has been set to true is NOT supported and will break your installation."
  type        = bool
  default     = false
}

variable "datawatch_kms_key_arn" {
  description = "ARN of existing KMS Key to use for data encryption"
  type        = string
  default     = ""
}

variable "datawatch_kms_key_rotation_days" {
  description = "The KMS key rotation period"
  type        = number
  default     = 120
}

variable "datawatch_db_name" {
  description = "The database name to use in the connection string for Datawatch apps. This is here because some RDS instances have been created with a blank DB name, so it can't be assumed the RDS DB name is a valid Database name for the connection string. If not specified, it will default to `datawatch_rds_db_name`"
  type        = string
  default     = ""
}

variable "datawatch_rds_db_name" {
  description = "The database name for Datawatch's application DB"
  type        = string
  default     = "bigeye"
}

variable "datawatch_rds_root_user_name" {
  description = "The root user name for datawatch"
  type        = string
  default     = "bigeye"
}

variable "datawatch_rds_snapshot_identifier" {
  description = "The snapshot identifier of the snapshot to create the database from"
  type        = string
  default     = null
}

variable "datawatch_rds_allocated_storage" {
  description = "The amount of storage to allocate to the DB"
  type        = number
  default     = 20
}

variable "datawatch_rds_max_allocated_storage" {
  description = "The maximum amount of storage to allocate to the DB"
  type        = number
  default     = 2048
}

variable "datawatch_rds_iops" {
  description = "iops for the datawatch primary DB.  Null will use the defaults for gp3 which is recommended."
  type        = number
  default     = null
}

variable "datawatch_rds_instance_type" {
  description = "The instance type to use for RDS"
  type        = string
  default     = "db.t4g.small"
}

variable "datawatch_rds_root_user_password_secret_arn" {
  description = "The secrets manager arn for the root user password for datawatch. One will be created if not provided"
  type        = string
  default     = ""
}

variable "datawatch_rds_engine_version" {
  description = "The mysql engine version"
  type        = string
  default     = "8.0.40"
}

variable "datawatch_rds_enable_performance_insights" {
  description = "Whether to enable performance insights. Default to true if the database type supports it"
  type        = bool
  default     = true
}

variable "datawatch_rds_enhanced_monitoring_interval" {
  description = "interval seconds for running enhanced monitoring, 0 means off"
  type        = number
  default     = 0
}

variable "datawatch_rds_enhanced_monitoring_role_arn" {
  description = "Role ARN to use for enhanced monitoring"
  type        = string
  default     = ""
}

variable "datawatch_rds_backup_retention_period" {
  description = "Days to keep backups"
  type        = number
  default     = 30
}

variable "datawatch_rds_enabled_logs" {
  description = "A list of log types to enable. By default only error logs are enabled"
  type        = list(string)
  default     = ["error"]
}

variable "datawatch_rds_options" {
  description = "A list of maps containing db option group options, maps should have keys 'name' and 'value'.  If no values are set, the default option group is used."
  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

variable "datawatch_rds_default_parameters" {
  description = "Default parameters to use. These provide a baseline set of parameters. Can add to them using datawatch_rds_parameters variable."
  type = map(object({
    value        = any
    apply_method = optional(string)
  }))
  default = {
    binlog_format = {
      value = "ROW"
    }
    character_set_server = {
      value = "utf8mb4"
    }
    innodb_lock_wait_timeout = {
      value = 300
    }
    lock_wait_timeout = {
      value = 300
    }
    log_bin_trust_function_creators = {
      value = "1"
    }
    log_output = {
      value        = "FILE"
      apply_method = "immediate"
    }
    long_query_time = {
      value = 120
    }
    performance_schema = {
      value        = 1
      apply_method = "pending-reboot"
    }
    skip_name_resolve = {
      value        = 1
      apply_method = "pending-reboot"
    }
  }
}

variable "datawatch_rds_parameters" {
  description = "Additional db parameters to use. These are applied on top of datawatch_rds_default_parameters"
  type = map(object({
    value        = any
    apply_method = optional(string)
  }))
  default = {}
}

variable "datawatch_rds_replica_enabled" {
  description = "Whether to use a read replica for datawatch"
  type        = bool
  default     = false
}

variable "datawatch_rds_replica_engine_version" {
  description = "Defaults to engine_version.  This is primarily used for engine upgrades as the replica has to be upgraded first."
  type        = string
  default     = ""
}

variable "datawatch_rds_replica_iops" {
  description = "iops for the datawatch replica DB.  Null will use the defaults for gp3 which is recommended."
  type        = number
  default     = null
}

variable "datawatch_rds_replica_instance_type" {
  description = "The instance type to use for datawatch read replica"
  type        = string
  default     = "db.t4g.small"
}

variable "datawatch_rds_replica_backup_retention_period" {
  description = "Days to keep backups for the replica"
  type        = number
  default     = 1
}

variable "datawatch_replica_rds_options" {
  description = "A list of maps containing db option group options for the replica, maps should have keys 'name' and 'value'.  If no values are set, the default option group is used."
  type = list(object({
    option_name = string
    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

variable "datawatch_rds_replica_default_parameters" {
  description = "Default parameters to use for the replica. These provide a baseline set of parameters. Can add to them using datawatch_rds_replica_parameters variable."
  type = map(object({
    value        = any
    apply_method = optional(string)
  }))
  default = {
    binlog_format = {
      value = "ROW"
    }
    log_bin_trust_function_creators = {
      value = "1"
    }
    log_output = {
      value        = "FILE"
      apply_method = "immediate"
    }
    performance_schema = {
      value        = 1
      apply_method = "pending-reboot"
    }
    skip_name_resolve = {
      value        = 1
      apply_method = "pending-reboot"
    }
  }
}

variable "datawatch_rds_replica_parameters" {
  description = "Additional db parameters to use on the replica. These are applied on top of datawatch_rds_replica_default_parameters"
  type = map(object({
    value        = any
    apply_method = optional(string)
  }))
  default = {}
}

variable "datawatch_rds_extra_security_group_ids" {
  description = "Extra security groups to put on the RDS instance"
  type        = list(string)
  default     = []
}

variable "datawatch_rds_additional_tags" {
  description = "Additional tags to apply to the datawatch RDS resources"
  type        = map(string)
  default     = {}
}

variable "datawatch_rds_primary_additional_tags" {
  description = "Additional tags to apply to the datawatch RDS primary DB.  This is merged with datawatch_rds_additional_tags for the primary"
  type        = map(string)
  default     = {}
}

variable "datawatch_rds_replica_additional_tags" {
  description = "Additional tags to apply to the datawatch RDS replica DB.  This is merged with datawatch_rds_additional_tags for the replica"
  type        = map(string)
  default     = {}
}

variable "datawatch_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "datawatch_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 2048
}

variable "datawatch_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "datawatch_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "datawatch_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "datawatch_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "datawatch_extra_security_group_ids" {
  description = "Additional security group ids to datawatch"
  type        = list(string)
  default     = []
}

variable "datawatch_lb_extra_security_group_ids" {
  description = "Additional security group ids to datawatch ALB"
  type        = list(string)
  default     = []
}

variable "datawatch_mysql_maxsize" {
  description = "Max size for mysql"
  type        = number
  default     = 140
}

variable "datawatch_feature_analytics_logging_enabled" {
  description = "Whether feature analytics logs are enabled"
  type        = bool
  default     = false
}

variable "datawatch_feature_analytics_send_enabled" {
  description = "Whether feature analytics logs are sent"
  type        = bool
  default     = false
}

variable "datawatch_feature_jvm_memory_leak_fix" {
  description = "DEPRECATED: This flag no longer does anything.  It will be removed in a future release"
  type        = bool
  default     = false
}

variable "datawatch_request_body_logging_enabled" {
  description = "DEPRECATED: This flag will no longer do anything.  It will be removed in a future release"
  type        = bool
  default     = true
}

variable "datawatch_request_auth_logging_enabled" {
  description = "Whether request auth logs are enabled"
  type        = bool
  default     = false
}

variable "datawatch_class_loading_logging_enabled" {
  description = "Verbose debug logging of every class load/unload event.  This is useful to trace out of memory due to compressed class space exhaustion.  Not recommended to set to true for production"
  type        = bool
  default     = false
}

variable "datawatch_stitch_schema_name" {
  description = "stitch schema name"
  type        = string
  default     = ""
}

variable "datawatch_external_logging_level" {
  description = "INFO or DEBUG"
  type        = string
  default     = "INFO"
}

variable "datawatch_slack_has_dedicated_app" {
  description = ""
  type        = bool
  default     = false
}

variable "datawatch_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "datawatch_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

variable "datawatch_max_request_size" {
  description = "Controls the max request size for API calls to datawatch. It is unusual to need to adjust this, contact Bigeye support."
  default     = "100000000"
  type        = string
}

variable "datawatch_temporal_large_payload_enabled" {
  description = "Controls if datawatch common services have the temporal large payload converter enabled.  It is not common to deviate from the default setting."
  type        = bool
  default     = false
}

#======================================================
# Application Variables - Backfillwork
#======================================================
variable "backfillwork_image_tag" {
  description = "The image tag to use for backfillwork, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "backfillwork_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "backfillwork_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "backfillwork_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "backfillwork_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "backfillwork_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "backfillwork_extra_security_group_ids" {
  description = "Additional security group ids to backfillwork"
  type        = list(string)
  default     = []
}

variable "backfillwork_lb_extra_security_group_ids" {
  description = "Additional security group ids to backfillwork ALB"
  type        = list(string)
  default     = []
}

variable "backfillwork_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "backfillwork_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}


#======================================================
# Application Variables - Datawork
#======================================================
variable "datawork_image_tag" {
  description = "The image tag to use for datawork, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "datawork_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "datawork_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "datawork_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "datawork_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "datawork_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "datawork_extra_security_group_ids" {
  description = "Additional security group ids to datawork"
  type        = list(string)
  default     = []
}

variable "datawork_lb_extra_security_group_ids" {
  description = "Additional security group ids to datawork ALB"
  type        = list(string)
  default     = []
}

variable "datawork_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "datawork_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

#======================================================
# Application Variables - Indexwork
#======================================================
variable "indexwork_image_tag" {
  description = "The image tag to use for indexwork, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "indexwork_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 2
}

variable "indexwork_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 2048
}

variable "indexwork_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "indexwork_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "indexwork_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "indexwork_extra_security_group_ids" {
  description = "Additional security group ids to indexwork"
  type        = list(string)
  default     = []
}

variable "indexwork_lb_extra_security_group_ids" {
  description = "Additional security group ids to indexwork ALB"
  type        = list(string)
  default     = []
}

variable "indexwork_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "indexwork_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

#======================================================
# Application Variables - Lineagework
#======================================================
variable "lineagework_image_tag" {
  description = "The image tag to use for lineagework, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "lineagework_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "lineagework_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "lineagework_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "lineagework_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "lineagework_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "lineagework_extra_security_group_ids" {
  description = "Additional security group ids to lineagework"
  type        = list(string)
  default     = []
}

variable "lineagework_lb_extra_security_group_ids" {
  description = "Additional security group ids to lineagework ALB"
  type        = list(string)
  default     = []
}

variable "lineagework_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "lineagework_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

#======================================================
# Application Variables - Metricwork
#======================================================
variable "metricwork_image_tag" {
  description = "The image tag to use for metricwork, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "metricwork_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "metricwork_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "metricwork_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "metricwork_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "metricwork_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "metricwork_extra_security_group_ids" {
  description = "Additional security group ids to metricwork"
  type        = list(string)
  default     = []
}

variable "metricwork_lb_extra_security_group_ids" {
  description = "Additional security group ids to metricwork ALB"
  type        = list(string)
  default     = []
}

variable "metricwork_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "metricwork_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

#======================================================
# Application Variables - rootcause
#======================================================
variable "rootcause_image_tag" {
  description = "The image tag to use for rootcause, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "rootcause_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "rootcause_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "rootcause_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "rootcause_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "rootcause_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "rootcause_extra_security_group_ids" {
  description = "Additional security group ids to rootcause"
  type        = list(string)
  default     = []
}

variable "rootcause_lb_extra_security_group_ids" {
  description = "Additional security group ids to rootcause ALB"
  type        = list(string)
  default     = []
}

variable "rootcause_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "rootcause_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}


#======================================================
# Application Variables - internalapi
#======================================================
variable "internalapi_image_tag" {
  description = "The image tag to use for internalapi, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "internalapi_desired_count" {
  description = "Initial capacity before autoscaling adjustments"
  type        = number
  default     = 2
}

variable "internalapi_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "internalapi_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 4096
}

variable "internalapi_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "internalapi_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "internalapi_extra_security_group_ids" {
  description = "Additional security group ids to internalapi"
  type        = list(string)
  default     = []
}

variable "internalapi_lb_extra_security_group_ids" {
  description = "Additional security group ids to internalapi ALB"
  type        = list(string)
  default     = []
}

variable "internalapi_jvm_max_ram_pct" {
  description = ""
  type        = number
  default     = 80
}

variable "internalapi_enable_ecs_exec" {
  description = "Whether to enable ECS exec"
  type        = bool
  default     = false
}

variable "internalapi_autoscaling_config" {
  type = object({
    min_capacity       = number
    max_capacity       = number
    type               = string
    target_utilization = number
  })
  default = {
    min_capacity = 2
    max_capacity = 15
    # If CPU scaling is leading to OOM or other overloading due to bursts, switch to request_count_per_target or increase the min capacity.
    type               = "cpu_utilization"
    target_utilization = 65
  }
  validation {
    condition     = contains(["none", "cpu_utilization", "request_count_per_target"], var.internalapi_autoscaling_config.type)
    error_message = "Must be one of: none, cpu_utilization, request_count_per_target"
  }
}
#======================================================
# Application Variables - Scheduler
#======================================================
variable "scheduler_image_tag" {
  description = "The image tag to use for scheduler, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

variable "scheduler_desired_count" {
  description = "The desired number of replicas"
  type        = number
  default     = 1
}

variable "scheduler_cpu" {
  description = "Amount of CPU to allocate"
  type        = number
  default     = 1024
}

variable "scheduler_memory" {
  description = "Amount of Memory in MB to allocate"
  type        = number
  default     = 2048
}

variable "scheduler_port" {
  description = "The port to listen on"
  type        = number
  default     = 80
}

variable "scheduler_threads" {
  description = "The number of threads for scheduler"
  type        = number
  default     = 10
}

variable "scheduler_additional_environment_vars" {
  description = "Additional enviromnent variables to give the application"
  type        = map(string)
  default     = {}
}

variable "scheduler_additional_secret_arns" {
  description = "Additional secret arns to give the application"
  type        = map(string)
  default     = {}
}

variable "scheduler_extra_security_group_ids" {
  description = "Additional security group ids to scheduler"
  type        = list(string)
  default     = []
}

variable "scheduler_lb_extra_security_group_ids" {
  description = "Additional security group ids to scheduler ALB"
  type        = list(string)
  default     = []
}

#======================================================
# Application Variables - Bigeye Admin
#======================================================
variable "bigeye_admin_image_tag" {
  description = "The image tag to use for the bigeye-admin app, defaults to the global `image_tag` if not specified"
  type        = string
  default     = ""
}

#======================================================
# Application Variables - lineageplus_solr
#======================================================
variable "lineageplus_enabled" {
  description = "Whether or not leneageplus components should be deployed."
  type        = bool
  default     = false
}

variable "lineageplus_solr_instance_type" {
  description = "EC2 instance type to use as capacity provider for solr."
  type        = string
  default     = "t3.medium"
}

variable "lineageplus_solr_image_repository_suffix" {
  description = "The repository suffix. For example if the repository is solr/test, the suffix is /test"
  type        = string
  default     = ""
}

variable "lineageplus_solr_image_tag" {
  description = "The image tag to use for lineageplus solr service."
  type        = string
  default     = ""
}

variable "lineageplus_solr_opts" {
  description = "Additional options to pass to solr startup script."
  type        = list(string)
  default     = []
}

variable "lineageplus_solr_desired_count" {
  description = "This variable takes only 0 or 1 and is intended to allow stopping solr service for data volume maintenance."
  type        = number
  default     = 1
  validation {
    condition     = contains([0, 1], var.lineageplus_solr_desired_count)
    error_message = "The value must be either 0 or 1."
  }
}

variable "lineageplus_solr_heap_size" {
  description = "Amount of memory to allocate for solr heap. Will be set for -Xms and -Xmx java options. Default is 80% of instance memory."
  type        = string
  default     = ""
}

variable "lineageplus_solr_ebs_volume_size" {
  description = "Size of EBS volume attached to EC2 container instance running solr, in GB"
  type        = number
  default     = 100
}

variable "lineageplus_solr_ebs_volume_iops" {
  description = "Set iops to the value supported by your instance type. https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html"
  type        = number
  default     = 3000
}

variable "lineageplus_solr_ebs_volume_throughput" {
  description = "Set throughput to the value supported by your instance type. https://docs.aws.amazon.com/ec2/latest/instancetypes/gp.html"
  type        = number
  default     = 125
}

variable "lineageplus_solr_cnames" {
  description = "CNAME Route53 records that will point to the main service DNS name."
  type        = list(string)
  default     = []
}

variable "lineageplus_solr_jmx_port" {
  description = "port to use as the jmx port for solr"
  type        = number
  default     = 1099
}

variable "lineageplus_solr_refresh_instance_on_launch_template_change" {
  description = <<EOD
    Whether or not the instance should be recreated immediately on every template change.
    If false, existing instance will continue running but new instances will use the new template.
    Note: changes happen when AWS releases new AMI, so we don't have control over that.
  EOD
  type        = bool
  default     = false
}
#======================================================
# Cloudfront Variables
#======================================================
variable "cloudfront_enabled" {
  description = <<EOT
This controls whether a Cloudfront distribution is created.  This should be set to true before
setting var.cloudfront_route_static_asset_traffic to true to avoid a brief downtime due to a race
between DNS update and Cloudfront distribution creation.   var.cloudfront_route_static_asset_traffic
should be set to false before setting this variable to false for the same reason.
A var.cloudfront_logging_bucket and var.cloudfront_acm_certificate_arn also need to be set in
addition to setting this var to true to enable Cloudfront in front of the Bigeye app stack.
EOT
  type        = bool
  default     = false
}

variable "cloudfront_route_static_asset_traffic" {
  description = <<EOT
This flag controls the DNS entry Bigeye uses for static assets.  Set to true to point DNS at Cloudfront
for static assets.  See also var.cloudfront_enabled
EOT
  type        = bool
  default     = false
}

variable "cloudfront_logging_bucket" {
  description = "A logging S3 bucket is required for Cloudfront distributions"
  type        = string
  default     = ""
}

variable "cloudfront_acm_certificate_arn" {
  description = "An ACM cert is required for Cloudfront distributions"
  type        = string
  default     = ""
}

variable "cloudfront_compression_enabled" {
  description = ""
  type        = bool
  default     = true
}

variable "cloudfront_origin_read_timeout" {
  description = "How long Cloudfront waits for a response from the origin (or time Cloudfront will wait for the next packet)"
  type        = number
  default     = 60
}
