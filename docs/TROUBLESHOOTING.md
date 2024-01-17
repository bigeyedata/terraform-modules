# Troubleshooting

For installation issues, there is a bundled troubleshooting module called bigeye-admin. This module
launches an ECS Task inside the VPC to test networking, DNS, and other
potential failure modes.

## Prerequisites

You will need your cluster name, which will be a combination of the `environment`
and `instance` variables from your terraform file. E.g. `test-bigeye`, `prod-bigeye`, etc.
Hereafter in this document, the cluster name will be referred to as `CLUSTER_NAME`.

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
aws ecs list-tasks --cluster $CLUSTER_NAME --service-name "${CLUSTER_NAME}-bigeye-admin" --query 'taskArns[*]' --output text

# Copy the first line which should be an Arn 
TASK_ARN="<paste value here>"
```

#### Get Task ID from AWS Console

1. Log into the AWS Console.
2. In the search box, type "ECS", select the "Elastic Container Service" to navigate to the ECS dashboard.
3. Locate and click on your cluster in the list of clusters. The name will correspond to the `environment` and `instance` variables from your terraform file.
4. Locate and click on the `bigeye-admin` service in the cluster Services tab.
5. Select the `Tasks` tab. The Tasks will be listed there.
6. Copy the Arn from that screen, or click on the Task and copy the Arn from the next screen.

Set up your CLI to have the variables it will need for the next command

```sh
CLUSTER_NAME="<paste your CLUSTER_NAME here>"
TASK_ARN="<paste value here>"
```

### Shell into Admin Container

The admin container is configured to allow executing a command (e.g. `/bin/bash`)
to access the bigeye-admin tool.

```sh
aws ecs execute-command --cluster "$CLUSTER_NAME" --task "$TASK_ARN" --container "${CLUSTER_NAME}-bigeye-admin" --command "/bin/bash" --interactive
```

At this your terminal should show an empty prompt like:

```text
The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.


Starting session with SessionId: ecs-execute-command-08327dd62c1dae733
root@ip-10-100-193-204:/# 
```

## Troubleshooting Steps

TODO
