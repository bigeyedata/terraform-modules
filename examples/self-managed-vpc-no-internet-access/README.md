# Self-managed VPC with no internet access installation

Some installation environments may require installing Bigeye in a VPC that has no NAT or route for
any services or resources to public net. The method for doing this is to create your own (or bring
an existing) VPC that does not have internet access and pass it into the Bigeye module.

The only file necessary to install Bigeye with existing infrastructure (DNS domain, vpc, security groups,
mail server, etc) is [main.tf](./main.tf).  All of the other `*_example.tf` files are here as
a reference as they will create example infrastructure (DNS domain, vpc, security groups,
mail server, etc) for an end to end test.

This example shows the necessary configuration of variables for the Bigeye module to accomplish
this as well as a sample VPC configuration with the necessary VPC Endpoints (S3, logs, ECR) and
security groups that can be used as a reference.  The VPC endpoints are required for the services
to function properly without access to AWS' public service endpoints and is just overall a recommended
practice, even if your installation will have access to/from public net.

Creating your own security groups allows you to restrict inbound traffic to just your VPC cidr
which is a 2nd level of security beyond simple removing subnet routes to public net.

See the "[Standard](../standard/README.md)" example for more details on general Bigeye stack configuration.

This bigeye module includes everything you need to install a Bigeye stack into your AWS account.

The module includes:

* VPC
* Security Groups
* IAM Roles
* ALBs & ACM SSL cert
* ECS cluster, services, and tasks
* Secrets
* S3 buckets
* RabbitMQ Broker
* Elasticache


## Prerequisites

