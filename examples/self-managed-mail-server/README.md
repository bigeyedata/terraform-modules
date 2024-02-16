# Self-Managed Mail Server

Some installation environments may require using a custom SMTP server to relay
Bigeye email notifications instead of the default Bigeye SMTP server.  Installs
where no internet-access is allowed is a common use case for this.

## Prerequisites

You will need all the same prerequisites as the standard
install as well as your custom SMTP server connection info.

Also create an AWS secrets manager secret and put the password for your SMTP credential as a string.

## Configuration

* `byomailserver_smtp_host` - hostname of your custom SMTP server
* `byomailserver_smtp_port` - port of your custom SMTP server
* `byomailserver_smtp_user` - username for your custom SMTP server
* `byomailserver_smtp_password_secret_arn` - AWS secrets manager ARN containing the password for your custom SMTP server.  See [main.tf](./main.tf) for implementation

A sample configuration can be found in [main.tf](./main.tf)