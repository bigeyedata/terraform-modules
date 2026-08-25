# Terraform Modules

This repository holds terraform modules used to install
the Bigeye stack into an AWS Environment.

## Prerequisites

### Terraform

[Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)

- at least version 1.0. We find that
  ([tfenv](https://github.com/tfutils/tfenv)) is a useful way to install
  & manage Terraform versions

### AWS

You need
the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
installed and configured with credentials for your AWS account.

## Getting Started

Check out the [standard example](./examples/standard/) to get started with
a Bigeye stack. Other common configurations are also in the examples directory.

For a full list of the configuration options, please review the
[variables.tf](./modules/bigeye/variables.tf) in the main bigeye module.

## Compatibility Matrix

Some infrastructure changes require application changes to be in place,
and some application changes require infrastructure changes. This section
of the README notes these changes.

This compatibility matrix is not exhaustive. It is added on a
best-effort basis. The terraform-modules version refers to the version
of the terraform module in this repository. The Application Version refers
to the value of the `image_tag`, specifying the application image.
It is always recommended to be on the latest
terraform version and application version.

| terraform-modules Version | Application Version | Comment                                                                                  |
|---------------------------|---------------------|------------------------------------------------------------------------------------------|
| >= 12.0.0                 | 1.73.0              | dedicated indexwork service for catalog indexing operations                              |
| >= 11.4.0                 | 1.71.0              | migrate queue membership to "include" list that became available in app version `1.71.0` |
| >= 9.2.0                  | 1.65.0              | mTLS support in datawatch services removed, requires TF settings introduced in `9.2.0`   |
| 9.2.0                     | >= 1.57.0           | TF adds temporal settings that were released in app version 1.57.0                       |
| >= 3.12.0                 | 1.48.0              | Application 1.48.0 requires at least terraform-modules version 3.12.0                    |

## Upgrading

### Upgrading to 27.0.0

The `scheduler` service has been decommissioned and removed. Its scheduled jobs
have been migrated to Temporal schedules run by the other services, so no
separate service, load balancer, or target group is needed. No action is
required — the remaining services pick up the work automatically once applied.

The following `bigeye` module variables have been removed (they were only used
by the retired service):

- `var.scheduler_image_tag`
- `var.scheduler_desired_count`
- `var.scheduler_cpu`
- `var.scheduler_memory`
- `var.scheduler_port`
- `var.scheduler_threads`
- `var.scheduler_additional_environment_vars`
- `var.scheduler_additional_secret_arns`
- `var.scheduler_extra_security_group_ids`
- `var.scheduler_lb_extra_security_group_ids`

The following `bigeye` module outputs have been removed:

- `output.scheduler_dns_name`
- `output.scheduler_load_balancer_dns_name`
- `output.scheduler_load_balancer_zone_id`

The following `alarms` module variables have been removed:

- `var.elb_scheduler_host_count_*`
- `var.elb_scheduler_response_time_*`
- `var.elb_scheduler_error_rate_*`
- `var.ecs_scheduler_mem_*`

Note: because the `scheduler` security group was removed from the ordered list
feeding the Redis `allowed_client_security_group_ids`, the trailing ingress
rules on that resource will be recreated on the next apply.

### Upgrading to 26.0.0

The dedicated `rootcause` service has been removed. Its Temporal task queue
(`issue-root-cause`) is now handled by the `datawork` service, so no separate
service, load balancer, or target group is needed. No action is required to
move the queue — `datawork` picks it up automatically once applied.

The following `bigeye` module variables have been removed (they were only used
by the retired service):

- `var.rootcause_image_tag`
- `var.rootcause_desired_count`
- `var.rootcause_cpu`
- `var.rootcause_memory`
- `var.rootcause_port`
- `var.rootcause_additional_environment_vars`
- `var.rootcause_extra_security_group_ids`
- `var.rootcause_lb_extra_security_group_ids`
- `var.rootcause_jvm_max_ram_pct`
- `var.rootcause_enable_ecs_exec`

The `var.temporal_client_issue_root_cause_wf_exec_size` and
`var.temporal_client_issue_root_cause_act_exec_size` variables are retained;
they now tune the `issue-root-cause` workers running inside `datawork`.

The following `bigeye` module outputs have been removed:

- `output.rootcause_dns_name`
- `output.rootcause_load_balancer_dns_name`
- `output.rootcause_load_balancer_zone_id`

The following `alarms` module variables have been removed:

- `var.elb_rootcause_host_count_*`
- `var.ecs_rootcause_mem_*`

Note: because the `rootcause` security group was removed from the ordered lists
feeding the Redis and RDS `allowed_client_security_group_ids`, the `lineageapi`
ingress rule on those resources will be recreated on the next apply.

### Upgrading to 25.3.0

Terraform apply will fail the first time you run it after upgrading to 25.3.0
due to security group rules being regenerated (duplicate rules conflict).  
It will succeed on the second terraform apply.

This corrects a bug introduced in 24.0.0 that affected new installs.

### Upgrading to 25.0.0

The following var has been removed:

- `var.datawatch_base_encryption_secret_arn`

### Upgrading to 24.0.0

The following vars have been renamed.

- `var.additional_ingress_cidrs` to `var.external_ingress_cidrs`
- `var.internal_extra_security_group_ids` to
  `var.internal_additional_security_group_ids`
- `var.temporal_lb_extra_security_group_ids` to
  `var.external_additional_security_group_ids`

Also note that if you have set `var.additional_ingress_cidrs`,
0.0.0.0/0 will now be removed from external load balancer ingress.

`var.external_additional_security_group_ids` controls access to
both the external ALB and NLB.

### Upgrading to 23.0.0

The following vars have been removed from the bigeye module:

- var.install_individual_external_lbs
- var.use_centralized_external_lb_solr
- var.use_centralized_internal_lb
- var.install_individual_internal_lbs
- var.haproxy_lineageapi_enabled
- var.disable_unused_monocle_dd_flags
- var.load_balancing_anomaly_mitigation

The following vars have been removed from the alarms module:

- var.monitor_individual_external_lbs
- var.monitor_individual_internal_lbs

### Upgrading to 22.0.0

The following var has been removed:

- var.availability_zone_rebalancing flag.

### Upgrading to 21.0.0

The AWS provider needs to be upgrade to support ALB anomaly mitigation.
Upgrade your hashicorp/aws provider to 5.100.0 or newer.

(Optional) The following are useful commands to avoid a service interruption
from ECS replacing services when autoscaling is enabled. It will also make
the terraform apply run much faster.

Run these before running terraform apply with `21.0.0`

```bash
terraform state mv \
  'module.bigeye.module.datawatch.aws_ecs_service.controlled_count[0]' \
  'module.bigeye.module.datawatch.aws_ecs_service.uncontrolled_count[0]'
terraform state mv \
  'module.bigeye.module.haproxy.aws_ecs_service.controlled_count[0]' \
  'module.bigeye.module.haproxy.aws_ecs_service.uncontrolled_count[0]'
terraform state mv \
  'module.bigeye.module.web.aws_ecs_service.controlled_count[0]' \
  'module.bigeye.module.web.aws_ecs_service.uncontrolled_count[0]'   
```

### Upgrading to 20.0.0

The following vars have been renamed from "ponts" to points" to fix typos.
If you've set any of the following, rename them from these:

- var.ecs_backfillwork_mem_dataponts_to_alarm
- var.ecs_datawatch_mem_dataponts_to_alarm
- var.ecs_datawork_mem_dataponts_to_alarm
- var.ecs_indexwork_mem_dataponts_to_alarm
- var.ecs_lineagework_mem_dataponts_to_alarm
- var.ecs_metricwork_mem_dataponts_to_alarm
- var.ecs_rootcause_mem_dataponts_to_alarm
- var.ecs_monocle_mem_dataponts_to_alarm
- var.ecs_internalapi_mem_dataponts_to_alarm
- var.ecs_scheduler_mem_dataponts_to_alarm
- var.ecs_toretto_mem_dataponts_to_alarm
- var.ecs_web_mem_dataponts_to_alarm

To these:

- var.ecs_backfillwork_mem_datapoints_to_alarm
- var.ecs_datawatch_mem_datapoints_to_alarm
- var.ecs_datawork_mem_datapoints_to_alarm
- var.ecs_indexwork_mem_datapoints_to_alarm
- var.ecs_lineagework_mem_datapoints_to_alarm
- var.ecs_metricwork_mem_datapoints_to_alarm
- var.ecs_rootcause_mem_datapoints_to_alarm
- var.ecs_monocle_mem_datapoints_to_alarm
- var.ecs_internalapi_mem_datapoints_to_alarm
- var.ecs_scheduler_mem_datapoints_to_alarm
- var.ecs_toretto_mem_datapoints_to_alarm
- var.ecs_web_mem_datapoints_to_alarm

### Upgrading to 19.0.0

Be sure to apply 18.0.0 first, or the previously inline security group
rules that were removed will be left dangling and will cause conflicts
down the road.

### Upgrading to 18.0.0

18.0.0 is the first step in a 2 part series to migrate from inline security
group rules to dedicated rules. The inline rules do not track AWS rule Ids
properly which blocks seamless changes. More can be read on this in the
[Terraform docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)

> IMPORTANT - Apply this plan 1x only. Then apply 19.0.0

The migration path from inline rules involves setting the inline rules to
empty lists. But this will fight with the dedicated ingress/egress rules so
only apply 18.0.0 once, then upgrade to 19.0.0 and the plan will be
idempotent again.

### Upgrading to 17.0.0

The minimum version of the `hashicorp/aws` module has been increased to
5.68.0. If your install has the version pinned to something lower,
increase the version to at least 5.68.0 and run `terraform init -upgrade`.

### Upgrading to 16.0.0

The following var has been removed:

- backfillwork_autoscaling_max_count

### Upgrading to 15.0.0

The following vars have been removed:

- var.monocle_autoscaling_enabled
- var.monocle_max_count
- var.monocle_autoscaling_request_count_target
- var.indexwork_autoscaling_enabled
- var.internalapi_autoscaling_cpu_enabled
- var.internalapi_autoscaling_cpu_target

Instead, use:

- var.internalapi_autoscaling_config
- var.monocle_autoscaling_config

### Upgrading to 14.0.0

The following variable will need to be removed from your config if you
are using it.

- indexwork_autoscaling_max_count

It has been replaced with `var.indexwork_desired_count` to control the
instance count for the indexwork service.

### Upgrading to 13.0.0

The following feature flags will need to be removed from your config if you
are using them:

- migrate_lineage_mq_queue_enabled
- migrate_catalog_indexing_mq_queue_enabled

### Upgrading to 12.0.0

The following feature flags will need to be removed from your config if you
are using them:

- indexwork_enabled
- indexwork_autoscaling_enabled

### Upgrading to 10.0.0

All variables with papi in the name need to be globally replaced with
internalapi.

### Upgrading to 1.0.0

> IMPORTANT - There are a few breaking changes in this release.

Please refer to the [changelog](./CHANGELOG.md#100-2023-12-22)
for more instructions.
