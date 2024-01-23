# Self-Managed mTLS certs Installation

Bigeye images ship with a set of default mTLS certs for communication
between the Temporal service and the other services.  These certs are
included for ease of installation, but are not meant for use in production.

For production installations, it is recommended to generate your own
SSL certs, whether they be self signed or otherwise, so that they are
unique for your environment.

The method for Bigeye to use your self-managed SSL certs is to store them
in AWS Secrets manager (ASM) as base64 encoded strings.  Details on how to
do this are in the steps below.

## Prerequisites

* AWS CLI setup (aws sts get-caller-identity should run without error)
* AWS user has access to create / modify secret in ASM
* openssl, tar, gzip, base64 work from local bash shell

## Steps

1. Install Bigeye using the default mTLS certs (ie follow the minimal or standard example).  It is best to get this up and running with the default certs first to reduce the number of moving parts to check when the self-managed mTLS certs are introduced. 
2. Generate a set of self-signed certs (omit this step if you are bringing your own generated certs)

Take note of the following Terraform outputs from Step 1.
* `stack_name` - ASM secrets tagged with stack:<stack_name> will be readable by the Bigeye ECS cluster
* `temporal_dns_name` - This is used for SSL hostname verification, self signed certs will be created for this hostname.

Run the following script, it will generate a set of self-signed certs and upload it to ASM at /bigeye/byo-mtls-example/*
```
./generate_self_signed_mtls_certs.sh  -a <temporal_dns_name> -s <stack_name> -u /bigeye/byo-mtls-example
```
Take note of the ARNs for the ASM secrets that were created as those will be used in a later step.

Skip to Step 5.

3. Store mTLS certs as base64 encoded strings in ASM.

For bringing your own certs, the files need to be stored in ASM as base64 encoded strings (ie secret_value = cat $file | base64).

You will need 4 files
* public CA (pem)
* public cert (pem) that was generated from the CA
* private cert (key) that was generated from the CA
* ca bundle (tgz).  Basically a tar where there is 1 file in it - the public CA.  This tar should then be gzipped so the final file is a tgz.  See
the `generate_trust_bundle()` function in [generate_self_signed_mtls_certs.sh](./generate_self_signed_mtls_certs.sh) for an example of how to generate this.

Once you have the files, base64 encode them (cat $file | base64) and upload that string to ASM.  You will have 1 ASM secret per file, ensure no newlines are present in the uploaded secret.
4. Add a tag to your ASM secrets to grant the ECS cluster access to the secrets. Key = stack, value = `stack_name`.  `stack_name` is one of the Terraform outputs in Step 1.
5. Add the *_additional_secret_arns to the Bigeye terraform module as shown in [main.tf](./main.tf) to point Bigeye at your custom SSL certs and run terraform apply.  If you used [generate_self_signed_mtls_certs.sh](./generate_self_signed_mtls_certs.sh) to generate the certs, the ARNs will be in the output from that script. 
6. Go to the ECS web ui and manually stop all tasks associated with the Temporal service as there will be conflict between the existing Temporal service running with
default mTLS certs and the new one that is trying to start up with your custom certs.  ECS will automatically restart after a minute or two.

## Configuration

The following variables are required to use your own custom mTLS certs:

* `temporal_use_default_certificates` - set this to false to use custom mTLS certs
* `datawatch_additional_secret_arns` - this is a set ASM secrets that will be used by the datawatch service to connect to Temporal - see [main.tf](./main.tf) for implementation
* `temporal_additional_secret_arns` = this is a set ASM secrets that will be used by the temporal service for connections from all clients - see [main.tf](./main.tf) for implementation
* `temporalui_additional_secret_arns` = this is a set ASM secrets that will be used by the temporalui service to connect to Temporal - see [main.tf](./main.tf) for implementation

The certs required by Bigeye will be
- root ca public key (pem) - this is used by client and server to trust certificate pairs
- public cert generated from the root ca (pem)
- private cert generated from the root ca (key)

The same public/private key pair will be used on both client and server side in this example for the sake of simplicity. 
If desired, datawatch, temporal, and temporalui can use different public/private key pairs as long as they are all 
generated from the same root ca.

A sample configuration can be found in [main.tf](./main.tf).

## Scripts
Also included in this example is a helper script to generate a set of self-signed certs and upload them to ASM.  This can be run with -h for more detail.
- generate_self_signed_mtls_certs.sh
