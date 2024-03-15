# Self-Managed VPC

Some installation environments may require installing
Bigeye in an existing VPC. This example shows the necessary
configuration of variables to accomplish a Bigeye stack
install within an existing VPC environment.

See the "Standard" example for more details on general Bigeye stack configuration

## Prerequisites

You will need all the same prerequisites as the standard
install, as well as an existing VPC with appropriate subnets.

## Configuration

Follow all the configuration steps in the standard install,
and then add the following variables:

* `byovpc_vpc_id` - get this from the VPC you're installing within
* `byovpc_rabbitmq_subnet_ids` - a list of subnet IDs to install the RabbitMQ
broker. These do not need internet access.
* `byovpc_internal_subnet_ids` - a list of subnet IDs to create internal
service load balancers. These do not need internet access.
* `byovpc_application_subnet_ids` - a list of subnet IDs to launch ECS tasks.
These should have egress to the internet.
* `byovpc_public_subnet_ids` - a list of subnet IDs to launch internet-facing
load balancers.
* `byovpc_redis_subnet_group_name` - the name of the subnet group to launch
the Redis node(s).
* `byovpc_database_subnet_group_name` - the name of the subnet group to launch
the RDS instances.

Your VPC structure will dictate which subnet IDs need to be
chosen for each category here. You must provide at least two
subnet IDs for the variables that ask for the list. For example,
AWS Application Load Balancers requires subnets from at least
two availability zones.

A sample configuration can be found in [main.tf](./main.tf).
