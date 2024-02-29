# [3.3.0](https://github.com/bigeyedata/terraform-modules/compare/v3.0.0...v3.3.0) (2024-02-29)


### Bug Fixes

* remove read-after-write race for rds databases ([776ebd5](https://github.com/bigeyedata/terraform-modules/commit/776ebd54c387c76212f0f6e34eddd0725e4b0cd3))
* remove read-after-write race for redis auth token ([7c684c2](https://github.com/bigeyedata/terraform-modules/commit/7c684c2810171c5b5da797aae8f9e7ee7fd71762))
* remove read-after-write race for secret in rabbitmq ([3e33823](https://github.com/bigeyedata/terraform-modules/commit/3e33823e5cd41184bcb84452f4d400c8cec5e97c))
* upgrade slackapi/slack-github-action to v1.25.0 ([da3d503](https://github.com/bigeyedata/terraform-modules/commit/da3d50320ba52813342864d6e9076501720522b0))


### Features

* use inline policy rather than AWS-managed policy ([f68a32f](https://github.com/bigeyedata/terraform-modules/commit/f68a32ff0016528522b85df22aeb6c36b29a83c7))



# [3.2.0](https://github.com/bigeyedata/terraform-modules/compare/v3.0.0...v3.2.0) (2024-02-29)


### Bug Fixes

* remove read-after-write race for rds databases ([776ebd5](https://github.com/bigeyedata/terraform-modules/commit/776ebd54c387c76212f0f6e34eddd0725e4b0cd3))
* remove read-after-write race for redis auth token ([7c684c2](https://github.com/bigeyedata/terraform-modules/commit/7c684c2810171c5b5da797aae8f9e7ee7fd71762))
* remove read-after-write race for secret in rabbitmq ([3e33823](https://github.com/bigeyedata/terraform-modules/commit/3e33823e5cd41184bcb84452f4d400c8cec5e97c))
* upgrade slackapi/slack-github-action to v1.25.0 ([da3d503](https://github.com/bigeyedata/terraform-modules/commit/da3d50320ba52813342864d6e9076501720522b0))


### Features

* use inline policy rather than AWS-managed policy ([f68a32f](https://github.com/bigeyedata/terraform-modules/commit/f68a32ff0016528522b85df22aeb6c36b29a83c7))



# [3.1.0](https://github.com/bigeyedata/terraform-modules/compare/v3.0.0...v3.1.0) (2024-02-28)


### Bug Fixes

* remove read-after-write race for rds databases ([776ebd5](https://github.com/bigeyedata/terraform-modules/commit/776ebd54c387c76212f0f6e34eddd0725e4b0cd3))
* remove read-after-write race for redis auth token ([7c684c2](https://github.com/bigeyedata/terraform-modules/commit/7c684c2810171c5b5da797aae8f9e7ee7fd71762))
* remove read-after-write race for secret in rabbitmq ([3e33823](https://github.com/bigeyedata/terraform-modules/commit/3e33823e5cd41184bcb84452f4d400c8cec5e97c))


### Features

* use inline policy rather than AWS-managed policy ([f68a32f](https://github.com/bigeyedata/terraform-modules/commit/f68a32ff0016528522b85df22aeb6c36b29a83c7))



# [3.0.0](https://github.com/bigeyedata/terraform-modules/compare/v2.13.0...v3.0.0) (2024-02-23)


### Bug Fixes

* use dedicated ingress rule for rabbitmq security group ([5fef368](https://github.com/bigeyedata/terraform-modules/commit/5fef3689316838c0e2b40f3d0106cfb47cc020ab))


### Features

* allow admin container access to RabbitMQ ([668e271](https://github.com/bigeyedata/terraform-modules/commit/668e271f0cce0afd2a3f211170f8eed3e5337889))


### BREAKING CHANGES

* This requires manual deletion of the <stack>-rabbitmq
instance.

AWS managed RabbitMQ does not allow changing security group membership
for RabbitMQ so the resource must be deleted manually first before
we can allow the admin container access to RabbitMQ.
* This requires users to remove all existing
security group rules from the <stack>-rabbitmq security group.

The terraform run will fail due to duplicate ingress rules otherwise.

This change was required to avoid terraform perpetually detecting
changes when rabbitmq_extra_cidr_blocks is an empty list (default).



# [2.13.0](https://github.com/bigeyedata/terraform-modules/compare/v2.12.0...v2.13.0) (2024-02-22)


### Bug Fixes

* add depends_on to improve deployment flow ([3a37200](https://github.com/bigeyedata/terraform-modules/commit/3a372009643848cab6f705b7d2d1663ff5310d7c))


### Features

* add variable for num history shards ([0d8460b](https://github.com/bigeyedata/terraform-modules/commit/0d8460b41495bdc62b09b990b8bf234e2cd51c32))
* allow rabbitmq cluster mode to be controlled directly ([73f7643](https://github.com/bigeyedata/terraform-modules/commit/73f7643d3b8e38ac2ed283177305a44370d2fb20))



# [2.12.0](https://github.com/bigeyedata/terraform-modules/compare/v2.11.0...v2.12.0) (2024-02-22)


### Features

* add ability to set ingress cidr blocks for rabbitmq ([ae4f96f](https://github.com/bigeyedata/terraform-modules/commit/ae4f96f3b197c55d2c9fa5bc95ba1b3f095718f3))



# [2.11.0](https://github.com/bigeyedata/terraform-modules/compare/v2.10.0...v2.11.0) (2024-02-22)


### Bug Fixes

* datadog metric checks for haproxy ([2a2cc79](https://github.com/bigeyedata/terraform-modules/commit/2a2cc7967f26338e8864df32f8772888234bb553))


### Features

* add variables for datadog container secrets ([72d2003](https://github.com/bigeyedata/terraform-modules/commit/72d20031c6cb8bb4457cb773082a09fa8a2226e2))



# [2.10.0](https://github.com/bigeyedata/terraform-modules/compare/v2.9.1...v2.10.0) (2024-02-16)


### Bug Fixes

* toretto autoscaling names ([3bc0d1e](https://github.com/bigeyedata/terraform-modules/commit/3bc0d1ecea762a77e41dc98a089baebaaf98a15a))
* toretto autoscaling should be based on datawatch count ([f5385dd](https://github.com/bigeyedata/terraform-modules/commit/f5385ddc01325999bf2a8e714fe6f7e2646eba9c))


### Features

* add autoscaling to monocle ([dd7b1eb](https://github.com/bigeyedata/terraform-modules/commit/dd7b1ebc382eca5d1a15786462c928ce2c998f42))
* add outputs from service module ([f99708e](https://github.com/bigeyedata/terraform-modules/commit/f99708ead622f6ad68832d36ecafafe54140672a))



## [2.9.1](https://github.com/bigeyedata/terraform-modules/compare/v2.9.0...v2.9.1) (2024-02-16)


### Bug Fixes

* default alarm settings ([23bd027](https://github.com/bigeyedata/terraform-modules/commit/23bd027c3af916e04dc8e0e8beb9de0269e47a02))



# [2.9.0](https://github.com/bigeyedata/terraform-modules/compare/v2.8.0...v2.9.0) (2024-02-16)


### Features

* add BYO mail server env vars to datawatch, datawork, metricwork ([3a814a4](https://github.com/bigeyedata/terraform-modules/commit/3a814a4868c42608d276960bc6a972f4149ecc17))



# [2.8.0](https://github.com/bigeyedata/terraform-modules/compare/v2.7.0...v2.8.0) (2024-02-15)


### Features

* add option to use existing high/low urgency SNS topics ([8c1ee45](https://github.com/bigeyedata/terraform-modules/commit/8c1ee45dfba87b92d6d3dae1e4fc7f887778d603))



# [2.7.0](https://github.com/bigeyedata/terraform-modules/compare/v2.6.0...v2.7.0) (2024-02-14)


### Features

* add control over temporal persistence QPS ([ff4b2d9](https://github.com/bigeyedata/terraform-modules/commit/ff4b2d90bfddc3644ee16df916b78946ccd0bd55))



# [2.6.0](https://github.com/bigeyedata/terraform-modules/compare/v2.5.0...v2.6.0) (2024-02-14)


### Bug Fixes

* broker name in bigeye module outputs ([f3c10fc](https://github.com/bigeyedata/terraform-modules/commit/f3c10fc3e50266b0d7ca0db0ef71bbe66aeacf23))


### Features

* add autoscaling for toretto ([a2ae211](https://github.com/bigeyedata/terraform-modules/commit/a2ae211538b1725f93960ea3a343aedc98206979))
* add broker name to outputs ([d1b9d0b](https://github.com/bigeyedata/terraform-modules/commit/d1b9d0b9277ce41507c43906d345c7d11faf7b75))



# [2.5.0](https://github.com/bigeyedata/terraform-modules/compare/v2.4.0...v2.5.0) (2024-02-13)


### Features

* add module for cloudwatch alarms ([dee7fb0](https://github.com/bigeyedata/terraform-modules/commit/dee7fb08f454d58705de1a3b82d1cae75b250042))
* add outputs to bigeye module for databases ([3a3aad9](https://github.com/bigeyedata/terraform-modules/commit/3a3aad9b9e423f0c6bec0ad46075d8fc4939f65d))



# [2.4.0](https://github.com/bigeyedata/terraform-modules/compare/v2.3.0...v2.4.0) (2024-02-13)


### Features

* add flag to control temporal logging ([c08dc57](https://github.com/bigeyedata/terraform-modules/commit/c08dc57caf65a932a5c4c69435fd9f5395218f31))



# [2.3.0](https://github.com/bigeyedata/terraform-modules/compare/v2.2.0...v2.3.0) (2024-02-12)


### Bug Fixes

* environment variables for bigeye-admin container ([e64989c](https://github.com/bigeyedata/terraform-modules/commit/e64989c111b6e4cb1e5397783c8f6ba709aeb3e2))


### Features

* allow separate optional tags for primary vs replica dbs ([b0e152c](https://github.com/bigeyedata/terraform-modules/commit/b0e152ce6ad8539b47cf7c52fb3bbe4d7b601fe7))



# [2.2.0](https://github.com/bigeyedata/terraform-modules/compare/v2.1.0...v2.2.0) (2024-02-02)


### Features

* set binlog format to ROW ([c1f4682](https://github.com/bigeyedata/terraform-modules/commit/c1f4682db12b0f91ca813cafb99945d78ceb1ffb))



# [2.1.0](https://github.com/bigeyedata/terraform-modules/compare/v2.0.0...v2.1.0) (2024-02-01)


### Bug Fixes

* add datawatch_db_name to handle edge case ([1f510fc](https://github.com/bigeyedata/terraform-modules/commit/1f510fcc39119eb84fdb3757d5079ef36875378b))
* add depends_on to prevent race condition on initial apply ([68f8ac8](https://github.com/bigeyedata/terraform-modules/commit/68f8ac8768c551abfd75e2106ad4e13466d91ab8))


### Features

* add datawatach_rds_root_user_name to configure db ([43ae61b](https://github.com/bigeyedata/terraform-modules/commit/43ae61b5060491f4657f81d4e1c74d1a567d6521))



# [2.0.0](https://github.com/bigeyedata/terraform-modules/compare/v1.16.0...v2.0.0) (2024-01-31)

### BREAKING CHANGES

#### Security Group Changes

A change was made to the security groups, which will result
in `terraform apply` getting stuck trying to
apply a security group rule when that rule already exists.

This is a result of moving from using an `ingress` block inside an
`aws_security_group` resource to a separate resource for the
`aws_vpc_security_group_ingress_rule`. This affects installations
unless you have `create_security_groups = false`.

##### Recommendation

You may either delete or import the conflicting
security group rule. The RDS security groups and Redis security groups
are affected. These have the names `-datawatch-db`, `-datawatch-db-replica`,
`-temporal-db`, `-temporal-db-replica`, and `-redis-cache`.

##### Downtime

"Yes" if you delete the security group rule. "No" if you import it.

##### Steps

To import the security group rule run: `terraform import [ADDR] [id]`.
The ADDR for each of the resources will be

* `module.bigeye.module.datawatch_rds.aws_vpc_security_group_ingress_rule.client_sg[0]`
* `module.bigeye.module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_client_sg[0]`
* `module.bigeye.module.temporal_rds.aws_vpc_security_group_ingress_rule.client_sg[0]`
* `module.bigeye.module.temporal_rds.aws_vpc_security_group_ingress_rule.replica_client_sg[0]`
* `module.bigeye.module.redis.aws_vpc_security_group_ingress_rule.client_sg[0]`

Make sure to wrap the ADDR with quotes, or the shell command will fail. Get the `[id]` for
each of the security groups from the AWS console.

For example:

```sh
terraform import "module.bigeye.module.datawatch_rds.aws_vpc_security_group_ingress_rule.client_sg[0]" sgr-1234567890
```

([10d1f4a](https://github.com/bigeyedata/terraform-modules/commit/10d1f4aa1822e4f73ab193e421ceb4c88d300b32))


#### Removed Variables

The following two variables have been removed:

* `sentry_dsn` ([9e2dce8](https://github.com/bigeyedata/terraform-modules/commit/9e2dce86e747f01b4a7ff3992884ea9b15cfd133))
* `datadog_agent_api_key` ([bc62730](https://github.com/bigeyedata/terraform-modules/commit/bc6273025d853bb953e75e1596c9560488be6864))

Instead, use the following variables:

* `sentry_dsn_secret_arn`
* `datadog_agent_api_key_secret_arn`

This allows for better secrets management and makes sure
that the `terraform plan` output isn't unnecessarily hidden.

#### Removed Outputs

All outputs starting with `temporal_admin_` have been replaced
with corresponding outputs starting with `temporalui_`.

([a4906b5](https://github.com/bigeyedata/terraform-modules/commit/a4906b581c7a056fc20ac3dde2134e2c5264ff3f))


### Bug Fixes

* remove redis client sg from services ([a8acd87](https://github.com/bigeyedata/terraform-modules/commit/a8acd875517fa35cf4a46f0d5d1a1bbf492fdd0d))
* update services to not require db client sg ([5cb71be](https://github.com/bigeyedata/terraform-modules/commit/5cb71be4fec84c6706b4acf72ad1e6e8debd97d8))


### Features

* add security_group_id as output from simpleservice ([99f612a](https://github.com/bigeyedata/terraform-modules/commit/99f612a05dbe5c02c5ef36a84f7d43902eee4caf))


# [1.16.0](https://github.com/bigeyedata/terraform-modules/compare/v1.15.0...v1.16.0) (2024-01-31)


### Bug Fixes

* align declared container def with deployed ([3d24a89](https://github.com/bigeyedata/terraform-modules/commit/3d24a89c4fb7ef9aa84ddee25f80da6be49abfe6))
* healthcheck for temporalui ([64b3557](https://github.com/bigeyedata/terraform-modules/commit/64b355762771d79d9b5941cdcf3396d853884b75))
* remove environment vars that can just be injected ([f28a3d0](https://github.com/bigeyedata/terraform-modules/commit/f28a3d0021cd28e0a265bfba8cbc6021df168045))
* send temporalui logs to temporal log group ([b5bbec3](https://github.com/bigeyedata/terraform-modules/commit/b5bbec3c45666fd8fab31fb57eb49816b47c48e5))
* typo in datadog environment variables ([d4d89f9](https://github.com/bigeyedata/terraform-modules/commit/d4d89f90f459b2d63c22786c8653ff379752429c))
* update healthcheck parameters ([a553a5c](https://github.com/bigeyedata/terraform-modules/commit/a553a5c50ff1276cccba9791e8fa8f2fdedd0a50))
* update web environment variables to respect env ([8022483](https://github.com/bigeyedata/terraform-modules/commit/8022483fd6f1861b7e699624bbf299c5b36957c8))
* updated temporal configuration to match other services ([41a9fb9](https://github.com/bigeyedata/terraform-modules/commit/41a9fb96fc3cbc1a60d8d93a5a739c3f0b92f8d5))


### Features

* add ability for additional docker labels if using datadog ([3f14589](https://github.com/bigeyedata/terraform-modules/commit/3f1458986349d277a4207b508c9ecff488427144))
* add datadog AD checks for haproxy ([861ac9b](https://github.com/bigeyedata/terraform-modules/commit/861ac9bb48dc44fad2c49e07f777bfa0fe760215))
* add rds_apply_immediately variable to control RDS changes ([fc5971e](https://github.com/bigeyedata/terraform-modules/commit/fc5971e02846d253f3dad02d37262c083a623db7))
* add sentry configuration variables ([84a2e1a](https://github.com/bigeyedata/terraform-modules/commit/84a2e1a73a84c1e19cb137da53542d90244054d6))
* add stopTimeout setting on ECS task ([1c5db22](https://github.com/bigeyedata/terraform-modules/commit/1c5db22652912bb182dafd9f1de922c03d4f22be))
* add variable for feature send enabled ([2acacbc](https://github.com/bigeyedata/terraform-modules/commit/2acacbca17961aa68fef8417d51f879e9cb46eb9))
* configure stop_timeout for toretto and dw workers ([8d5c2f0](https://github.com/bigeyedata/terraform-modules/commit/8d5c2f0d619cba3123e323fbd46f4ff0ebe1026e))



# [1.15.0](https://github.com/bigeyedata/terraform-modules/compare/v1.14.0...v1.15.0) (2024-01-31)


### Features

* set mysql transaction isolation to read-committed ([efd1e74](https://github.com/bigeyedata/terraform-modules/commit/efd1e74434281ab4307cbfcef651f2016afdf0ec))



# [1.14.0](https://github.com/bigeyedata/terraform-modules/compare/v1.13.0...v1.14.0) (2024-01-26)


### Bug Fixes

* fixed output for temporal RDS hostname ([736d504](https://github.com/bigeyedata/terraform-modules/commit/736d5043aab77ed11546b776494f8b30d560ebdb))


### Features

* add outputs temporalui_* to replace temporal_admin ([0284d57](https://github.com/bigeyedata/terraform-modules/commit/0284d570446f391d0ca81ded289bcfd5a0295841))
* add validation message for BYO DNS and ACM certificate ([54c31e7](https://github.com/bigeyedata/terraform-modules/commit/54c31e7a58bc639a8aee35e3dd2cd3811f8cc577))
* use RDS dns for app when create_dns_records is false ([ef34b46](https://github.com/bigeyedata/terraform-modules/commit/ef34b46c2f968bd0d9d8c6cd9ab93e2476ad142f))



# [1.13.0](https://github.com/bigeyedata/terraform-modules/compare/v1.12.0...v1.13.0) (2024-01-25)


### Features

* add additional networking resources to module outputs ([ca3feb5](https://github.com/bigeyedata/terraform-modules/commit/ca3feb56396a4c83d131dae6df5c209d4fc793ee))



# [1.12.0](https://github.com/bigeyedata/terraform-modules/compare/v1.11.0...v1.12.0) (2024-01-25)


### Features

* add ability to change temporal db name ([5722963](https://github.com/bigeyedata/terraform-modules/commit/572296317a21e0bd5419faf6aa976cb9d700eae5))



# [1.11.0](https://github.com/bigeyedata/terraform-modules/compare/v1.10.0...v1.11.0) (2024-01-25)


### Bug Fixes

* mark rabbit username as not sensitive ([57f8791](https://github.com/bigeyedata/terraform-modules/commit/57f879118a7fd25fd23ae461ba2c5e2aa751e8ee))


### Features

* add rabbitmq configuration data to bigeye-admin ([9346e23](https://github.com/bigeyedata/terraform-modules/commit/9346e2358cbaa1b64844c8e6e2727338662b5c79))



# [1.10.0](https://github.com/bigeyedata/terraform-modules/compare/v1.9.0...v1.10.0) (2024-01-25)


### Bug Fixes

* add missing tags to temporal resources ([89f514e](https://github.com/bigeyedata/terraform-modules/commit/89f514e462d2c0ae8e0e9d038b67ee49427c2452))
* clean up environment variables ([b20aaf1](https://github.com/bigeyedata/terraform-modules/commit/b20aaf1ab8419069cd1136b1bd70e182e4d50148))
* update datadog parameters for containers ([b4000ba](https://github.com/bigeyedata/terraform-modules/commit/b4000baf8c13eea9520ba2d4b68317453f7050fa))


### Features

* add variable for additional rds tags ([54775ea](https://github.com/bigeyedata/terraform-modules/commit/54775ea4bdede60af67055250a7dfed97ed1cd92))
* plumb through healthcheck config into simple service ([abd5686](https://github.com/bigeyedata/terraform-modules/commit/abd56866f10cfe360fbb6dd7363bc0e3c30b2a93))
* refactor plumbing for elb logs ([a83b51b](https://github.com/bigeyedata/terraform-modules/commit/a83b51bc58936a0a629fee4e49940d8a1d964ccb))
* update web service unhealthy target ([b4b8baf](https://github.com/bigeyedata/terraform-modules/commit/b4b8baf75847e3190691f80dd6d1492050237c8c))



# [1.9.0](https://github.com/bigeyedata/terraform-modules/compare/v1.8.1...v1.9.0) (2024-01-23)


### Features

* add BYO mTLS certs example ([3e207b1](https://github.com/bigeyedata/terraform-modules/commit/3e207b1c1363b72942fdb3d898ba05402e616851))



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
