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

* A Route53 Hosted Zone
* The AWS ECR registry URL (get from Bigeye)
* An image tag (get from Bigeye)

## Steps

To install the stack, run the following:

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
curl https://github.com/bigeyedata/terraform-modules/tree/main/docs/examples/standard/main.tf

# Or using wget
wget https://github.com/bigeyedata/terraform-modules/tree/main/docs/examples/standard/main.tf
```

### Configure your stack

Replace the following variables in `main.tf`. You will need to get the docker images from Bigeye

* `top_level_dns_name`
* `image_registry`
* `image_tag`

### Run Terraform

```sh
terraform init
terraform plan
terraform apply
```

