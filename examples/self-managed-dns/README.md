# Self-Managed DNS Installation

Some installation environments may need to manage their own
DNS record creation. By default, the standard install will
configure DNS records in Route53. However, if your DNS resides
in a different provider, account, or otherwise, you will need
to control your own DNS records.

The stack will not be fully functional until the DNS records
are implemented and the services can communicate with one
another and with their databases.

See the "Standard" example for general details on standing up
a Bigeye stack.

## Prerequisites

You will need the ability to configure DNS records for the application.

You will need the ability to manually create an AWS Certificate
Manager wildcard certificate.

### ACM Certificate

Provision an AWS ACM certificate for the wildcard domain under
your top level domain. Your top level domain is what goes in the
`top_level_dns_name`. For example, if your top level domain is
`example.com`, then you will need to provision a certificate
that is valid for `*.example.com`.

Please refer to the AWS documentation
for [provisioning](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)
and [validating](https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html)
your certificate.

You may proceed when your certificate in ACM shows "Issued" as its status.
Copy the ARN for your certificate.

## Configuration

### Configuring the Bigeye Module

You will configure your main terraform file similar to the "Standard" example,
with just a few additions. Set the `create_dns_records` variable to `false`,
and set the `acm_certificate_arn` equal to the ARN copied in the prerequisites.

For example:

```hcl
module "bigeye" {
  # ...
  top_level_dns_name  = "example.com"
  vanity_alias        = "bigeye"
  create_dns_records  = false
  acm_certificate_arn = "arn:aws:acm:YOUR_REGION:YOUR_ACCOUNT:certificate/YOUR_CERT_ID"
}
```

A more complete example can be found in the [main.tf](./main.tf)
file in this example's directory.

### Creating DNS Records

The application requires DNS records to be created before it
is functional. You may configure these DNS records manually,
or using terraform.

You will use the outputs from the `bigeye` module to get the values
necessary for these records. How you configure your DNS is up to you,
but there is an example of how this is done in Route53 in
the [dns.tf](./dns.tf) file.

In [main.tf](./main.tf), all the outputs from
the `bigeye` module exported as outputs for you to use. These will
be available after you run `terraform apply`.

The table below lists the necessary DNS names and their values that must
be specified using a CNAME record type.

If within AWS, you may choose to use an Alias type A record for the
load balancers. The necessary Route53 Zone IDs are also included
in the module output.


| Output Name Containing DNS Name | Output Name Containing Record Value |
| ------------------------------- | ----------------------------------- |
| vanity_dns_name | haproxy_load_balancer_dns_name |
| datawatch_dns_name | datawatch_load_balancer_dns_name |
| datawork_dns_name | datawork_load_balancer_dns_name |
| metricwork_dns_name | metricwork_load_balancer_dns_name |
| monocle_dns_name | monocle_load_balancer_dns_name  |
| web_dns_name | web_load_balancer_dns_name  |
| toretto_dns_name | toretto_load_balancer_dns_name  |
| scheduler_dns_name | scheduler_load_balancer_dns_name  |
| temporalui_dns_name | temporalui_load_balancer_dns_name  |
| temporal_dns_name | temporal_load_balancer_dns_name  |

### Optionsal Steps

When `create_dns_records` is set to false, the applications will
use the RDS-provided domain names for the databases.

If desired, you may also create DNS records to have more
readable domain names for the databases. The bigeye module outputs
these values for you to create those records.

| Output Name Containing DNS Name | Output Name Containing Record Value |
| ------------------------------- | ----------------------------------- |
| datawatch_database_vanity_dns_name | datawatch_database_dns_name |
| datawatch_database_replica_vanity_dns_name | datawatch_database_replica_dns_name |
| temporal_database_vanity_dns_name | temporal_database_dns_name |
