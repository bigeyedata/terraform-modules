# Standard Installation

This bigeye module includes everything you need to install
a Bigeye stack into your AWS account.

The module includes:

* ECS cluster, services, and tasks
* Cloudwatch
* Elasticache
* ELBs
* IAM Roles (create and manage ECS roles)
* Opensearch
* RDS databases
* RabbitMQ Broker (Amazon MQ)
* Secrets Manager
* Security Groups
* S3 buckets
* VPC

## Prerequisites

Bigeye support will need the following information

* github handle to pull the terraform modules repo
* AWS account ID that you will be running the install from.  This is to
authorize access to Bigeye ECR images
* AWS Region you will be installing Bigeye.  This is to ensure images are
available in the region that you will be pulling from.

For the standard installation, you will also need the following:

* [Terraform prerequisites](https://github.com/bigeyedata/terraform-modules/blob/main/README.md#prerequisites)
* Access to an ECR registry with container images (get from Bigeye)
* An image tag (get from Bigeye)
* An AWS account with a Route53 Hosted Zone where Terraform will write DNS
records
* An AWS IAM user or role that has enough permissions to provision DNS
records, IAM roles, create databases, etc.

## Steps

### Get Bigeye Container Images

The Bigeye stack will launch a number of containers into ECS.
Speak with someone in sales at Bigeye to request your account
be given access to these container images.

### Set up the directory that will hold your terraform

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

* `top_level_dns_name` - replace this with your Route53 hosted zone that we'll
create DNS records in.
* `image_tag` - get the container image tag to use from Bigeye

It is also valuable to set  `vanity_alias` as well.  The combination of
`vanity_alias` and `top_level_dns_name` comprise the URL that Bigeye will be
access from after the install is complete:
"https://vanity_alias.top_level_dns_name"

### Run Terraform

This process will take around 30 minutes as some of the resources such as RDS
and Opensearch take a while to create resources.

```sh
terraform init
terraform plan
terraform apply
```

Once the installation is complete, the bigeye UI can be accessed at
`https://<vanity_alias>.<top_level_dns_name>/first-time`

### Troubleshooting

#### Terraform failure messages

```log
Error: creating ECS Service (x-temporalui): operation error ECS: 
CreateService, https response error StatusCode: 400, RequestID: xxxxx, 
InvalidParameterException: The target group with targetGroupArn <arn> does not 
have an associated load balancer.
```

This is transient and happens on some installs due to the timing with when the
ECS service is being created and when the load balancer is created.  Re-run
terraform apply again.
