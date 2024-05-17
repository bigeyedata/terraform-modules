# Self-managed VPC with no internet, low access installation

Some installation environments may have hightened security requirements
which may include:

* No internet access
* Externally managed DNS records
* Externally managed VPC & security group configuration
* Externally managed IAM permissions
* etc.

The bigeye module has been configured with this sort of flexibility in mind.
This example demonstrates how this can be accomplished.

## Installation Prerequisites

### Domain

In order to install Bigeye, you must already have a domain registered in your
DNS provider. This example assumes you have a Route53 Hosted Zone for a domain
registered to your account.

### ECR Access with Bigeye Images

See the "[Standard](../standard/README.md)" example for more details on general Bigeye stack configuration.

### Software Dependencies

In order to execute commands in this example, you will need some software installed
on the relevant systems.

#### Curl

Most linux systems come with curl installed. You can also use wget if you prefer.

#### Terraform

Please refer to the [official Terraform install instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

If installing in a no-internet environment, ensure you have access a terraform installation tarball.

Terraform installation bundles can be found on their
[releases page](https://releases.hashicorp.com/terraform/) page.

Copy this resource to your account's public dependencies bucket using the following command:

```sh
aws s3 cp <downloaded zip file> zips3://<YOUR_BUCKET>/tooling/terraform/
```

It is more common for linux instances to have `tar` installed instead of `zip`. You can convert
the zip to tar from your computer using:

```sh
mkdir terraform_zip_to_tar
unzip <downloaded zip file> -d terraform_zip_to_tar
tar -czvf terraform_<version>_<os>_<arch>.tar.gz terraform_zip_to_tar
```

And upload the tarball to your bucket:

```sh
aws s3 cp terraform_<version>_<os>_<arch>.tar.gz s3://<YOUR_BUCKET>/tooling/terraform/
```

A sample terraform installation tarball for x86 linux architecture can be found
in `s3://bigeye-bundle-distributions/tooling/terraform/terraform_1.8.3_linux_amd64.tar.gz`.

To install from the tarball, run:

```sh
curl https://s3.us-west-2.amazonaws.com/<YOUR_BUCKET>/tooling/terraform/terraform_1.8.3_linux_amd64.tar.gz --output terraform_1.8.3_linux_amd64.tar.gz
tar -xzvf terraform_1.8.3_linux_amd64.tar.gz
sudo mv terraform/terraform /usr/local/bin/terraform
```

#### AWS Credentials

It is recommended to use an IAM Role rather than IAM User programmatic access keys.
Refer to the 
[AWS Terraform Provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
to configure the `provider "aws"` blocks in this directory.

For this example, the bastion is assigned an IAM Role with the Administrator IAM Policy.

#### SSH Key Pair

You'll need this to connect to the bastion. If you don't already have an SSH key pair
at `~/.ssh/id_rsa.pub`, then you'll need to run:

```sh
ssh-keygen -t rsa -b 4096
```

#### AWS CLI

Depending on how you're obtaining the terraform module and provider
cache, you may need to access your bucket via the AWS CLI.

You may already have AWS CLI installed, but if not, please refer to the
[official AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
to install the CLI.

If you do not have access to their public S3 bucket to download their zip,
you will need to make that available to your instance via your account's public
dependencies bucket. A sample `tar.gz` file has been made available at
`s3://bigeye-bundle-distributions/tooling/awscli/awscli-exe-linux-x86_64.tar.gz`.

You can obtain the appropriate installation package from AWS's bucket, and then rebundle it
into a tar.gz file, as described above for terraform.

To download the AWS CLI from your public bucket and install it on an amd64 linux system,
run the following commands.

```sh
curl https://s3.us-west-2.amazonaws.com/<YOUR_BUCKET>/tooling/awscli/awscli-exe-linux-x86_64.tar.gz --output awscli-exe-linux-x86_64.tar.gz
tar -xzvf awscli-exe-linux-x86_64.tar.gz
sudo ./awscli-exe-linux-x86_64/aws/install
# Confirm installed
aws --version
```

### Sample Dependencies Bucket

Before deploying any application-specific resources, you should have access to any
resources that you would otherwise obtain from the internet. This includes the
terraform executable and relevant `.terraform` folder caches which include the
aws and random providers.

A sample implementation of these resources is shown in the
[dependencies/main.tf](./dependencies/main.tf) file. This includes two S3 buckets.
A public bucket is specified to contain public dependencies such as the AWS CLI
and Terraform binaries. A private bucket is specified to contain Bigeye content,
such as the terraform-modules tarballs. Your specific needs may vary.

From the `dependencies` directory:

1. Configure your AWS provider
2. Update the `bucket_prefix` local variable.
3. Install the S3 buckets for dependencis using the following commands:

```
terraform init
terraform apply
```

### Sample Installer Setup

This example walks through setting up an EC2 instance for running
the terraform. The instance is running Amazon Linux 2023.

SSH into your instance

```sh
ssh -i ~/.ssh/id_rsa ec2-user@<IP>
```

Configure your AWS environment.

```sh
mkdir .aws
vim .aws/credentials
# populate this according to your needs
```

The terraform will take a public SSH key to allow access
to the bastion, which we will use as an edge device to verify
the stack is up and running. Copy this from your computer
(that is, your desktop/laptop where you can run a browser)
out to the EC2 instance so terraform can find it. Again, this
is only to help drive the bastion-as-a-vpn example.

```sh
vim .ssh/id_rsa.pub
# Copy your key here.
```

Download and install terraform from tarball

```sh
curl https://s3.us-west-2.amazonaws.com/<YOUR_BUCKET>/tooling/terraform/terraform_1.8.3_linux_amd64.tar.gz --output terraform_1.8.3_linux_amd64.tar.gz
tar -xzvf terraform_1.8.3_linux_amd64.tar.gz
sudo mv terraform/terraform /usr/local/bin/terraform
```

Download terraform modules tarball and extract it.

```sh
aws s3 cp s3://<YOUR PRIVATE BUCKET>/terraform-modules-<VERSION>.tar.gz .
tar -xzvf terraform-modules-<VERSION>.tar.gz
```

Set up installation folder. This is where we will run terraform
commands.

```sh
mv terraform-modules/examples/self-managed-vpc-no-internet-access ~/bigeye
cd ~/bigeye
```

Open the `main.tf` file and configure your aws provider block. This looks like:

```hcl
provider "aws" {
  # ...
}
```

## Installing Bigeye

This example is split into three steps.

### Step 1 - Bring-your-own Resources Module

This step includes installing the externally-managed resources that will
be injected into the bigeye module. These are resources that would otherwise
be managed by the bigeye module, but must be managed externally for some reason,
whether it be security, compliance, compatibility, process, etc. The following
resources are configured in this step:

* No-Internet VPC
* Route53 Hosted Zone for DNS records
* Bastion for edge access (you may use a VPN, etc.)
* SSL certificate (Amazon Certificate Manager)
* Security groups
* IAM Roles for the services
* An SMTP server (SES)
* RabbitMQ Broker (Amazon MQ)

This step sets up the VPC for the Bigeye application. The application
will be installed in subnets with no internet access. A bastion can
be installed, either in a public or private subnet.

The specific details of this step will vary, depending on your installation environment.
The contents of this module provide a **sample** implementation, which may not work
for your environment.

For example, Amazon SES is used as the SMTP server implementation. You may use a
different SMTP server, and that's fine.

Additionally, the sample VPC configuration is effective for demonstration purposes, but
you may have completely different networking requirements.

Note: The AWS API endpoints for IAM, Amazon Certificate Manager, Route53, and Amazon MQ
are not available as private VPC endpoints. In order to install these from the
internet-disconnected bastion, they are deployed as CloudFormation stacks, managed
by terraform.

From the bastion, in the directory where you have extracted the terraform modules,
edit the `main.tf` file, updating:

* `aws_region`
* `aws_account_id`
* `environment`
* `instance`
* `parent_domain_hosted_zone_id`
* `parent_domain_name`
* `subdomain_prefix`
* `vanity_alias`
* `image_tag`
* `image_registry`
* `from_email`
* `cidr_first_two_octets`
* `bastion_enabled` - if you'd like bastion access
* `bastion_public` - if you need to access the bastion over public net
* `bastion_ingress_cidr` if applicable
* `bastion_ssh_public_key_file` - if applicable

See the "[Standard](../standard/README.md)" example for more details on general Bigeye stack configuration.

Then, from that folder, run:

```sh
terraform apply -target module.bringyourown
```

### Step 2 - Bigeye application

This step continues by installing the Bieye application. Run the following from the bastion
in the installation directory:

```sh
terraform apply -target module.bigeye
```

### Step 3 - DNS

The last module is to configure DNS records for the application. The application will not
successfully start up until this module is applied.

In this example, the DNS records are created using Route53. These simply serve as an example.
Your specific DNS implementation may use a different provider, e.g. Cloudflare.

Apply these resources using the following commands from the bastion in the installation directory:

```
terraform apply
```

Note the `bigeye_address` output. We'll use that in the verification step.

## Verification

Since this demonstration example Terraform plan does not include a VPN and the stack is set up without
an internet gateway, a bastion will be used for an SSH tunnel to route UI/API requests to Bigeye.  This is 
here for demonstration purposes, but a VPN is recommended instead for production installs.

```text
NOTE: Accessing Bigeye is web browser based.  The remaining steps should be run wherever you will be using a web browser to access
Bigeye from (e.g. local laptop).  It does not have to be the same place you are running terraform from.  You will need to copy the SSH private
key (~/.ssh/id_rsa) from the host that Terrafom was run from and put it on the machine where you will be running the web browser.  Be sure
the file has the correct permissions when done (chmod 600).
```

Use an SSH tunnel to route requests to the Bigeye application. Use the `bigeye_address` and
`bastion_ip` values from earlier.
```sh
export bigeye_address=<YOUR_VALUE_HERE>
export bastion_ip=<YOUR_VALUE_HERE>
```

```shell
ssh -L 8443:${bigeye_address}:443 -Nf ec2-user@${bastion_ip}
```

Update your local /etc/hosts file so that the Bigeye url `${bigeye_address}` will go over the localhost SSH tunnel port.

```shell
sudo -- sh -c "echo 127.0.0.1 ${bigeye_address}  >> /etc/hosts"
```

Point your browser to ${bigeye_address}:8443/first-time to create an account.

Note that the SSH tunnel method is not perfect.  Occasionally there will be a redirect that does
not come back with the port number in the URL (ie notification emails).  When that happens just add the :8443 port into the URL at the end of `${bigeye_address}`.


### Create Email account in AWS Workmail

Now that the route53 subdomain has been created, create an AWS Workmail account.  An email client is necessary in order to accept a 
verification email for AWS SES and Workmail is a native AWS offering so is used here for demonstration purposes.  

There is no Terraform provider for Workmail, so this will be done manually using the AWS Web UI.

[AWS Web UI](https://console.aws.amazon.com) -> Workmail -> Create Organization button

1. `Existing Route 53 domain`: check radio button
2. `Route 53 hosted zone`: Select the same domain specified in [main.tf](./main.tf) as the subdomain variable
3. `Alias`: Pick something unique.  bigeye-example-com for example

Now that the Workmail org has been created, we're going to create an email that matches the `${from_email} configured in [main.tf](./main.tf).

Wait for the Workmail org that you created to finish creating and become `Active` (the browser refreshes status automatically). 
Click on 

`Workmail organization (e.g. bigeye-example-com) -> Users (left nav) -> Add user button.`

Put whatever you like into the configuration boxes, the only important one is the Email address.
That must match the `${from_email}` in [main.tf](./main.tf), be sure to set the @domain dropdown box to your subdomain.
If the drop down is empty or your subdomain isn't in the list, just wait a minute or two and refresh the page.  DNS verification
is happening in the background and this can take a few minutes.

Take note of the `username` and `password` fields you have filled in.  Those will be used to log into Workmail to read a verification email from SES later.

### SES account verification

When the stack has been created, the SES identity for `${from_email}` will have been created and SES will have
sent a verification email to the account.  Log into Workmail https://<workmail_organization>.awsapps.com/mail and
use the `username` and `password` from before to log in.  Open up the email from "Awamzon Web Services"
and click on the verify email link so the email address will be verified and SES will allow email to be sent from this address.

