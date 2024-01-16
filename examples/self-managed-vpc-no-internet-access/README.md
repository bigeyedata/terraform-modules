# Self-Managed VPC

Some installation environments may require installing Bigeye in a VPC that has no NAT or route for
any services or resources to public net. The method for doing this is to create your own (or bring 
an existing) VPC that does not have internet access and pass it into the Bigeye module.  

This example shows the necessary configuration of variables for the Bigeye module to accomplish 
this as well as a sample VPC configuration with the necessary VPC Endpoints (S3, logs, ECR) and
security groups that can be used as a reference.  The VPC endpoints are required for the services
to function properly without access to AWS' public service endpoints and is just overall a recommended
practice, even if your installation will have access to/from public net.

Creating your own security groups allows you to restrict inbound traffic to just your VPC cidr 
which is a 2nd level of security beyond simple removing subnet routes to public net.

See the "Standard" example for more details on general Bigeye stack configuration.

## Prerequisites

You will need all the same prerequisites as the standard
install, as well as an existing VPC with appropriate subnets.

## Configuration

Follow all the configuration steps in the standard install,
and then add the following variables:

* `byovpc_vpc_id` - get this from the VPC you're installing within
* `byovpc_rabbitmq_subnet_ids` - a list of subnet IDs to install the RabbitMQ broker. These do not need internet access.
* `byovpc_internal_subnet_ids` - a list of subnet IDs to create internal service load balancers. These do not need internet access.
* `byovpc_application_subnet_ids` - a list of subnet IDs to launch ECS tasks. These should have egress to the internet.
* `byovpc_public_subnet_ids` - a list of subnet IDs to launch internet-facing load balancers.
* `byovpc_redis_subnet_group_name` - the name of the subnet group to launch the Redis node(s).
* `byovpc_database_subnet_group_name` - the name of the subnet group to launch the RDS instances.
* `temporal_internet_facing = false` - do not create the temporal service LB as public facing
* `internet_facing          = false` - do not create the API/UI LB as public facing
* `create_security_groups = false` - do not create security groups for the various services.  This allows you to bring your own with inbound cidr ranges restricted.  While technically not required since the subnets do not have a route to public net, this is a 2nd layer of security to ensure no public inbound traffic is allowed to the Bigeye application.  You will likely want to add your VPN cidr range to this anyhow.
* `*_extra_security_group_ids` - use your own security groups for resources (see create_security_groups = false)

Your VPC structure will dictate which subnet IDs need to be
chosen for each category here. You must provide at least two
subnet IDs for the variables that ask for the list. For example,
AWS Application Load Balancers requires subnets from at least
two availability zones.

A sample configuration can be found in [main.tf](./main.tf).

