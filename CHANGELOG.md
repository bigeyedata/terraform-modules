## [1.8.1](https://github.com/bigeyedata/terraform-modules/compare/v1.8.0...v1.8.1) (2024-01-19)


### Bug Fixes

* configure iam policy for bigeye-admin ([255f8a1](https://github.com/bigeyedata/terraform-modules/commit/255f8a17c489d9afaf549399764b54ab0dbc920d))
* prevent terraform dependency graph issues for admin module ([1b7f490](https://github.com/bigeyedata/terraform-modules/commit/1b7f490d3927f7a4657edd1912caab49052aa932))



# [1.8.0](https://github.com/bigeyedata/terraform-modules/compare/v1.7.0...v1.8.0) (2024-01-19)


### Features

* propagate ECS tags to the task ([bf04efd](https://github.com/bigeyedata/terraform-modules/commit/bf04efd516810750fdefd769a48fca9521431056))



# [1.7.0](https://github.com/bigeyedata/terraform-modules/compare/v1.6.2...v1.7.0) (2024-01-18)


### Bug Fixes

* add environment variables for admin module ([d710f24](https://github.com/bigeyedata/terraform-modules/commit/d710f244a5d38aa0b34b83ae8287919b42ad2e8d))


### Features

* release initial version of bigeye-admin container ([c4ead4f](https://github.com/bigeyedata/terraform-modules/commit/c4ead4f1f5b998c21b5d9683feb066929fe29661))



## [1.6.2](https://github.com/bigeyedata/terraform-modules/compare/v1.6.1...v1.6.2) (2024-01-18)


### Bug Fixes

* normalize subnet names ([fffe0ed](https://github.com/bigeyedata/terraform-modules/commit/fffe0ed3253f9dece350b78cad95a65eb7fef039))
* remove DEMO_ENDPOINT_ENABLED env var ([acf02cc](https://github.com/bigeyedata/terraform-modules/commit/acf02ccb845c30e42c673dffa86613d650a91393))



## [1.6.1](https://github.com/bigeyedata/terraform-modules/compare/v1.6.0...v1.6.1) (2024-01-18)


### Bug Fixes

* normalize subnet names ([6ba167f](https://github.com/bigeyedata/terraform-modules/commit/6ba167fbb84772a171f6380e14fbdf72b37e09f8))



# [1.6.0](https://github.com/bigeyedata/terraform-modules/compare/v1.5.0...v1.6.0) (2024-01-16)


### Features

* add VPC endpoints for resources required for ECS ([724ab0a](https://github.com/bigeyedata/terraform-modules/commit/724ab0addca8bce7fb33eac03e9fc86a58233af6))



# [1.5.0](https://github.com/bigeyedata/terraform-modules/compare/v1.4.0...v1.5.0) (2024-01-12)


### Features

* add NAT IPs to TF output ([2995d6c](https://github.com/bigeyedata/terraform-modules/commit/2995d6c49b529effcc4fcceb5ad6a7b53896e1cd))



# [1.4.0](https://github.com/bigeyedata/terraform-modules/compare/v1.3.0...v1.4.0) (2024-01-11)


### Features

* enable service-specific image tag overrides ([f3cabd3](https://github.com/bigeyedata/terraform-modules/commit/f3cabd37466a47d54ecc6bbac07c353f2e12f389))



# [1.3.0](https://github.com/bigeyedata/terraform-modules/compare/v1.2.1...v1.3.0) (2024-01-11)


### Bug Fixes

* non-sensitive variables should not be marked as sensitive ([9dac420](https://github.com/bigeyedata/terraform-modules/commit/9dac4200663317fbe773de368e515e054e676c38))


### Features

* specify defaulted values in task definition ([127a605](https://github.com/bigeyedata/terraform-modules/commit/127a605cce6f53ea67351c134fd4dd4fc24c8b8a))
* use a secret ARN to store DD agent api key ([e35ab7d](https://github.com/bigeyedata/terraform-modules/commit/e35ab7d5538adcbc1716995c0a6f82eb89b489e2))



## [1.2.1](https://github.com/bigeyedata/terraform-modules/compare/v1.2.0...v1.2.1) (2024-01-11)


### Bug Fixes

* reduce time it takes to mark ECS nodes as healthy ([9aba1e7](https://github.com/bigeyedata/terraform-modules/commit/9aba1e7dcd725bc1d072dd4d49cbb96f9620bf1f))



# [1.2.0](https://github.com/bigeyedata/terraform-modules/compare/v1.1.0...v1.2.0) (2024-01-10)


### Features

* add troubleshooting client security group to resources ([817e9f3](https://github.com/bigeyedata/terraform-modules/commit/817e9f30106e803defc514ebd5052628a4d2cccd))
* add troubleshooting container instance ([c741fd5](https://github.com/bigeyedata/terraform-modules/commit/c741fd597191681ff9a26cd8b887e4ae9a994549))
* update ECS configuration to log execute commands ([29fae91](https://github.com/bigeyedata/terraform-modules/commit/29fae91a32e6815a9e198833d03d568c5aafda1c))
* use troubleshooting container in main bigeye module ([9e40921](https://github.com/bigeyedata/terraform-modules/commit/9e4092104fff05d85825790001102b49f09c72f4))



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



## [0.2.2](https://github.com/bigeyedata/terraform-modules/compare/v0.2.1...v0.2.2) (2023-12-13)


### Bug Fixes

* use vanity_alias for all dns names ([4004a5d](https://github.com/bigeyedata/terraform-modules/commit/4004a5d2a79533be7448d95de203a60565f94fe7))



## [0.2.1](https://github.com/bigeyedata/terraform-modules/compare/v0.2.0...v0.2.1) (2023-12-06)


### Bug Fixes

* remove empty string validation on image_registry ([72889f5](https://github.com/bigeyedata/terraform-modules/commit/72889f53daa05aacae4532cc8404a5e71492ff4b))



# [0.2.0](https://github.com/bigeyedata/terraform-modules/compare/v0.1.0...v0.2.0) (2023-12-01)


### Bug Fixes

* remove duplicate default ([90ffbf3](https://github.com/bigeyedata/terraform-modules/commit/90ffbf35f54f3aaf95ebd8817253d0ffcef71b9c))


### Features

* add validation rules to common variables ([11fdd73](https://github.com/bigeyedata/terraform-modules/commit/11fdd738f509d1510ad26bca6696b7e011415af7))
* allow slack and auth0 secrets to be empty/unset ([1069765](https://github.com/bigeyedata/terraform-modules/commit/1069765cccb041d649aa58d7c0ab5a8a47b0149f))
* default image_tag to latest and default registry to account ECR ([771e62e](https://github.com/bigeyedata/terraform-modules/commit/771e62e935d64fdad718f6af8988fdae4f867843))



# [0.1.0](https://github.com/bigeyedata/terraform-modules/compare/v0.0.0...v0.1.0) (2023-11-30)


### Features

* add bigeye stack ([1516c13](https://github.com/bigeyedata/terraform-modules/commit/1516c13821df592f7093b6b72a7f955b005a2390))
* add rabbitmq module ([b621459](https://github.com/bigeyedata/terraform-modules/commit/b6214590e2ac95ed2106c56fc83963e44e2b9f43))
* add rds module ([922dda1](https://github.com/bigeyedata/terraform-modules/commit/922dda1b57f686d5a41a83edac3ca7be0d90e07d))
* add redis module ([5181c58](https://github.com/bigeyedata/terraform-modules/commit/5181c582ba2261f121b25d09539c4bd9039bc5db))
* add simpleservice module ([fe8c317](https://github.com/bigeyedata/terraform-modules/commit/fe8c317dce9646be28c1439b5b9924b1128863b5))
