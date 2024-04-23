# Terraform Modules

This repository holds terraform modules used to install
the Bigeye stack into an AWS Environment.

## Prerequisites

### Terraform

[Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)

- at least version 1.0.  We find that
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

## Compatibility

As features are released, newer versions of this terraform infrastructure are required.
To prevent issues resulting from misalignment between the `image_tag` of the application
and the module version, please consult this chart:

| Application Version | Terraform Module Version |
| ------------------- | ------------------------ |
| 1.48.0 | requires 3.12.0+ |

## Upgrading

### Upgrading to 1.0.0

>IMPORTANT - There are a few breaking changes in this release.

Please refer to the [changelog](./CHANGELOG.md#100-2023-12-22)
for more instructions.