* Install [Terraform](https://github.com/bigeyedata/terraform-modules/blob/main/README.md#prerequisites)
* Install git
* Access to an ECR registry with container images (get from Bigeye)
* An image tag (get from Bigeye)
* An AWS account with a Route53 Hosted Zone where Terraform will write DNS records
* AWS credentials (access keys)
* ssh keys generated (~/.ssh/id_rsa.pub exists)

### Terraform install
[Official Terraform install instructions](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

**OSX:** 
```shell
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**RHEL Linux:**
```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

**Ubuntu/Debian Linux:**
```shell
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
```

### Git install
**OSX:**
```shell
brew install git
```
**RHEL Linux:**
```bash
yum install git
```
**Ubuntu/Debian Linux:**
```shell
 apt-get install git
```

### AWS credentials
You will need a set of AWS Credentials, Terraform uses this to create and install reasources in your AWS environment.

It is recommended for production setups to skip this step and configure the `provider "aws"` block without hard coded credentials,
but for this example, generate new access keys and save the access key id and secret key for later.  You will be putting them into 
the `aws_access_key` and `aws_secret_key` variables in [main.tf](./main.tf).  More info can be found in the [official docs for the aws Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

```
AWS Web UI -> IAM - Users -> Your user -> security credentials tab -> create access key button
```

### Generate SSH keys
If you do not have an SSH keypair already (~/.ssh/id_rsa.pub), generate one
```shell
ssh-keygen -t rsa -b 4096
```
This will be used in a future step for accessing the Bastion host.

## Short Terraform primer
Terraform will by default install all of the *.tf files in the current directory using the AWS credentials that you provide.  

A few useful commands that will be used in this example:
* `terraform init` - this downloads and any necessary terraform modules to your local (aws provider etc)
* `terraform plan` - think of this as a dry run mode.  This reads all of the *.tf files and compares them to AWS to see what needs to be added, removed or updated and prints out a list of proposed changes.
* `terraform apply` - Prints the same things as terraform plan, but prompts for yes/no to actually execute the changes.
* `terraform destroy` - Deletes all resources defined in *.tf.

## Bigeye stack install steps

### Ask for access to Bigeye Container Images

The Bigeye stack will launch a number of containers into ECS.  Contact Bigeye support with your 
AWS Account ID to request your account be given access to these container images.

### Set up the directory that will hold your terraform.

```shell
mkdir bigeye-stack
cd bigeye-stack
```

### Download the Bigeye Terraform examples
Git Clone the Bigeye Terraform modules repo and copy the self-managed-vpc-no-internet-access example.  The rest of the
files can be discarded.
```shell
git clone https://github.com/bigeyedata/terraform-modules.git
cp -r terraform-modules/examples/self-managed-vpc-no-internet-access/* .
rm -rf terraform-modules
```

### Configure your stack
Examine and configure every variable in the locals{} block in [main.tf](./main.tf).  Pay particular attention
to the following settings:
* aws_region
* aws_access_key
* aws_secret_key
* bastion_ingress_cidr
* cidr_first_two_octets
* environment
* instance
* parent_domain
* subdomain_prefix

The locals block is the only section that needs to be edited for this example.

### Create route53 subdmain

Create the route53 subdomain.  The `-target=aws_route53_zone.subdomain` tells terraform to install a specific resource instead of
all of the resources found in the *.tf files in the directory.  **aws_route53_zone.subdomain** is defined in [subdomain_example.tf](./subdomain_example.tf)
if you wish to inspect how it is defined.

```shell
# initialize Terraform
terraform init
# create subdomain
terraform apply -target=aws_route53_zone.subdomain
# create NS records for subdomain in parent domain (for SES email domain verification)
terraform apply -target=aws_route53_record.subdomain_ns_record
````

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

Workmail organization (e.g. bigeye-example-com) -> Users (left nav) -> Add user button.

Put whatever you like into the configuration boxes, the only important one is the Email address.
That must match the `${from_email}` in [main.tf](./main.tf), be sure to set the @domain dropdown box to your subdomain. 

Take note of the `username` and `password` fields you have filled in.  Those will be used to log into Workmail to read a verification email from SES later.

### Create a VPC

`module.vpc` is defined in [vpc_example.tf](./vpc_example.tf).
```shell
terraform apply -target=module.vpc
```

### Create the rest of the stack
```shell
terraform plan
terraform apply
```
This can take upwards of 20-30 minutes as a few of the AWS resources have long instance creation times (RDS, rabbitMQ, redis).

### SES account verification
When the stack has been created, the SES identity for `${from_email}` will have been created and SES will have
sent a verification email to the account.  Log into Workmail https://<workmail_organization>.awsapps.com/mail and
use the `username` and `password` from before to log in.  Open up the email from "Awamzon Web Services"
and click on the verify email link so the email address will be verified and SES will allow email to be sent from this address.

### Accessing the Bigeye UI
Since this demonstration example Terraform plan does not include a VPN and the stack is set up without
an internet gateway, a bastion will be used for an SSH tunnel to route UI/API requests to Bigeye.  This is 
here for demonstration purposes, but a VPN is recommended instead for production installs.

```text
NOTE: Accessing Bigeye is web browser based.  The remaining steps should be run wherever you will be using a web browser to access
Bigeye from (e.g. local laptop).  It does not have to be the same place you are running terraform from.  You will need to copy the SSH private
key (~/.ssh/id_rsa) from the host that Terrafom was run from and put it on the machine where you will be running the web browser.  Be sure
the file has the correct permissions when done (chmod 600).
```

Note the output of the Terraform apply when the stack was created.  The last few lines of output will be a few useful values:
* bastion
* bastion_ssh_user
* bigeye_address

Use an SSH tunnel to route requests to the Bigeye application

```shell
ssh -L 8443:${bigeye_address}:443 -Nf  ubuntu@${bastion}
```

Update your local /etc/hosts file so that the Bigeye url `${bigeye_address}` will go over the localhost SSH tunnel port.

```shell
sudo -- sh -c "echo 127.0.0.1 ${bigeye_address}  >> /etc/hosts"
```
Point your browser to ${bigeye_address}:8443/first-time to create an account.

Note that the SSH tunnel method is not perfect.  Occasionally there will be a redirect that does
not come back with the port number in the URL (ie notification emails).  When that happens just add the :8443 port into the URL at the end of `${bigeye_address}`.
