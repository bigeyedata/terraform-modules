# Terraform Modules

This repository holds terraform modules used to install
the Bigeye stack into an AWS Environment.

## Prerequisites

### Terraform

[Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)

- at least version 1.0. We find that
  `tfenv` ([link](https://github.com/tfutils/tfenv)) is a useful way to install
  & manage Terraform versions

### AWS

You need the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
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
group rules to dedicated rules.  The inline rules do not track AWS rule Ids
properly which blocks seamless changes.  More can be read on this in the
[Terraform docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)

> IMPORTANT - Apply this plan 1x only.  Then apply 19.0.0

The migration path from inline rules involves setting the inline rules to
empty lists. But this will fight with the dedicated ingress/egress rules so
only apply 18.0.0 once, then upgrade to 19.0.0 and the plan will be
idempotent again.

### Upgrading to 17.0.0

The minimum version of the `hashicorp/aws` module has been increased to
5.68.0.  If your install has the version pinned to something lower,
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

All variables with papi in the name need to be globally replaced with internalapi.

### Upgrading to 1.0.0

> IMPORTANT - There are a few breaking changes in this release.

Please refer to the [changelog](./CHANGELOG.md#100-2023-12-22)
for more instructions.
