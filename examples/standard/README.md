# Standard Installation

This bigeye module includes everything you need to install
a Bigeye stack into your AWS account.

The module includes:

* VPC
* Security Groups
* IAM Roles
* ELBs
* ECS cluster, services, and tasks
* Secrets
* S3 buckets
* RabbitMQ Broker
* Elasticache

## Prerequisites

For the standard install, you will need the following:

* [Terraform prerequisites](https://github.com/bigeyedata/terraform-modules/blob/main/README.md#prerequisites)
* Access to an ECR registry with container images (get from Bigeye)
* An image tag (get from Bigeye)
* An AWS account with a Route53 Hosted Zone where Terraform will write DNS records

## Steps

To install the stack, run the following:

### Get Bigeye Container Images

The Bigeye stack will launch a number of containers into ECS.
Speak with someone in sales at Bigeye to request your account
be given access to these container images.

### Set up the directory that will hold your terraform.

```sh
mkdir bigeye-stack
cd bigeye-stack
```

### Download the sample terraform file

Create a `main.tf` file with the contents of the sample in this folder.

You can copy the contents directly from the repository here - [main.tf](./main.tf)

Or you can download the file manually using curl/wget.

```sh
curl -L -o main.tf https://raw.githubusercontent.com/bigeyedata/terraform-modules/main/examples/standard/main.tf

# Or using wget
wget https://raw.githubusercontent.com/bigeyedata/terraform-modules/main/examples/standard/main.tf
```

### Configure your stack

Replace the following variables in `main.tf`.

* `top_level_dns_name` - replace this with your Route53 hosted zone that we'll create DNS records in.
* `image_tag` - get the container image tag to use from Bigeye

### Configure AWS (optional)

The AWS provider will use your default AWS CLI profile if it's present.
If not, you may need to configure the AWS provider with something like:

```hcl
provider "aws" {
    profile = "testaccount - REPLACE WITH YOUR INFO"
    region = "us-east-2 - REPLACE WITH YOUR INFO"
}
```

You can see the various configuration values for the AWS provider [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

### Run Terraform

```sh
terraform init
terraform plan
terraform apply
```

