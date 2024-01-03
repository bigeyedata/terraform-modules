# [1.1.0](https://github.com/bigeyedata/terraform-modules/compare/v1.0.1...v1.1.0) (2024-01-03)


### Bug Fixes

* add scheduler address to self for localhost calls ([458696c](https://github.com/bigeyedata/terraform-modules/commit/458696cc2fd21ab35c331f71fa4d55ef60b1cad6))
* rds module should respect `create_security_groups` var ([3b664e1](https://github.com/bigeyedata/terraform-modules/commit/3b664e1bd3a124c38196c1a57506758844b30e74))
* send correct security groups when `create_security_groups` is false ([896d40a](https://github.com/bigeyedata/terraform-modules/commit/896d40a371f41ec4dd6cbfb580bc12cc4d82f90d))
* use `datawatch_rds_db_name` for datawatch JDBC connection string ([ca718db](https://github.com/bigeyedata/terraform-modules/commit/ca718db35d3f3b5b619f03f429b760de20ba591a))


### Features

* add validation for ECS task security groups ([dd2acc5](https://github.com/bigeyedata/terraform-modules/commit/dd2acc5fd45bbd876b272bf3e7a325d70de46d7d))
* add validation message for rabbitmq security groups ([d6f7b7e](https://github.com/bigeyedata/terraform-modules/commit/d6f7b7e2f3212e0fd25a0c7539d25ae91781e973))
* add validation messages for redis and rds security groups ([c62ea0d](https://github.com/bigeyedata/terraform-modules/commit/c62ea0d70a86432fe7ca8b01bc5e5839cc267799))
* add validation rules ([19454b5](https://github.com/bigeyedata/terraform-modules/commit/19454b53abbf043519ba1dd0bda67cdc543d7cd5))



## [1.0.1](https://github.com/bigeyedata/terraform-modules/compare/v1.0.0...v1.0.1) (2023-12-27)


### Bug Fixes

* update temporal LB SG to allow 443 ([d994113](https://github.com/bigeyedata/terraform-modules/commit/d994113007a5868ec5815aded6fcda1fd8cf30ca))



# [1.0.0](https://github.com/bigeyedata/terraform-modules/compare/v0.5.1...v1.0.0) (2023-12-22)


### Bug Fixes

* grant monocle and toretto IAM access to S3 ([d84bd59](https://github.com/bigeyedata/terraform-modules/commit/d84bd59e7994e7329034ecc3d29cbbc1f5387961))
* respect create_security_groups variable for services ([183c2e9](https://github.com/bigeyedata/terraform-modules/commit/183c2e99e8bab9838c3e5e7cbdc00ed11f792b21))
* respect create_security_groups variable for temporal ([f0806cf](https://github.com/bigeyedata/terraform-modules/commit/f0806cf5d612cfbcee1ea1e005e9ce3643540e22))
* use bigeye as the default mysql db name for the app db ([3f88717](https://github.com/bigeyedata/terraform-modules/commit/3f88717bea84dd96573a2e6bf8771dfdd2ac6aef))


* chore!: update AWS provider ([d6ec311](https://github.com/bigeyedata/terraform-modules/commit/d6ec3117dfce49884b0af4d6604912425e42f3a3))
* feat!: add security group to temporal network load balancer ([4cf79dd](https://github.com/bigeyedata/terraform-modules/commit/4cf79dd26f8e84e00c17497c87d4673ea2886340))
* feat!: move temporal load balancer to private by default ([954dd41](https://github.com/bigeyedata/terraform-modules/commit/954dd41297ee1166e2e6a7b27df96265a6624e06))


### Features

* add plumbing for bringing your own security group ids for services ([f2147e9](https://github.com/bigeyedata/terraform-modules/commit/f2147e9805cbbc55d7180b193a67e3588b33427e))


### BREAKING CHANGES

* This change updates the required AWS Terraform
provider, and requires re-initializing terraform in your directory.

Steps: Run `terraform init -upgrade` to install the new
AWS Terraform provider
* By default, a security group is added to the
Network Load Balancer for the Temporal service. AWS does not support
modifying Security Groups on Network Load Balancers at this time, so
this change requires the NLB to be destroyed and recreated.

Downtime: Yes. There will be downtime while Terraform destroys and
recreates the NLB. While the NLB is offline, no workers will be able
to start new work, and no new work (e.g. metric runs) will be scheduled.
Work already in queue will remain there and be picked up when the LB
is up and service is restored.

Steps: Upgrade the terraform module version and run terraform apply.
* A new variable `temporal_internet_facing`
has been introduced to control whether the Temporal LB is internet
facing. The default is `false`, which is a breaking change causing
the LB to be destroyed and recreated.

Recommendation: accept the new default and migrate to an internal
temporal LB. This is more secure since it avoids unnecessary public
access to the Temporal LB.

Downtime: Yes. There will be a service interruption for this change.
While the service is offline, workers will not be able to retrieve work
and no new work (i.e. metric runs) will be able to be published to the
work queue. Work already in queue will remain there and get picked up
as soon as the Temporal service is restored.

Steps: Upgrade the terraform module version and run terraform apply.
Terraform will destroy and recreate the load balancer if necessary.
For customers who do not wish to make this change, or wish to make this
change at a later date, set the `temporal_internet_facing`
variable to `true`.
* Existing installs will need to set the
`datawatch_rds_db_name = 'toro'` variable or the upgrade will
destroy the application database will all application settings
(including users etc).



## [0.5.1](https://github.com/bigeyedata/terraform-modules/compare/v0.5.0...v0.5.1) (2023-12-21)


### Bug Fixes

* add datadog api key to service container if enabled ([f2b4a35](https://github.com/bigeyedata/terraform-modules/commit/f2b4a35f04b7202def6c3a0560d628b3db1777cc))



# [0.5.0](https://github.com/bigeyedata/terraform-modules/compare/v0.4.0...v0.5.0) (2023-12-20)


### Features

* add an image repository suffix variable ([9af4648](https://github.com/bigeyedata/terraform-modules/commit/9af4648eef5255ca0ea9b1175e218845d710d7dd))



