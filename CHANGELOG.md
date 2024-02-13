# [3.0.0](https://github.com/bigeyedata/terraform-modules/compare/v0.1.0...v3.0.0) (2024-02-13)


### Bug Fixes

* add datadog api key to service container if enabled ([e1061d0](https://github.com/bigeyedata/terraform-modules/commit/e1061d0ddab9db0cd4a00e8fdcb6ec9120a70da6))
* add datawatch_db_name to handle edge case ([af31699](https://github.com/bigeyedata/terraform-modules/commit/af31699b2ee82d21c294a1c6103ad71e9d75de29))
* add depends_on to prevent race condition on initial apply ([18be8eb](https://github.com/bigeyedata/terraform-modules/commit/18be8eb648bcdb09240832096ebf1444bae190a2))
* add environment variables for admin module ([13c9bc0](https://github.com/bigeyedata/terraform-modules/commit/13c9bc0d9e1c7845505ad0bf15d84b8dc2b9d337))
* add missing tags to temporal resources ([bb5adcb](https://github.com/bigeyedata/terraform-modules/commit/bb5adcbe87344481d077ae297ade99480915d2ae))
* add scheduler address to self for localhost calls ([75156bb](https://github.com/bigeyedata/terraform-modules/commit/75156bb55389fd707f534b8bcab922c52e635157))
* align declared container def with deployed ([db946ed](https://github.com/bigeyedata/terraform-modules/commit/db946ed3ddda8bc529f5d8a021f0527fe21aa27c))
* clean up environment variables ([5cf6dfb](https://github.com/bigeyedata/terraform-modules/commit/5cf6dfbe9b7b8c9df9da11d3ed33e5722fb0b637))
* configure iam policy for bigeye-admin ([47ae706](https://github.com/bigeyedata/terraform-modules/commit/47ae7063927bbfa3f6d43574b4759926b4ab2d2a))
* environment variables for bigeye-admin container ([ee37884](https://github.com/bigeyedata/terraform-modules/commit/ee37884cf74b47cf9fc7686693ace4863926b444))
* fixed output for temporal RDS hostname ([4d342be](https://github.com/bigeyedata/terraform-modules/commit/4d342be41388908dcead0ce29304932453151a81))
* grant monocle and toretto IAM access to S3 ([c7f959b](https://github.com/bigeyedata/terraform-modules/commit/c7f959b72600b4a038802da62f4bef93c2b9c5f1))
* healthcheck for temporalui ([f43bb7f](https://github.com/bigeyedata/terraform-modules/commit/f43bb7f64aa8e5ffc55dab95ee36a88927d9101c))
* mark rabbit username as not sensitive ([fb869ae](https://github.com/bigeyedata/terraform-modules/commit/fb869ae4daba0c9d855f2f759cd1681d70bd5018))
* non-sensitive variables should not be marked as sensitive ([91a9561](https://github.com/bigeyedata/terraform-modules/commit/91a9561b2731d8e194731aa89184a210ab30cfee))
* normalize subnet names ([ba4b8c2](https://github.com/bigeyedata/terraform-modules/commit/ba4b8c2e4f8cda65075933ef38aa0b4dc06f0936))
* normalize subnet names ([6642dc5](https://github.com/bigeyedata/terraform-modules/commit/6642dc5bae8eed04425c9f37ae4d7e3d12faa794))
* prevent terraform dependency graph issues for admin module ([3d69736](https://github.com/bigeyedata/terraform-modules/commit/3d69736b15be3a4b5ad8bd32b1b2c495efef14e1))
* rds module should respect `create_security_groups` var ([c0cd615](https://github.com/bigeyedata/terraform-modules/commit/c0cd615c4c2a673ea5c9a6ce7a79aa3436186c01))
* reduce time it takes to mark ECS nodes as healthy ([f46e0f7](https://github.com/bigeyedata/terraform-modules/commit/f46e0f7ac92763a02f6c656e6a3375a13559eb48))
* remove DEMO_ENDPOINT_ENABLED env var ([02fbd69](https://github.com/bigeyedata/terraform-modules/commit/02fbd69e52856dd65372d6448cc1699a1f3a5120))
* remove duplicate default ([6cd1958](https://github.com/bigeyedata/terraform-modules/commit/6cd195861345defab549a28e4736a21e09ffc0e5))
* remove empty string validation on image_registry ([27a9967](https://github.com/bigeyedata/terraform-modules/commit/27a9967927340c370f0a8da504183c2b2cf79b36))
* remove environment vars that can just be injected ([3d3f5a9](https://github.com/bigeyedata/terraform-modules/commit/3d3f5a9e76ed6f155dec7360e7c05956c98ffe33))
* remove redis client sg from services ([bc7b8da](https://github.com/bigeyedata/terraform-modules/commit/bc7b8da8e383990ddb586f6bcb482bd2e5095d59))
* respect create_security_groups variable for services ([e520fa4](https://github.com/bigeyedata/terraform-modules/commit/e520fa44e4daaca4c0d788d07eb2d0be5bbdf7a2))
* respect create_security_groups variable for temporal ([0ae893f](https://github.com/bigeyedata/terraform-modules/commit/0ae893f65bf19744036a3a33ef7e09f9f7b4bda6))
* send correct security groups when `create_security_groups` is false ([3819d66](https://github.com/bigeyedata/terraform-modules/commit/3819d661c3a314c0f9351900b6a4c55228639eca))
* send temporalui logs to temporal log group ([0b037e4](https://github.com/bigeyedata/terraform-modules/commit/0b037e4fc3d9501177a3abfcd4e7b97864223958))
* typo in datadog environment variables ([36f4c30](https://github.com/bigeyedata/terraform-modules/commit/36f4c30c7a5a4af3ddedd6f8ec93738a876127ce))
* update datadog parameters for containers ([2b43aac](https://github.com/bigeyedata/terraform-modules/commit/2b43aaca240214f7cd8b698983b21e3161d31230))
* update deploy so mulitiple deploys run serially ([524f756](https://github.com/bigeyedata/terraform-modules/commit/524f756b64a1c7a70b994f665db91b8feca82935))
* update healthcheck parameters ([974995a](https://github.com/bigeyedata/terraform-modules/commit/974995a436f4c65f9e0eaa6ec0a6aa566909e50f))
* update services to not require db client sg ([92fac85](https://github.com/bigeyedata/terraform-modules/commit/92fac8591ebdf1034a28614576ca495044fe6279))
* update temporal LB SG to allow 443 ([5638b0e](https://github.com/bigeyedata/terraform-modules/commit/5638b0ef1b3fe69e78875a2d674afbe743c2e0f7))
* update web environment variables to respect env ([42963e5](https://github.com/bigeyedata/terraform-modules/commit/42963e5c3f4277b4caa4ae78857d32bc5bee5f4c))
* updated temporal configuration to match other services ([a602b1f](https://github.com/bigeyedata/terraform-modules/commit/a602b1f65304de3ec107bf1ded31ee2be63e2570))
* use `datawatch_rds_db_name` for datawatch JDBC connection string ([05f0619](https://github.com/bigeyedata/terraform-modules/commit/05f0619123f936698adc29a28fb03edffd041ede))
* use bigeye as the default mysql db name for the app db ([cbba645](https://github.com/bigeyedata/terraform-modules/commit/cbba64563548bfc8b048b592ab602063d19f4bf1))
* use vanity_alias for all dns names ([29bfa66](https://github.com/bigeyedata/terraform-modules/commit/29bfa665e5cf1b858fc3d25baf3060071f8eb820))


* feat!: update how RDS/Redis modules manage ingress from services ([f9b9ad6](https://github.com/bigeyedata/terraform-modules/commit/f9b9ad66627925459e2c6507a0098adb7a3ee59c))
* fix!: remove sentry_dsn variable ([3f3e023](https://github.com/bigeyedata/terraform-modules/commit/3f3e023028534b39122047038b5c4c18147f563e))
* fix!: remove deprecated temporal_admin outputs ([9e11d91](https://github.com/bigeyedata/terraform-modules/commit/9e11d91f67df51814b22a3be7da809fa9069722f))
* fix!: remove datadog_agent_api_key variable ([c2b634c](https://github.com/bigeyedata/terraform-modules/commit/c2b634ccd871d65ab7bf7f298689da73451136ae))
* chore!: update AWS provider ([1448308](https://github.com/bigeyedata/terraform-modules/commit/144830847959fd20563b09af3d0c1b7a522eb6d5))
* feat!: add security group to temporal network load balancer ([91e8120](https://github.com/bigeyedata/terraform-modules/commit/91e8120498bb6ea83db2fdd0efeeba2ef0e69842))
* feat!: move temporal load balancer to private by default ([c6bba4c](https://github.com/bigeyedata/terraform-modules/commit/c6bba4c1e12c16f984ec0894384b926d934e9f93))


### Features

* add ability for additional docker labels if using datadog ([6716306](https://github.com/bigeyedata/terraform-modules/commit/671630657daaf3917046088549a7e33818b41385))
* add ability to change temporal db name ([cc26904](https://github.com/bigeyedata/terraform-modules/commit/cc2690468a0fd6669952778399d1ada7942d9a14))
* add additional networking resources to module outputs ([899bded](https://github.com/bigeyedata/terraform-modules/commit/899bded32ad123fcbc8b04af2aaabe5151509b96))
* add an image repository suffix variable ([994a577](https://github.com/bigeyedata/terraform-modules/commit/994a5770c9b31d60a6d84a12f1ccd3d9a37f7d16))
* add BYO mTLS certs example ([4e907ba](https://github.com/bigeyedata/terraform-modules/commit/4e907ba73921a12d7e5a56d039a17ccf97512a7a))
* add datadog AD checks for haproxy ([6323c2f](https://github.com/bigeyedata/terraform-modules/commit/6323c2fc864406e71b15f95d56596cdfb7817717))
* add datawatach_rds_root_user_name to configure db ([02e18bc](https://github.com/bigeyedata/terraform-modules/commit/02e18bc70df2e95b277e246026e42591a8f0047d))
* add flag to control temporal logging ([a926003](https://github.com/bigeyedata/terraform-modules/commit/a926003724ac0e3c97cb9a501a2886456c810880))
* add module for cloudwatch alarms ([ad02cfb](https://github.com/bigeyedata/terraform-modules/commit/ad02cfb2bb1e54a935060076d093bd2a55c68db7))
* add NAT IPs to TF output ([32a28e1](https://github.com/bigeyedata/terraform-modules/commit/32a28e1752d5dc8d7713df0ef7041f35758f9a6f))
* add outputs temporalui_* to replace temporal_admin ([73be63c](https://github.com/bigeyedata/terraform-modules/commit/73be63ca6bc7cbe6f4b8130ffc4d40c9ea7d072d))
* add outputs to bigeye module for databases ([4d4165e](https://github.com/bigeyedata/terraform-modules/commit/4d4165eab9d121fc539b8528a2637333a9a71c74))
* add plumbing for bringing your own security group ids for services ([9c22999](https://github.com/bigeyedata/terraform-modules/commit/9c229992c6d1b587008bc73a637beff2efb90670))
* add rabbitmq configuration data to bigeye-admin ([f13b6cb](https://github.com/bigeyedata/terraform-modules/commit/f13b6cb6f4441bb00eb4fa19047c0cd4e5ebb8d5))
* add rds_apply_immediately variable to control RDS changes ([295f090](https://github.com/bigeyedata/terraform-modules/commit/295f090387bb6c445d74b2a066adc4f12c460ec8))
* add security_group_id as output from simpleservice ([5dade54](https://github.com/bigeyedata/terraform-modules/commit/5dade544670952322b868f25528900985a810954))
* add sentry configuration variables ([80f971a](https://github.com/bigeyedata/terraform-modules/commit/80f971adcbf6f7f3933babea7b831d84b783c151))
* add stopTimeout setting on ECS task ([4cc33f0](https://github.com/bigeyedata/terraform-modules/commit/4cc33f0a9728e9e9898791d48fe5d19f5385e039))
* add troubleshooting client security group to resources ([1dcdc61](https://github.com/bigeyedata/terraform-modules/commit/1dcdc614a99296c06413b8b296ed46fc02b0143e))
* add troubleshooting container instance ([acbbd8b](https://github.com/bigeyedata/terraform-modules/commit/acbbd8b42cc7cdc674d1467e2db811f56e788cf9))
* add validation for ECS task security groups ([c06d4ff](https://github.com/bigeyedata/terraform-modules/commit/c06d4ffc0269ea23eadd3c585b4163b00ff91b94))
* add validation message for BYO DNS and ACM certificate ([f2b4b14](https://github.com/bigeyedata/terraform-modules/commit/f2b4b14d413c9ed6e420ca49a23541b233739b93))
* add validation message for rabbitmq security groups ([999b60d](https://github.com/bigeyedata/terraform-modules/commit/999b60dd36908225a3107bc75b8e4b24ba86f2e7))
* add validation messages for redis and rds security groups ([eda6468](https://github.com/bigeyedata/terraform-modules/commit/eda6468122c59238c377e32d1e87aa9272eb829b))
* add validation rules ([5f56450](https://github.com/bigeyedata/terraform-modules/commit/5f56450f0c6e74d8ae219378954f4f6a3025eae7))
* add validation rules to common variables ([6e818b8](https://github.com/bigeyedata/terraform-modules/commit/6e818b83e262a81c33717fa958871d6ce33bd331))
* add variable for additional rds tags ([adc45c7](https://github.com/bigeyedata/terraform-modules/commit/adc45c7991d2e12b30d47e503e891ca388ada0c8))
* add variable for feature send enabled ([27cab15](https://github.com/bigeyedata/terraform-modules/commit/27cab15124c8965cd2f897af6355e7c5fb22ec73))
* add VPC endpoints for resources required for ECS ([21d484a](https://github.com/bigeyedata/terraform-modules/commit/21d484afb18a897cacebddad4a77863eb5142b09))
* allow separate optional tags for primary vs replica dbs ([a9a5ec5](https://github.com/bigeyedata/terraform-modules/commit/a9a5ec5cf80fe96e53daa6dbb191e2cc7b067ae4))
* allow slack and auth0 secrets to be empty/unset ([0152a79](https://github.com/bigeyedata/terraform-modules/commit/0152a799bd42494b50dd2255da6f8c00a8c4fd9b))
* configure stop_timeout for toretto and dw workers ([31cdf34](https://github.com/bigeyedata/terraform-modules/commit/31cdf34e4db3838d9b101fd1719fd97405436f1e))
* default image_tag to latest and default registry to account ECR ([8d89dd8](https://github.com/bigeyedata/terraform-modules/commit/8d89dd883f55440ee356adf47588b8e7fa4b1f96))
* enable service-specific image tag overrides ([fa8f9f8](https://github.com/bigeyedata/terraform-modules/commit/fa8f9f87a052f2b7ef2381a43df2376ef367a76a))
* plumb through healthcheck config into simple service ([a101a26](https://github.com/bigeyedata/terraform-modules/commit/a101a2621228ddad70fa029fc4b97c09c0f3ec66))
* propagate ECS tags to the task ([daf967d](https://github.com/bigeyedata/terraform-modules/commit/daf967d050ee39b9ae4065f8bdccb7c611a5c6ae))
* refactor plumbing for elb logs ([1caf3e7](https://github.com/bigeyedata/terraform-modules/commit/1caf3e71d781f88ce3f58f4db95987714d49bb29))
* release initial version of bigeye-admin container ([ee1825f](https://github.com/bigeyedata/terraform-modules/commit/ee1825fb48c708c62b51ffc45a04fd446566c9ea))
* set binlog format to ROW ([a2cb774](https://github.com/bigeyedata/terraform-modules/commit/a2cb774f55acc7a48a9eacf42c384d891336d8b6))
* set mysql transaction isolation to read-committed ([d18fb4e](https://github.com/bigeyedata/terraform-modules/commit/d18fb4e25737ace1987b20da410db351b71377c0))
* specify defaulted values in task definition ([7a44553](https://github.com/bigeyedata/terraform-modules/commit/7a44553035c62dc5e344c583707d31bd7f61df23))
* update ECS configuration to log execute commands ([4106249](https://github.com/bigeyedata/terraform-modules/commit/4106249bc8de7b91c7cbbbb3ea84194712253aeb))
* update temporal env vars to latest CLI ([f1d8c02](https://github.com/bigeyedata/terraform-modules/commit/f1d8c02d80312b228b8bd16aba34fa939fd32bc9))
* update temporal env vars to latest CLI ([8bc4dde](https://github.com/bigeyedata/terraform-modules/commit/8bc4dde2dc0d0fa7a0c3f5395ca8b8712bce7af5))
* update web service unhealthy target ([7abe154](https://github.com/bigeyedata/terraform-modules/commit/7abe1540a41a40032959f72d08c89d47f8d7d206))
* use a secret ARN to store DD agent api key ([99175d2](https://github.com/bigeyedata/terraform-modules/commit/99175d2a566be850414569c35ff816891f521ae1))
* use RDS dns for app when create_dns_records is false ([6f3561c](https://github.com/bigeyedata/terraform-modules/commit/6f3561c55ce83bdb82e80f305b832e0d1f8e4158))
* use troubleshooting container in main bigeye module ([d4e5b3e](https://github.com/bigeyedata/terraform-modules/commit/d4e5b3e98e0ab5f618caed604d9310e4760cc440))


### BREAKING CHANGES

* `terraform apply` commands will get stuck trying to
apply a security group rule when that rule already exists. This is
a result of moving from using an `ingress` block inside an
`aws_security_group` resource to a separate resource for the
`aws_vpc_security_group_ingress_rule`. This affects installations
unless you have `create_security_groups = false`.

Recommendation: You may either delete or import the conflicting
security group rule. The RDS security groups and Redis security groups
are affected. These have the names `-datawatch-db`, `-datawatch-db-replica`,
`-temporal-db`, `-temporal-db-replica`, and `-redis-cache`.

Downtime: "Yes" if you delete the security group rule. "No" if you import it.

Steps: To import the security group rule run: `terraform import [ADDR] [id]`.
The ADDR for each of the resources will be
* `module.bigeye.module.datawatch_rds.aws_vpc_security_group_ingress_rule.client_sg[0]`
* `module.bigeye.module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_client_sg[0]`
* `module.bigeye.module.temporal_rds.aws_vpc_security_group_ingress_rule.client_sg[0]`
* `module.bigeye.module.temporal_rds.aws_vpc_security_group_ingress_rule.replica_client_sg[0]`
* `module.bigeye.module.redis.aws_vpc_security_group_ingress_rule.client_sg[0]`

Make sure to wrap the ADDR with quotes, or the shell command will fail. Get the `[id]` for
each of the security groups from the AWS console.
* The `sentry_dsn` variable was removed

Recommendation: Use the `sentry_dsn_secret_arn` variable, passing the
ARN to an AWS SecretsManager secret.

Downtime: No

Steps: Store your Sentry DSN in an AWS SecretsManager secret,
delete the `sentry_dsn` terraform variable, and use the `sentry_dsn_secret_arn`
variable instead.
* Outputs starting with `temporal_admin_` have been
removed.

Recommendation: Use the new outputs starting with `temporalui_`

Downtime: No
* A new variable `datadog_agent_api_key_secret_arn`
should be used instead of `datadog_agent_api_key`

Recommendation: Use an AWS SecretsManager secret to store your API Key
and pass its ARN into `datadog_agent_api_key_secret_arn`.

Downtime: No
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
