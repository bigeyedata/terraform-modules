# Alarms

Monitoring cloud resources can be accomplished a number of ways, and we understand
there may not be a one-size-fits-all approach to providing monitoring for the Bigeye
stack. The `alarms` module is deployed alongside, rather than within, the
primary `bigeye` module. This allows for the possibility of using other
monitoring solutions instead. The `alarms` module uses CloudWatch Metrics and Alarms
to monitor resources, and SNS Topics to alert on them. These CloudWatch Alarms can
be individually configured to tune specific alarms to your operating conditions.
The module includes default values which are reasonable based off our experience.
However, there will likely need to be modifications made to tune specific alarms
to your deployment.

## Prerequisites

Stand up a stack using the "Standard" example, or any of the other examples
which best reflect your needs.

## Configuration

Create another module in your `main.tf` pointing at the `alarms` module.
Look in the included [main.tf](./main.tf) file. You will need to pass along
outputs from the `bigeye` module so the `alarms` module can configure the resources
accordingly.

Each alarm has several settings which can be configured:

* `datapoints_to_alarm`
* `disabled`
* `evaluation_periods`
* `period`
* `threshold`
* `sns_arns`

You can override part or all of the defaults for a given alert.
For example, in order to override the CPU alarm threshold for
Datawatch's RDS database, you would specify:

```hcl
# ...
module "alarms" {
  # ...
  rds_datawatch_cpu_threshold = 80
  # ...
}
```

To override all the values, that would look like:

```hcl
# ...
module "alarms" {
  # ...
  rds_datawatch_cpu_threshold = 80
  rds_datawatch_cpu_datapoints_to_alarm = 5
  rds_datawatch_cpu_period = 300
  rds_datawatch_cpu_evaluation_periods = 3
  rds_datawatch_cpu_sns_arns = ["arn:aws:..."]
  # ...
}
```

To disable a specific alarm, set `disabled` to `true` like so:

```hcl
module "alarms" {
  # ...
  rds_datawatch_cpu_disabled = true
  # ...
}
```

To see all the alarms and their defaults, please refer to the module
[variables.tf file](../../modules/alarms/variables.tf).
