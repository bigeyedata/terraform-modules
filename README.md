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
