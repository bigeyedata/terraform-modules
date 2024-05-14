# Self-Managed IAM Installation

Some installation environments may need to manage their own
IAM Roles. By default, the standard install will configure IAM
roles.

## Prerequisites

You will need the ability to configure IAM Roles for
the application.

## Configuration

You will configure your main terraform file similar to the "Standard" example,
with just a few additions. You must create one IAM Role for the ECS cluster
execution role, one IAM Role for the datawatch-related services, one IAM
Role for the monocle & toretto services, and optionally one IAM Role for
the admin container, if that is enabled.

The [iam.tf](./iam.tf) file in this directory shows the lowest permissions
required for the ECS service and the applications.

WARNING: It is always best to refer to the resources in the main terraform
modules, rather than this file. The permissions will be kept up to date in this
directory on a best-effort basis, but it is always best to refer to the
resources in the main terraform modules.

Resources in module:

* `aws_iam_role.ecs`
* `aws_iam_role.monocle`
* `aws_iam_role.datawatch`
* `module.bigeye_admin.aws_iam_role.this`

