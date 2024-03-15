# Troubleshooting

For installation issues, there is a bundled troubleshooting module
called bigeye-admin. This module launches an ECS Task inside the VPC to test
networking, DNS, and other potential failure modes.

## Prerequisites

You will need your cluster name, which will be a combination of the
`environment` and `instance` variables from your terraform file. E.g.
`test-bigeye`, `prod-bigeye`, etc. Hereafter in this document, the cluster
name will be referred to as `CLUSTER_NAME`.

The AWS CLI ([install docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
and Simple Systems Manager plugin (SSM, [install docs](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html))
are required to access the Troubleshooting service.

## Enabling the Admin Module

You will need to modify your terraform like so:

```tf
// ...
module "bigeye" {
  // ...
  # add this line to your Bigeye module
  enable_bigeye_admin_module = true
}
```

The changes above will enable and configure the admin module.
Apply the changes using `terraform apply`.

## Accessing the Admin Service

### Task ID

To access the admin service, you will need to get a Task ID.
You can either get the Task Arn using the AWS Console or the AWS CLI.

#### Get Task Arn from AWS CLI

```sh
# Assign your CLUSTER_NAME into your shell
CLUSTER_NAME="<paste your CLUSTER_NAME here>"

# get the task Arn
aws ecs list-tasks --cluster $CLUSTER_NAME --service-name \
"${CLUSTER_NAME}-bigeye-admin" --query 'taskArns[*]' --output text

# Copy the first line which should be an Arn 
TASK_ARN="<paste value here>"
```

#### Get Task ID from AWS Console

1. Log into the AWS Console.
2. In the search box, type "ECS", select the "Elastic Container Service" to
navigate to the ECS dashboard.
3. Locate and click on your cluster in the list of clusters. The name will
correspond to the `environment` and `instance` variables from your terraform
file.
4. Locate and click on the `bigeye-admin` service in the cluster Services tab.
5. Select the `Tasks` tab. The Tasks will be listed there.
6. Copy the Arn from that screen, or click on the Task and copy the Arn from
the next screen.

Set up your CLI to have the variables it will need for the next command

```sh
CLUSTER_NAME="<paste your CLUSTER_NAME here>"
TASK_ARN="<paste value here>"
```

### Shell into Admin Container

The admin container is configured to allow executing a command (e.g. `/bin/bash`)
to access the bigeye-admin tool.

```sh
aws ecs execute-command --cluster "$CLUSTER_NAME" --task "$TASK_ARN" \
--container "${CLUSTER_NAME}-bigeye-admin" --command "/bin/bash" --interactive
```

At this your terminal should show an empty prompt like:

```text
The Session Manager plugin was installed successfully. Use the AWS CLI to start
a session.

Starting session with SessionId: ecs-execute-command-08327dd62c1dae733
root@ip-10-100-193-204:/# 
```

## Troubleshooting Steps

The bigeye-admin container contains a CLI tool (`bigeye-admin`) that exercises
several components required for the bigeye stack to work correctly.

```sh
# bigeye-admin --help
Usage: bigeye-admin [OPTIONS] COMMAND [ARGS]...

Options:
  --version   Show the version and exit.
  -h, --help  Show this message and exit.

Commands:
  test
```

### DNS

```sh
# Test datawatch's DNS config
bigeye-admin test dns -a datawatch

# Test all DNS config
bigeye-admin test dns --all
```

This will verify that all the expected DNS records are present, and
that they resolve to some address.

### ECS

```sh
# Test datawatch's ECS resources
bigeye-admin test ecs -a datawatch


# Test all apps ECS resources
bigeye-admin test ecs --all
```

There are a number of components that have to work together for traffic
to successfully be handled by ECS. This test checks that:

* ECS service is ready
* ECS service has tasks
* ECS service tasks are listening on the health check port
* Load balancer is ready
* Load balancer is listening on the correct ports
* ELB target group has targets
* ELB target group health checks are configured correctly

Due to the number of validations this command performs, this may
take a minute or two to complete.

### RDS

```sh
# Test the datawatch database
bigeye-admin test rds -a datawatch

# Test the temporal database
bigeye-admin test rds -a temporal

# Test both RDS databases
bigeye-admin test rds --all
```

These two RDS databases are necessary for datawatch and temporal to start.
This command tests that the databases are available, that they can listen
on the correct port, and that login succeeds.

### RabbitMQ

```sh
bigeye-admin test rabbitmq
```

This checks that rabbitmq is up, it can listen on the correct port, and that
login succeeds with the correct auth code.

### Redis

```sh
bigeye-admin test redis
```

This checks that redis is up, it can listen on the correct port, and that
login succeeds with the correct auth code.

### Temporal

```sh
bigeye-admin test temporal
```

This verifies that the temporal service is available and that a connection
can be made.
