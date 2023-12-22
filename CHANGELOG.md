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

#### IMPORTANT - Database Name Change

A new variable `datawatch_rds_db_name` was added with a
default value of `bigeye`. In existing installations, this is a breaking
change. In order to avoid destroying your database (and data!), please
set the following variable: `datawatch_rds_db_name = "toro"`.

#### Upgrade AWS Terraform Provider

The required AWS Terraform provider was updated to 5.31.0. This requires
running the following command:

```sh
terraform init -upgrade
```

#### Temporal LB changes

Two breaking changes were added for the Temporal LB. Applying these
will cause the Temporal LB to be destroyed and created.

While the LB is offline, no workers will be able to start new work,
and no new work (e.g. metric runs) will be scheduled. Work already in
queue will remain there and be picked up when the LB is up and service
is restored.

Simply run the normal `terraform apply` commands to update the
Load Blaancer. Note, due to the recency of Security Group support, this
encounters a bug in the AWS Terraform Provider, and you will have to run
the `terraform apply` command twice.

##### Add Security Group to Temporal LB

By default, a security group has been added to the
Network Load Balancer for the Temporal service. AWS does not support
modifying Security Groups on Network Load Balancers at this time, so
this change requires the NLB to be destroyed and recreated.

##### Modify default visibility for Temporal LB

A new variable `temporal_internet_facing`
has been introduced to control whether the Temporal LB is internet
facing. The default is `false`, which is a breaking change causing
the LB to be destroyed and recreated.

Recommendation: accept the new default and migrate to an internal
temporal LB. This is more secure since it avoids unnecessary public
access to the Temporal LB.


## [0.5.1](https://github.com/bigeyedata/terraform-modules/compare/v0.5.0...v0.5.1) (2023-12-21)


### Bug Fixes

* add datadog api key to service container if enabled ([f2b4a35](https://github.com/bigeyedata/terraform-modules/commit/f2b4a35f04b7202def6c3a0560d628b3db1777cc))



# [0.5.0](https://github.com/bigeyedata/terraform-modules/compare/v0.4.0...v0.5.0) (2023-12-20)


### Features

* add an image repository suffix variable ([9af4648](https://github.com/bigeyedata/terraform-modules/commit/9af4648eef5255ca0ea9b1175e218845d710d7dd))



# [0.4.0](https://github.com/bigeyedata/terraform-modules/compare/v0.3.0...v0.4.0) (2023-12-20)


### Bug Fixes

* update deploy so mulitiple deploys run serially ([9fc38f8](https://github.com/bigeyedata/terraform-modules/commit/9fc38f8667c50ba040d57818f7f22591d8dba42c))


### Features

* update temporal env vars to latest CLI ([1821dbb](https://github.com/bigeyedata/terraform-modules/commit/1821dbb895ad82f3641ce571596e888ecd23f633))



# [0.3.0](https://github.com/bigeyedata/terraform-modules/compare/v0.2.2...v0.3.0) (2023-12-20)


### Features

* update temporal env vars to latest CLI ([9799cc9](https://github.com/bigeyedata/terraform-modules/commit/9799cc99af406a61d946176fa5007748c84238bc))



