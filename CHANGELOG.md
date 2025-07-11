# [21.6.0](https://github.com/bigeyedata/terraform-modules/compare/v21.5.0...v21.6.0) (2025-07-08)


### Features

* add flag to enable additional debugging stats for java services ([e55ab6b](https://github.com/bigeyedata/terraform-modules/commit/e55ab6b62362a8399f9022b6ad775aba18cc4af8))



# [21.5.0](https://github.com/bigeyedata/terraform-modules/compare/v21.4.2...v21.5.0) (2025-07-03)


### Features

* enable EC AZ rebalancing and LB anomaly mitigation by default ([17faf20](https://github.com/bigeyedata/terraform-modules/commit/17faf20e6b84a8375add1c89e0a6795e1060e940))



## [21.4.2](https://github.com/bigeyedata/terraform-modules/compare/v21.4.1...v21.4.2) (2025-06-27)


### Bug Fixes

* use vanity url for static assets when CDN is disabled ([30e2355](https://github.com/bigeyedata/terraform-modules/commit/30e23552b139c7dc1861cf225212728b9156d103))



## [21.4.1](https://github.com/bigeyedata/terraform-modules/compare/v21.4.0...v21.4.1) (2025-06-26)


### Bug Fixes

* add temporalui service to available zone rebalancing flag ([0c71fcc](https://github.com/bigeyedata/terraform-modules/commit/0c71fccd526674b213bd3b531a345438a017dae4)), closes [#545](https://github.com/bigeyedata/terraform-modules/issues/545)



# [21.4.0](https://github.com/bigeyedata/terraform-modules/compare/v21.3.1...v21.4.0) (2025-06-26)


### Features

* allow enabling ECS availability zone rebalancing ([0d23f4b](https://github.com/bigeyedata/terraform-modules/commit/0d23f4b6c13b336d9874c04864e012ac8a5818d1))



## [21.3.1](https://github.com/bigeyedata/terraform-modules/compare/v21.3.0...v21.3.1) (2025-06-24)


### Bug Fixes

* adjust spot instance configs ([285afbf](https://github.com/bigeyedata/terraform-modules/commit/285afbf576d4a0d415ad279a7c9ba1d9d3202f09))



# [21.3.0](https://github.com/bigeyedata/terraform-modules/compare/v21.2.0...v21.3.0) (2025-06-23)


### Features

* allow using fargate spot instances ([73ee389](https://github.com/bigeyedata/terraform-modules/commit/73ee3893df9deda07733ee0758a14a2e1f3e8f03))



# [21.2.0](https://github.com/bigeyedata/terraform-modules/compare/v21.1.0...v21.2.0) (2025-06-17)


### Features

* normalize autoscaling config for api/ui facing services ([bba5e36](https://github.com/bigeyedata/terraform-modules/commit/bba5e364bca21aa51af61cd3e3ce563a79efea4d))



# [21.1.0](https://github.com/bigeyedata/terraform-modules/compare/v21.0.1...v21.1.0) (2025-06-17)


### Features

* add CPU autoscaling for datawatch ([7bd45fd](https://github.com/bigeyedata/terraform-modules/commit/7bd45fd6f88fcc4cd63bea3a3fdbdc566cd16cd9))



## [21.0.1](https://github.com/bigeyedata/terraform-modules/compare/v21.0.0...v21.0.1) (2025-06-17)


### Bug Fixes

* update ALB unhealthy check count for API servers ([5f81f98](https://github.com/bigeyedata/terraform-modules/commit/5f81f982c574698936dd95a8b7d3420c9eef6b5b))



# [21.0.0](https://github.com/bigeyedata/terraform-modules/compare/v20.9.2...v21.0.0) (2025-06-16)


* feat!: allow enabling alb anomaly mitigation ([fc0f90f](https://github.com/bigeyedata/terraform-modules/commit/fc0f90f4665c14cfa249f6a4ab5fdef61c0ab699))


### BREAKING CHANGES

* The aws provider version upgrade is required in
order to control the enable flag for this feature.



## [20.9.2](https://github.com/bigeyedata/terraform-modules/compare/v20.9.1...v20.9.2) (2025-06-02)


### Bug Fixes

* fix monocle cpu validation bug ([10b4615](https://github.com/bigeyedata/terraform-modules/commit/10b461586aaefedd56ac6552d07f3dc0fae54680))



## [20.9.1](https://github.com/bigeyedata/terraform-modules/compare/v20.9.0...v20.9.1) (2025-06-02)


### Bug Fixes

* change monocle default autoscaling algo to cpu scaling ([4779a8f](https://github.com/bigeyedata/terraform-modules/commit/4779a8fe0e493c3f562dfbec819bbf1981fe801b))



# [20.9.0](https://github.com/bigeyedata/terraform-modules/compare/v20.8.1...v20.9.0) (2025-06-02)


### Features

* allow setting monocle worker count ([1c4d1e1](https://github.com/bigeyedata/terraform-modules/commit/1c4d1e1b2b261345359eb3235ec62f21a8579ba9))



## [20.8.1](https://github.com/bigeyedata/terraform-modules/compare/v20.8.0...v20.8.1) (2025-05-30)


### Bug Fixes

* fix missing launch template ebs device name ([e86308b](https://github.com/bigeyedata/terraform-modules/commit/e86308bd4a56f0b763b67a0611093945bdf0cc0c))



# [20.8.0](https://github.com/bigeyedata/terraform-modules/compare/v20.7.1...v20.8.0) (2025-05-30)


### Features

* change default for lineageplus solr log level to warn ([f3d0082](https://github.com/bigeyedata/terraform-modules/commit/f3d00829f809e6ad43e272b04513f522faa6251c))



## [20.7.1](https://github.com/bigeyedata/terraform-modules/compare/v20.7.0...v20.7.1) (2025-05-29)


### Bug Fixes

* update MC username ([079fc06](https://github.com/bigeyedata/terraform-modules/commit/079fc0692577377c05000e4008bc7ebb9337d0cc))
* update MC username ([045f681](https://github.com/bigeyedata/terraform-modules/commit/045f68181ff6b17707b45db85f198b67a0740709))



# [20.7.0](https://github.com/bigeyedata/terraform-modules/compare/v20.6.0...v20.7.0) (2025-05-28)


### Features

* add datawatch lineageplus config ([697da3c](https://github.com/bigeyedata/terraform-modules/commit/697da3c8d3877928177c95be237bf099afe7729f))



# [20.6.0](https://github.com/bigeyedata/terraform-modules/compare/v20.5.1...v20.6.0) (2025-05-14)


### Features

* add temporal queue depth and age to datadog stats ([2174320](https://github.com/bigeyedata/terraform-modules/commit/2174320635e3bf10d9af8175825292f6b758ce66))



## [20.5.1](https://github.com/bigeyedata/terraform-modules/compare/v20.5.0...v20.5.1) (2025-05-14)


### Bug Fixes

* increase internal LB timeout to 900s ([2b29957](https://github.com/bigeyedata/terraform-modules/commit/2b2995703a721b7f484c0cf24f75aecc2e813cab))



# [20.5.0](https://github.com/bigeyedata/terraform-modules/compare/v20.4.0...v20.5.0) (2025-05-06)


### Features

* allow setting solr OS root volume EBS volume size ([bb884ee](https://github.com/bigeyedata/terraform-modules/commit/bb884ee593beb4862f26e6d8a0d73adbb860f637))



# [20.4.0](https://github.com/bigeyedata/terraform-modules/compare/v20.3.0...v20.4.0) (2025-05-05)


### Features

* increase solr os ebs volume size and fix ebs tags ([9cd05e1](https://github.com/bigeyedata/terraform-modules/commit/9cd05e1a04a42c20e1d482016c80ff605288349c))



# [20.3.0](https://github.com/bigeyedata/terraform-modules/compare/v20.2.0...v20.3.0) (2025-05-02)


### Features

* migrate datawatch and web to internal load balancer ([48e3648](https://github.com/bigeyedata/terraform-modules/commit/48e3648d5dc3c040bc287c624994a6a4caaa586c))



# [20.2.0](https://github.com/bigeyedata/terraform-modules/compare/v20.1.0...v20.2.0) (2025-05-01)


### Features

* add flag to disabled unused datadog flags for monocle ([cc27453](https://github.com/bigeyedata/terraform-modules/commit/cc274538046e2944976b0008e6fa689a10af765a))



# [20.1.0](https://github.com/bigeyedata/terraform-modules/compare/v20.0.0...v20.1.0) (2025-04-30)


### Features

* add env var to control routing of Lineage API requests ([7dab936](https://github.com/bigeyedata/terraform-modules/commit/7dab936614acc91c734c878a6b128492f9518cc8))



# [20.0.0](https://github.com/bigeyedata/terraform-modules/compare/v19.0.2...v20.0.0) (2025-04-26)


* feat!: add dedicated lineage api service ([f5dcf46](https://github.com/bigeyedata/terraform-modules/commit/f5dcf4683388579780567c71c3bfa7ce8d1391ea))


### BREAKING CHANGES

* as part of adding a new service, a previous change
to security group rules had to be cleaned up.  No action by installers
is required other than to install and upgrade to the previous major
version first before installing this one.

Note that this PR does not handle routing of API calls, that will
be an app version change (TBD).  This PR only handles installation
of the service.



## [19.0.2](https://github.com/bigeyedata/terraform-modules/compare/v19.0.1...v19.0.2) (2025-04-24)


### Bug Fixes

* update slack action formatting ([7ff7d9c](https://github.com/bigeyedata/terraform-modules/commit/7ff7d9c0abca5e9ee0695f02dbde72e7a5682362))



## [19.0.1](https://github.com/bigeyedata/terraform-modules/compare/v19.0.0...v19.0.1) (2025-04-24)


### Bug Fixes

* fix busted publish GH action ([f6d1206](https://github.com/bigeyedata/terraform-modules/commit/f6d1206155d61fcaae2f96abebca984ab949284a))
* move CD notification to its own job ([81ca585](https://github.com/bigeyedata/terraform-modules/commit/81ca5858315b182cf7096ab475c307ff5c689d52))
* pin sha for all github actions ([72f334a](https://github.com/bigeyedata/terraform-modules/commit/72f334ab9b02fbd3f4c8f1669979cc1ef47e3a9b))



# [19.0.0](https://github.com/bigeyedata/terraform-modules/compare/v18.0.0...v19.0.0) (2025-04-24)


* feat!: migrate off of inline security group rules part 2/2 ([e5203e8](https://github.com/bigeyedata/terraform-modules/commit/e5203e8ab05a160be1a2e90bc02bee6c0480b3d9))


### BREAKING CHANGES

* Part one should only be applied 1x.  Then upgrade
to part 2 and the plan will be idempotent again.



# [18.0.0](https://github.com/bigeyedata/terraform-modules/compare/v17.22.0...v18.0.0) (2025-04-24)


* feat!: migrate off of inline security group rules part 1/2 ([b78a6ba](https://github.com/bigeyedata/terraform-modules/commit/b78a6ba6dcf0aa46d73c7f5906c5627150c80571))


### BREAKING CHANGES

* Part one should only be applied 1x.  Then upgrade
to part 2 and the plan will be idempotent again.



# [17.22.0](https://github.com/bigeyedata/terraform-modules/compare/v17.21.1...v17.22.0) (2025-04-18)


### Features

* add flag to control TEMPORAL_LARGE_PAYLOAD_ENABLED env var ([6a7b39a](https://github.com/bigeyedata/terraform-modules/commit/6a7b39a6e62623b603476240afe406a2eb85ec9b))



## [17.21.1](https://github.com/bigeyedata/terraform-modules/compare/v17.21.0...v17.21.1) (2025-04-17)


### Bug Fixes

* ec2 ecs mem (solr) increments based on cpu size ([0fe24a8](https://github.com/bigeyedata/terraform-modules/commit/0fe24a8cf1cc1845e1e03b451f2147e852e9e20c))



# [17.21.0](https://github.com/bigeyedata/terraform-modules/compare/v17.20.1...v17.21.0) (2025-04-16)


### Features

* allow using a centralized internal LB ([d5e2777](https://github.com/bigeyedata/terraform-modules/commit/d5e277714e6c96f86e0d6f23f2d5946275a66d42))



## [17.20.1](https://github.com/bigeyedata/terraform-modules/compare/v17.20.0...v17.20.1) (2025-04-15)


### Bug Fixes

* remove publish bundle step from CI deploy ([9711ee6](https://github.com/bigeyedata/terraform-modules/commit/9711ee6693abcaf6f3a2bc0be2b34108e644b587))



# [17.20.0](https://github.com/bigeyedata/terraform-modules/compare/v17.19.0...v17.20.0) (2025-04-15)


### Features

* add a dedicated general purpose internal load balancer ([3acd5c7](https://github.com/bigeyedata/terraform-modules/commit/3acd5c72343250d7949202a2a681850f74fc8fc9))



# [17.19.0](https://github.com/bigeyedata/terraform-modules/compare/v17.18.0...v17.19.0) (2025-04-08)


### Features

* reduce temporal database default backup retention period ([eb98f09](https://github.com/bigeyedata/terraform-modules/commit/eb98f093eb82dc0605246f79c8b79407242f7657))



# [17.18.0](https://github.com/bigeyedata/terraform-modules/compare/v17.17.2...v17.18.0) (2025-04-04)


### Features

* copy RDS instance tags to snapshots ([b06d9e1](https://github.com/bigeyedata/terraform-modules/commit/b06d9e1bf466f17846f242d61e07312f7d03d88f))



## [17.17.2](https://github.com/bigeyedata/terraform-modules/compare/v17.17.1...v17.17.2) (2025-03-24)


### Bug Fixes

* pin solr CPU reservation for primary container ([9fbcde2](https://github.com/bigeyedata/terraform-modules/commit/9fbcde2926f116c60ae068f7759047990ed73f39))



## [17.17.1](https://github.com/bigeyedata/terraform-modules/compare/v17.17.0...v17.17.1) (2025-03-24)


### Bug Fixes

* use a flat value for OS overhead for solr mem calculation ([b84fd53](https://github.com/bigeyedata/terraform-modules/commit/b84fd530536c54d2b0a337ad1707fc7936ef638c))



# [17.17.0](https://github.com/bigeyedata/terraform-modules/compare/v17.16.0...v17.17.0) (2025-03-24)


### Features

* create a swap file on solr container instance ([#471](https://github.com/bigeyedata/terraform-modules/issues/471)) ([bb78e7f](https://github.com/bigeyedata/terraform-modules/commit/bb78e7f945d4f53775cf5c29bf86cc2724a3e1e6))



# [17.16.0](https://github.com/bigeyedata/terraform-modules/compare/v17.15.2...v17.16.0) (2025-03-24)


### Features

* install CloudWatch agent on solr container instance ([#468](https://github.com/bigeyedata/terraform-modules/issues/468)) ([565b49e](https://github.com/bigeyedata/terraform-modules/commit/565b49e1ed967261c51de111fc76f19b21c70fab))



## [17.15.2](https://github.com/bigeyedata/terraform-modules/compare/v17.15.1...v17.15.2) (2025-03-24)


### Bug Fixes

* disable firelens console logs ([f2d52ec](https://github.com/bigeyedata/terraform-modules/commit/f2d52ece23508b83f2330101cf1ace387d6036c9))



## [17.15.1](https://github.com/bigeyedata/terraform-modules/compare/v17.15.0...v17.15.1) (2025-03-22)


### Bug Fixes

* calculate solr heap size based on container mem ([59b4a2c](https://github.com/bigeyedata/terraform-modules/commit/59b4a2ce132509c3131735b30ad3a17d3fb9ef97))



# [17.15.0](https://github.com/bigeyedata/terraform-modules/compare/v17.14.0...v17.15.0) (2025-03-21)


### Features

* make refresh_instance_on_launch_template_change configurable ([#464](https://github.com/bigeyedata/terraform-modules/issues/464)) ([2ab1e26](https://github.com/bigeyedata/terraform-modules/commit/2ab1e262775341e92ecaa4648d9a741212040d56))



# [17.14.0](https://github.com/bigeyedata/terraform-modules/compare/v17.13.1...v17.14.0) (2025-03-21)


### Features

* send solr logs to sumo and jmx stats to datadog ([938fc4c](https://github.com/bigeyedata/terraform-modules/commit/938fc4cc0d60be9ab552001baa91aa68e4b45edd))



## [17.13.1](https://github.com/bigeyedata/terraform-modules/compare/v17.13.0...v17.13.1) (2025-03-21)


### Bug Fixes

* normalize tags for solr service ([604b7cf](https://github.com/bigeyedata/terraform-modules/commit/604b7cf7e3455da22b7ac73bfbd14023118cff1f))



# [17.13.0](https://github.com/bigeyedata/terraform-modules/compare/v17.12.3...v17.13.0) (2025-03-20)


### Features

* add optional CNAME records for solr service ([#458](https://github.com/bigeyedata/terraform-modules/issues/458)) ([4471b71](https://github.com/bigeyedata/terraform-modules/commit/4471b71c692570d410585195ee782bccd5d2cc8c))



## [17.12.3](https://github.com/bigeyedata/terraform-modules/compare/v17.12.2...v17.12.3) (2025-03-20)


### Bug Fixes

* cloudfront logging_config when logging bucket is not specified ([#456](https://github.com/bigeyedata/terraform-modules/issues/456)) ([ba31bed](https://github.com/bigeyedata/terraform-modules/commit/ba31bed33a1318c3740d513c941f6fd3b42d5f88))



## [17.12.2](https://github.com/bigeyedata/terraform-modules/compare/v17.12.1...v17.12.2) (2025-03-20)


### Bug Fixes

* revert "feat: use for_each instead of count for security group rules" ([#454](https://github.com/bigeyedata/terraform-modules/issues/454)) ([2558475](https://github.com/bigeyedata/terraform-modules/commit/2558475cffab1fd40fe4081802fb8fab9e92a7c8))



## [17.12.1](https://github.com/bigeyedata/terraform-modules/compare/v17.12.0...v17.12.1) (2025-03-19)


### Bug Fixes

* fix missing tags for ECS solr instance ([e72e223](https://github.com/bigeyedata/terraform-modules/commit/e72e2236d4e67d0565991e0a7defd0a2dbc9eb19))



# [17.12.0](https://github.com/bigeyedata/terraform-modules/compare/v17.11.1...v17.12.0) (2025-03-13)


### Features

* add output for temporal_rds_password_secret_arn ([#448](https://github.com/bigeyedata/terraform-modules/issues/448)) ([540bda9](https://github.com/bigeyedata/terraform-modules/commit/540bda9e9aa9f5d1c246a1e403c30e70ae3e9bfc))



## [17.11.1](https://github.com/bigeyedata/terraform-modules/compare/v17.11.0...v17.11.1) (2025-03-11)


### Bug Fixes

* preserve aws_security_group.db_replica_clients resource ([#446](https://github.com/bigeyedata/terraform-modules/issues/446)) ([a2b631a](https://github.com/bigeyedata/terraform-modules/commit/a2b631abfaae05cf194bcb8f203113fb032f5232))



# [17.11.0](https://github.com/bigeyedata/terraform-modules/compare/v17.10.0...v17.11.0) (2025-03-10)


### Features

* use for_each instead of count for security group rules ([4c73c35](https://github.com/bigeyedata/terraform-modules/commit/4c73c3552dc922bbd97f0bca7724651235289a38))



# [17.10.0](https://github.com/bigeyedata/terraform-modules/compare/v17.9.3...v17.10.0) (2025-02-27)


### Features

* add variables for solr EBS volume configuration ([d271e92](https://github.com/bigeyedata/terraform-modules/commit/d271e92a8a2b516f48cab600dda3ccfaae03f9a3))



## [17.9.3](https://github.com/bigeyedata/terraform-modules/compare/v17.9.2...v17.9.3) (2025-02-26)


### Bug Fixes

* allow OPTIONS calls for Cloudfront ([77a65c4](https://github.com/bigeyedata/terraform-modules/commit/77a65c4115e8fddcb2fd20c3a14ca9dea2feab64))



## [17.9.2](https://github.com/bigeyedata/terraform-modules/compare/v17.9.1...v17.9.2) (2025-02-25)


### Bug Fixes

* update CORS response headers for Cloudfront ([76ecc45](https://github.com/bigeyedata/terraform-modules/commit/76ecc45f0755aa5179e07b7b852d7cd1d40e36e7))



## [17.9.1](https://github.com/bigeyedata/terraform-modules/compare/v17.9.0...v17.9.1) (2025-02-23)


### Bug Fixes

* add https:// prefix to static asset root ([e642952](https://github.com/bigeyedata/terraform-modules/commit/e64295217fc51ac4da5a605e8b63468c96cfd653))



# [17.9.0](https://github.com/bigeyedata/terraform-modules/compare/v17.8.1...v17.9.0) (2025-02-22)


### Features

* make solr heap configurable via variable ([#434](https://github.com/bigeyedata/terraform-modules/issues/434)) ([389b40c](https://github.com/bigeyedata/terraform-modules/commit/389b40c6c343c612a80692cd19b4698f27c0a6e9))



## [17.8.1](https://github.com/bigeyedata/terraform-modules/compare/v17.8.0...v17.8.1) (2025-02-21)


### Bug Fixes

* update dns to only route static assets to cloudfront ([#425](https://github.com/bigeyedata/terraform-modules/issues/425)) ([26140aa](https://github.com/bigeyedata/terraform-modules/commit/26140aa5bc66715e0f46890955d56969f60a85bd))



# [17.8.0](https://github.com/bigeyedata/terraform-modules/compare/v17.7.1...v17.8.0) (2025-02-21)


### Features

* add new lineageplus_solr variables ([#426](https://github.com/bigeyedata/terraform-modules/issues/426)) ([8022069](https://github.com/bigeyedata/terraform-modules/commit/8022069868267ca280483f56aeea1675ee542074))



## [17.7.1](https://github.com/bigeyedata/terraform-modules/compare/v17.7.0...v17.7.1) (2025-02-21)


### Reverts

* Revert "feat: add DD_TRACE_128_BIT_TRACEID_LOGGING_ENABLED env var (#422)" ([1201115](https://github.com/bigeyedata/terraform-modules/commit/1201115ed792af7d3d88283268e57c580ec99c0a)), closes [#422](https://github.com/bigeyedata/terraform-modules/issues/422)



# [17.7.0](https://github.com/bigeyedata/terraform-modules/compare/v17.6.0...v17.7.0) (2025-02-21)


### Features

* update default rabbitmq and mysql versions ([73bba8f](https://github.com/bigeyedata/terraform-modules/commit/73bba8f1b8fb2f1689a45d98f841613e2b076534))



# [17.6.0](https://github.com/bigeyedata/terraform-modules/compare/v17.5.0...v17.6.0) (2025-02-14)


### Features

* add DD_TRACE_128_BIT_TRACEID_LOGGING_ENABLED env var ([#422](https://github.com/bigeyedata/terraform-modules/issues/422)) ([74740dd](https://github.com/bigeyedata/terraform-modules/commit/74740ddef7caca52deb0b844031fc71b8ae2a9db))



# [17.5.0](https://github.com/bigeyedata/terraform-modules/compare/v17.4.1...v17.5.0) (2025-02-13)


### Features

* improve Cloudfront caching strategy ([84e6ed9](https://github.com/bigeyedata/terraform-modules/commit/84e6ed9a4f2d0a5d9055e427c9da59097f48a903))



## [17.4.1](https://github.com/bigeyedata/terraform-modules/compare/v17.4.0...v17.4.1) (2025-02-11)


### Bug Fixes

* make var.lineageplus_solr_image_tag optional ([#418](https://github.com/bigeyedata/terraform-modules/issues/418)) ([0780252](https://github.com/bigeyedata/terraform-modules/commit/0780252249e1af00662ba855ef226329fd3f2543))



# [17.4.0](https://github.com/bigeyedata/terraform-modules/compare/v17.3.0...v17.4.0) (2025-02-08)


### Features

* bake static configs inside the image ([#412](https://github.com/bigeyedata/terraform-modules/issues/412)) ([9d0de18](https://github.com/bigeyedata/terraform-modules/commit/9d0de1855112f4e3d61ad289c9516c529ece7831))



# [17.3.0](https://github.com/bigeyedata/terraform-modules/compare/v17.2.1...v17.3.0) (2025-02-07)


### Features

* add option to use Cloudfront in front of the app ([e139d85](https://github.com/bigeyedata/terraform-modules/commit/e139d85ef9d46baa7ef210fc44e02645cadd45c6))



## [17.2.1](https://github.com/bigeyedata/terraform-modules/compare/v17.2.0...v17.2.1) (2025-02-07)


### Bug Fixes

* add byovpc support for aws_service_discovery_private_dns_namespace ([#414](https://github.com/bigeyedata/terraform-modules/issues/414)) ([496edab](https://github.com/bigeyedata/terraform-modules/commit/496edab19c453fb8723c9d7b094dd4cc7febab19))



# [17.2.0](https://github.com/bigeyedata/terraform-modules/compare/v17.1.4...v17.2.0) (2025-02-03)


### Features

* add tf module for Apache solr on ECS ([#410](https://github.com/bigeyedata/terraform-modules/issues/410)) ([a6ffc9a](https://github.com/bigeyedata/terraform-modules/commit/a6ffc9a84b42df35fa0ca3d900cf9e552a3b7d71))



## [17.1.4](https://github.com/bigeyedata/terraform-modules/compare/v17.1.3...v17.1.4) (2025-01-23)


### Bug Fixes

* update default temporal wf and exec counts to final values ([26f9129](https://github.com/bigeyedata/terraform-modules/commit/26f912964d598118e2b9557a0022a3761360204c))



## [17.1.3](https://github.com/bigeyedata/terraform-modules/compare/v17.1.2...v17.1.3) (2025-01-22)


### Bug Fixes

* increase parallism for trigger-batch-metric-run activity queue ([35d53d7](https://github.com/bigeyedata/terraform-modules/commit/35d53d72947db557a44aa6522643ea77a13a3ffa))



## [17.1.2](https://github.com/bigeyedata/terraform-modules/compare/v17.1.1...v17.1.2) (2025-01-22)


### Bug Fixes

* update default temporal client parallelism settings ([d3be719](https://github.com/bigeyedata/terraform-modules/commit/d3be719cec4442cd0a90dd9c1a2ae0e56e0bef8d))



## [17.1.1](https://github.com/bigeyedata/terraform-modules/compare/v17.1.0...v17.1.1) (2025-01-21)


### Bug Fixes

* disable worker service mem util alarms ([d0f4a2d](https://github.com/bigeyedata/terraform-modules/commit/d0f4a2d8005ac729a10f2d04afcfc37b55db7c02))



# [17.1.0](https://github.com/bigeyedata/terraform-modules/compare/v17.0.0...v17.1.0) (2025-01-17)


### Features

* enable datawatch_request_body_logging_enabled everywhere ([24d0b7f](https://github.com/bigeyedata/terraform-modules/commit/24d0b7f0b6886bbffca78a0736ce65e3741ba285))



# [17.0.0](https://github.com/bigeyedata/terraform-modules/compare/v16.6.0...v17.0.0) (2025-01-17)


* fix!: increase minimum hashicorp/aws version to 5.68.0 ([3649e74](https://github.com/bigeyedata/terraform-modules/commit/3649e743cf9a7e24bffa12f12eca325154731baa))


### BREAKING CHANGES

* If your installhas the "hashicorp/aws" provider version pinned to
something lower than 5.68.0, increase the version to at least 5.68.0
and run `terraform init -upgrade`.



# [16.6.0](https://github.com/bigeyedata/terraform-modules/compare/v16.5.0...v16.6.0) (2025-01-16)


### Features

* enable auto minor version upgrade for rabbitmq ([b53735f](https://github.com/bigeyedata/terraform-modules/commit/b53735f30e54c6bbd2b155a46845ed737a3eca3c))



# [16.5.0](https://github.com/bigeyedata/terraform-modules/compare/v16.4.1...v16.5.0) (2025-01-14)


### Features

* allow control of temporal parallelism remaining queues ([faee33d](https://github.com/bigeyedata/terraform-modules/commit/faee33d4d45f18161c683a2b1e95a1391e14e515))



## [16.4.1](https://github.com/bigeyedata/terraform-modules/compare/v16.4.0...v16.4.1) (2025-01-14)


### Bug Fixes

* shorten name of rootcausework to rootcause ([f7d4732](https://github.com/bigeyedata/terraform-modules/commit/f7d47327d7350b88ab7727141d60299fd72dc940))



# [16.4.0](https://github.com/bigeyedata/terraform-modules/compare/v16.3.0...v16.4.0) (2025-01-13)


### Features

* add dedicated ECS service for issue-root-cause ([55558fb](https://github.com/bigeyedata/terraform-modules/commit/55558fbb008fab85d0e91f52b4995c121e54c2e0))



# [16.3.0](https://github.com/bigeyedata/terraform-modules/compare/v16.2.0...v16.3.0) (2025-01-10)


### Features

* allow control of temporal parallelism on datawork service ([bb4d33b](https://github.com/bigeyedata/terraform-modules/commit/bb4d33b68b2bbec778de166c401f5bf498af641c))



# [16.2.0](https://github.com/bigeyedata/terraform-modules/compare/v16.1.0...v16.2.0) (2025-01-08)


### Features

* allow setting issue-root-cause temporal client settings ([dd60754](https://github.com/bigeyedata/terraform-modules/commit/dd60754cf57df8b9b6fcc653cf66291612cbede1))



# [16.1.0](https://github.com/bigeyedata/terraform-modules/compare/v16.0.0...v16.1.0) (2025-01-07)


### Features

* set lineagework instance count to 1 ([5d738a0](https://github.com/bigeyedata/terraform-modules/commit/5d738a087cde2572bb0c323a2671e5d434f0f3eb))



# [16.0.0](https://github.com/bigeyedata/terraform-modules/compare/v15.0.0...v16.0.0) (2024-12-10)


* fix!: remove autoscaling from backfillwork ([bc89cfb](https://github.com/bigeyedata/terraform-modules/commit/bc89cfb50c7a23a7a2279e4babd461a74bd388b6))


### BREAKING CHANGES

* - var.backfillwork_autoscaling_max_count has been removed



# [15.0.0](https://github.com/bigeyedata/terraform-modules/compare/v14.1.0...v15.0.0) (2024-12-06)


* feat!: allow specifying autoscaling algo for internalapi and monocle (#380) ([ec95813](https://github.com/bigeyedata/terraform-modules/commit/ec95813bc3b37268026cee86dc6b5d4d5bd77ade)), closes [#380](https://github.com/bigeyedata/terraform-modules/issues/380)


### BREAKING CHANGES

* The following vars have been removed:
- var.indexwork_autoscaling_enabled
- var.internalapi_autoscaling_cpu_enabled
- var.internalapi_autoscaling_cpu_target
- var.monocle_autoscaling_enabled
- var.monocle_max_count
- var.monocle_autoscaling_request_count_target

The following vars have been added:
- var.internalapi_autoscaling_config
- var.monocle_autoscaling_config



# [14.1.0](https://github.com/bigeyedata/terraform-modules/compare/v14.0.0...v14.1.0) (2024-11-20)


### Features

* make indexwork autoscaling configurable via variable ([#377](https://github.com/bigeyedata/terraform-modules/issues/377)) ([1cc3f34](https://github.com/bigeyedata/terraform-modules/commit/1cc3f349248fabfa37444b7e11b901d893b406ca))



# [14.0.0](https://github.com/bigeyedata/terraform-modules/compare/v13.0.0...v14.0.0) (2024-11-14)


* fix!: disable autoscaling for indexwork service ([8e53564](https://github.com/bigeyedata/terraform-modules/commit/8e5356422a05fdd67621b7f78886cd624df3b9ff))


### BREAKING CHANGES

* The following variable has been removed

- indexwork_autoscaling_max_count



# [13.0.0](https://github.com/bigeyedata/terraform-modules/compare/v12.7.2...v13.0.0) (2024-11-12)


* feat!: roll out lineage and catalog indexing queue migrations ([08c3e3f](https://github.com/bigeyedata/terraform-modules/commit/08c3e3f98fa69f39c45f58e230d7c024ac7c079f))


### BREAKING CHANGES

* The following bigeye module variables have been removed:
- migrate_lineage_mq_queue_enabled
- migrate_catalog_indexing_mq_queue_enabled

Remove these from your configuration before upgrading to this version
of the Bigeye terraform module.  If these have not been set
before, no action is required.



## [12.7.2](https://github.com/bigeyedata/terraform-modules/compare/v12.7.1...v12.7.2) (2024-11-12)


### Bug Fixes

* update autoscaling for services scaling on multiple queues ([2728086](https://github.com/bigeyedata/terraform-modules/commit/272808681c6e22b075ad913b1c05d9c13e9b56b8))



## [12.7.1](https://github.com/bigeyedata/terraform-modules/compare/v12.7.0...v12.7.1) (2024-11-11)


### Bug Fixes

* fix security group id order ([#368](https://github.com/bigeyedata/terraform-modules/issues/368)) ([4855f8f](https://github.com/bigeyedata/terraform-modules/commit/4855f8f8699210b159777df9a7459aa7e4038dd3))



# [12.7.0](https://github.com/bigeyedata/terraform-modules/compare/v12.6.0...v12.7.0) (2024-11-11)


### Features

* add backfillwork service ([#366](https://github.com/bigeyedata/terraform-modules/issues/366)) ([7575f92](https://github.com/bigeyedata/terraform-modules/commit/7575f92a10494fa801e430a377cab3f195d9d990))



# [12.6.0](https://github.com/bigeyedata/terraform-modules/compare/v12.5.0...v12.6.0) (2024-11-11)


### Features

* add flag to migrate lineage MQ work to lineagework ([5e5ed7f](https://github.com/bigeyedata/terraform-modules/commit/5e5ed7fb852e5aea703f1fd0093f70680a7dfd6d))



# [12.5.0](https://github.com/bigeyedata/terraform-modules/compare/v12.4.0...v12.5.0) (2024-11-08)


### Features

* add env var to control request size for datawatch ([#363](https://github.com/bigeyedata/terraform-modules/issues/363)) ([17edd39](https://github.com/bigeyedata/terraform-modules/commit/17edd39000040f485d0d4e04cdfa87d314c5e022))



# [12.4.0](https://github.com/bigeyedata/terraform-modules/compare/v12.3.0...v12.4.0) (2024-11-05)


### Features

* disable lineagework service by default ([474f20a](https://github.com/bigeyedata/terraform-modules/commit/474f20aeee343f52857dff5f1abc4a23defc9b43))



# [12.3.0](https://github.com/bigeyedata/terraform-modules/compare/v12.2.0...v12.3.0) (2024-11-05)


### Features

* increase datawatch default cpu ([901c893](https://github.com/bigeyedata/terraform-modules/commit/901c8938113955ee6512dbe429ccd60e2a29e7c9))
* scale indexwork in faster ([8e0efaf](https://github.com/bigeyedata/terraform-modules/commit/8e0efaf1be646d5274d26cbea6891a144bf2e3be))



# [12.2.0](https://github.com/bigeyedata/terraform-modules/compare/v12.0.1...v12.2.0) (2024-11-04)


### Features

* add flag to migrate lineage MQ work to lineagework ([9b1f468](https://github.com/bigeyedata/terraform-modules/commit/9b1f468f58b105f8cad57a7101fd1675e7e0805e))



# [12.1.0](https://github.com/bigeyedata/terraform-modules/compare/v12.0.0...v12.1.0) (2024-11-04)


### Bug Fixes

* update queue membership for MQ based metric runs ([2973e4a](https://github.com/bigeyedata/terraform-modules/commit/2973e4a0777d83682e33495a8d83786fffa34866))


### Features

* add flag to migrate lineage MQ work to lineagework ([9b1f468](https://github.com/bigeyedata/terraform-modules/commit/9b1f468f58b105f8cad57a7101fd1675e7e0805e))


## [12.0.1](https://github.com/bigeyedata/terraform-modules/compare/v12.0.0...v12.0.1) (2024-11-04)


### Bug Fixes

* update queue membership for MQ based metric runs ([2973e4a](https://github.com/bigeyedata/terraform-modules/commit/2973e4a0777d83682e33495a8d83786fffa34866))


# [12.0.0](https://github.com/bigeyedata/terraform-modules/compare/v11.7.0...v12.0.0) (2024-11-01)


* feat!: rollout indexwork service ([04d8624](https://github.com/bigeyedata/terraform-modules/commit/04d8624ae75b06a6670168359af1f0e3b12caf00))


### BREAKING CHANGES

* The following feature flags will need to be removed
from your config if you are using them:

- indexwork_enabled
- indexwork_autoscaling_enabled



# [11.7.0](https://github.com/bigeyedata/terraform-modules/compare/v11.6.0...v11.7.0) (2024-11-01)


### Features

* reduce default indexwork instance count ([06ae1be](https://github.com/bigeyedata/terraform-modules/commit/06ae1be854da854c867fc72536de460deaef2b7a))



# [11.6.0](https://github.com/bigeyedata/terraform-modules/compare/v11.5.1...v11.6.0) (2024-10-31)


### Bug Fixes

* reduce indexwork autoscaling to 1 step ([e6821b9](https://github.com/bigeyedata/terraform-modules/commit/e6821b98d887dc59b0ff580f43154e35005b9dd1))


### Features

* autoscale indexwork service ([764df5e](https://github.com/bigeyedata/terraform-modules/commit/764df5e5180cce676afa9cd2cb23c762dfed3ff0))



## [11.5.1](https://github.com/bigeyedata/terraform-modules/compare/v11.5.0...v11.5.1) (2024-10-30)


### Bug Fixes

* remove metricwork MQ workers ([ec304db](https://github.com/bigeyedata/terraform-modules/commit/ec304db9be4744d602a9c3847f965f093c0f064d))



# [11.5.0](https://github.com/bigeyedata/terraform-modules/compare/v11.4.0...v11.5.0) (2024-10-29)


### Features

* add indexwork service ([36d347d](https://github.com/bigeyedata/terraform-modules/commit/36d347d92b049881bcf75460acd11eaf08193373))



# [11.4.0](https://github.com/bigeyedata/terraform-modules/compare/v11.3.1...v11.4.0) (2024-10-23)


### Features

* use an include queue list instead of exclude queue ([2e4d98e](https://github.com/bigeyedata/terraform-modules/commit/2e4d98e78dfa193e2ea093b964f38e93a1ab62ee))



## [11.3.1](https://github.com/bigeyedata/terraform-modules/compare/v11.3.0...v11.3.1) (2024-10-09)


### Bug Fixes

* exclude issue-root-cause from lineagework service ([fb22038](https://github.com/bigeyedata/terraform-modules/commit/fb22038141e2c80375cf139b163b0bbd7f32d911))



# [11.3.0](https://github.com/bigeyedata/terraform-modules/compare/v11.2.0...v11.3.0) (2024-09-10)


### Features

* add enable flag for logging class load/unload messages ([a00ad19](https://github.com/bigeyedata/terraform-modules/commit/a00ad19d02d0f76cd6caf16fd64f5bc61fd9ba2d))



# [11.2.0](https://github.com/bigeyedata/terraform-modules/compare/v11.1.1...v11.2.0) (2024-09-06)


### Features

* add a feature flag to control a memory leak fix ([bb986af](https://github.com/bigeyedata/terraform-modules/commit/bb986af99cea60d5f1958aaf4ecabee468dcee99))



## [11.1.1](https://github.com/bigeyedata/terraform-modules/compare/v11.1.0...v11.1.1) (2024-09-06)


### Bug Fixes

* reduce datawatch and derivative service max JVM ram percent ([c2c266c](https://github.com/bigeyedata/terraform-modules/commit/c2c266c5b27b534539295146ee19e35a544bd406))



# [11.1.0](https://github.com/bigeyedata/terraform-modules/compare/v11.0.0...v11.1.0) (2024-09-06)


### Features

* allow setting JVM MaxRAMPercentage for each service ([71eec8b](https://github.com/bigeyedata/terraform-modules/commit/71eec8b51a9b0b9e63a83ef53bf6964edb6d3c4c))



# [11.0.0](https://github.com/bigeyedata/terraform-modules/compare/v10.4.2...v11.0.0) (2024-09-04)


* feat!: remove support for mTLS connections from Datawatch ([2ffe314](https://github.com/bigeyedata/terraform-modules/commit/2ffe314b30f8e7a7bd3b5d9e36191a881d09a194))


### BREAKING CHANGES

* Two environment variables `MTLS_KEY_PATH` and
`MTLS_CERT_PATH` were removed from Datawatch.

Recommendation: Ensure you are using application version `1.57.0`
or higher.

Downtime: No

Steps: None



## [10.4.2](https://github.com/bigeyedata/terraform-modules/compare/v10.4.1...v10.4.2) (2024-08-29)


### Bug Fixes

* reduce default max metric run workflow slots to 5 ([5e9bd84](https://github.com/bigeyedata/terraform-modules/commit/5e9bd8491d45012a7b2cb3db1aba160d7a07a4ab))



## [10.4.1](https://github.com/bigeyedata/terraform-modules/compare/v10.4.0...v10.4.1) (2024-08-20)


### Bug Fixes

* reduce default mc lineage workflow task pollers ([d482ffa](https://github.com/bigeyedata/terraform-modules/commit/d482ffa325f1a523bfe06d0d0ef9fb3f7488961e))



# [10.4.0](https://github.com/bigeyedata/terraform-modules/compare/v10.3.0...v10.4.0) (2024-08-12)


### Features

* change autothreshold S3 file expiration to 45 days ([3caaa3d](https://github.com/bigeyedata/terraform-modules/commit/3caaa3db30536a156f4da3767425f663cbba0bd2))



# [10.3.0](https://github.com/bigeyedata/terraform-modules/compare/v10.2.0...v10.3.0) (2024-08-08)


### Features

* new Temporal task queue monocle-invalidation ([705af1e](https://github.com/bigeyedata/terraform-modules/commit/705af1eeb68f4a24d08f39303758df8822e9437b)), closes [#14885](https://github.com/bigeyedata/terraform-modules/issues/14885)



# [10.2.0](https://github.com/bigeyedata/terraform-modules/compare/v10.1.2...v10.2.0) (2024-08-01)


### Features

* add ability to use hosted zone apex as top level domain ([07f3257](https://github.com/bigeyedata/terraform-modules/commit/07f32575f84901c701ee89e6fbb3b7bed3843b9d))



## [10.1.2](https://github.com/bigeyedata/terraform-modules/compare/v10.1.1...v10.1.2) (2024-07-31)


### Bug Fixes

* reduce default value for reconciliation workflow workers ([b76da3f](https://github.com/bigeyedata/terraform-modules/commit/b76da3f1a77915f0deddcefde287d810e58a70a8))



## [10.1.1](https://github.com/bigeyedata/terraform-modules/compare/v10.1.0...v10.1.1) (2024-07-26)


### Bug Fixes

* reduce default value for scorecard refresh parallelism ([9903119](https://github.com/bigeyedata/terraform-modules/commit/9903119bdb2aadfa304d9e83b89a1516f965b952))



# [10.1.0](https://github.com/bigeyedata/terraform-modules/compare/v10.0.0...v10.1.0) (2024-07-25)


### Features

* add env vars to control job executor parallelism ([2137cc9](https://github.com/bigeyedata/terraform-modules/commit/2137cc9d7bf3b86f2e799add1d76c8b45a205cbf))



# [10.0.0](https://github.com/bigeyedata/terraform-modules/compare/v9.2.0...v10.0.0) (2024-07-22)


### Bug Fixes

* rename papi service to internalapi ([fc65441](https://github.com/bigeyedata/terraform-modules/commit/fc65441de68752f5d49a4ec36a54a766fd655337))


### BREAKING CHANGES

#### Variable rename
* All variables with papi in the name need to
be globally replaced with internalapi.

#### Steps
1. Run the following commands to remove the papi security group from the redis and RDS security groups
> terraform destroy --target 'module.bigeye.module.redis.aws_vpc_security_group_ingress_rule.other_sgs[5]'
>
> terraform destroy --target 'module.bigeye.module.datawatch_rds.aws_vpc_security_group_ingress_rule.other_sgs[4]'
>
> terraform destroy --target 'module.bigeye.module.datawatch_rds.aws_vpc_security_group_ingress_rule.replica_other_sgs[4]'
2. Rename variables in main.tf referencing papi (search and replace `papi` with `internalapi`)
3. Change the module version of the bigeye module to v10.0.0
4. terraform init && terraform apply
5. If you are using the alarms module, now change the version of the alarms module to v10.0.0
6. terraform init && terraform apply
7. Done!


# [9.2.0](https://github.com/bigeyedata/terraform-modules/compare/v9.1.0...v9.2.0) (2024-07-18)


### Features

* add robot agent api key secret ([c4abb90](https://github.com/bigeyedata/terraform-modules/commit/c4abb901b5a30d31926bfcf2b233d3da55957df8))
* update temporal defaults to use apikey auth ([063db42](https://github.com/bigeyedata/terraform-modules/commit/063db427cf0b1f53754b4da509dba2e48f7e4985))



# [9.1.0](https://github.com/bigeyedata/terraform-modules/compare/v9.0.0...v9.1.0) (2024-07-08)


### Features

* add ECS mem util percent alarm ([8d4f6d8](https://github.com/bigeyedata/terraform-modules/commit/8d4f6d8a54da15f9f13c11b8bce3d68082230a53))



# [9.0.0](https://github.com/bigeyedata/terraform-modules/compare/v8.0.1...v9.0.0) (2024-07-05)


* fix!: upgrade AWS provider version from 5.33 to 5.50 ([0afcdc1](https://github.com/bigeyedata/terraform-modules/commit/0afcdc169cea92adde72da009000b0601b84f205))


### Features

* enable KMS key rotation ([05897ed](https://github.com/bigeyedata/terraform-modules/commit/05897ed613a738b0aed3151f1dbf3da6bf612796))
* make KMS key rotation days configurable ([82f6bbf](https://github.com/bigeyedata/terraform-modules/commit/82f6bbfd907fe0e3938550b4c30b3104bf48a273))


### BREAKING CHANGES

* You must run `terraform init -upgrade` to upgrade
your provider versions.

Recommendation: Run `terraform init -upgrade`.

Downtime: No.

Steps: Run `terraform init -upgrade`.



## [8.0.1](https://github.com/bigeyedata/terraform-modules/compare/v8.0.0...v8.0.1) (2024-07-03)


### Bug Fixes

* always create KMS IAM Policy if creating IAM Role ([af1ff1d](https://github.com/bigeyedata/terraform-modules/commit/af1ff1daca609555119ff9476e13f4b52e6b694e))



# [8.0.0](https://github.com/bigeyedata/terraform-modules/compare/v7.0.2...v8.0.0) (2024-07-02)


## Breaking Changes

### Variable Rename

[7b8a504](https://github.com/bigeyedata/terraform-modules/commit/50de5c1d19537a0e5c8e461281e2b5016f15d86b)

The `datwatch_encrypt_secrets_with_kms_enabled` variable had a typo and
has been renamed to `datawatch_encrypt_secrets_with_kms_enabled`.

### Change Default KMS Setting

[09acc39](https://github.com/bigeyedata/terraform-modules/commit/09acc39f6c4dcfe84ad66aebe8c85d6b066593e4)

The `datawatch_encrypt_secrets_with_kms_enabled` flag enables KMS
encryption in datawatch. As of `1.57.0` the feature is not yet GA, so
this value is being changed to false.

**Action required if**

* Upgrading from a terraform version between `6.6.0` and `7.0.2`.
* AND your application version is greater than `1.58.0`.

If your installation does not meet the above conditions, no action is required.

If you do meet the above conditions, then certain data has already been
encrypted with KMS, and if you do not follow the steps below, then you
will be at risk of data corruption.

#### Recommendation

You must set your
`datawatch_encrypt_secrets_with_kms_enabled` variable to true.

If you accidentally delete your KMS Key, you must cancel its deletion.
Please refer to the AWS documentation on cancelling a key deletion
[here](https://docs.aws.amazon.com/kms/latest/developerguide/deleting-keys-scheduling-key-deletion.html).


## Features

* add ability to bring your own kms key for encryption ([19d1b77](https://github.com/bigeyedata/terraform-modules/commit/19d1b77d73a6b383e55dafd6ff7988fa4d620f7b))



## [7.0.2](https://github.com/bigeyedata/terraform-modules/compare/v7.0.1...v7.0.2) (2024-07-02)


### Bug Fixes

* add setting private_hosted_zone to support private zones ([0e05741](https://github.com/bigeyedata/terraform-modules/commit/0e057411ec2ae9ce708171d6ce28e747da12f19b))



## [7.0.1](https://github.com/bigeyedata/terraform-modules/compare/v7.0.0...v7.0.1) (2024-06-29)


### Bug Fixes

* add tags to datawatch KMS key ([e6d8cd3](https://github.com/bigeyedata/terraform-modules/commit/e6d8cd3b4e5e66cf8cc7e71b5573ee0eb523e1e1))
* remove broken condition in kms policy ([893d7b2](https://github.com/bigeyedata/terraform-modules/commit/893d7b27cc90f25cdc1c1283a845a8a9a6fd151f))



# [7.0.0](https://github.com/bigeyedata/terraform-modules/compare/v6.6.1...v7.0.0) (2024-06-27)


* feat!: autoscale papi service ([c4f8c3a](https://github.com/bigeyedata/terraform-modules/commit/c4f8c3ad42e23b462c1b80905646dee618eadfeb))


### Features

* reduce Papi ECS service deregistration delay to 3 minutes ([2067655](https://github.com/bigeyedata/terraform-modules/commit/2067655b0361148239ce2a9d3fcd79181cbfb32d))


### BREAKING CHANGES

* Upgrading to this version will result downtime while
the Papi (internal API service) ECS service is replaced with an
autoscaling version.  The downtime can be avoided by manually
running a terraform state move before running terraform apply:

terraform state mv \
'module.bigeye.module.papi.aws_ecs_service.controlled_count[0]' \
'module.bigeye.module.papi.aws_ecs_service.uncontrolled_count[0]'

This also speeds up the terraform apply by ~15 minutes as that is
the current LB deregistration delay on the Papi service.



## [6.6.1](https://github.com/bigeyedata/terraform-modules/compare/v6.6.0...v6.6.1) (2024-06-27)


### Bug Fixes

* add permissions for datawatch ECS task to use KMS key ([66da40f](https://github.com/bigeyedata/terraform-modules/commit/66da40f0cc38b88efd0bc159f85aee010d7b8249))
* don't reference KMS unless feature is enabled ([1aa302a](https://github.com/bigeyedata/terraform-modules/commit/1aa302a5ff99671d0ece8f623c5061b50b08dd87))



# [6.6.0](https://github.com/bigeyedata/terraform-modules/compare/v6.5.0...v6.6.0) (2024-06-26)


### Features

* use KMS to encrypt secrets ([8d528c3](https://github.com/bigeyedata/terraform-modules/commit/8d528c31dbe341637ade0a780123df826d966e90))



# [6.5.0](https://github.com/bigeyedata/terraform-modules/compare/v6.4.1...v6.5.0) (2024-06-18)


### Features

* route internal API calls to papi service 2 ([133ea11](https://github.com/bigeyedata/terraform-modules/commit/133ea1124a58812a3c576258db10524ff7356343))



## [6.4.1](https://github.com/bigeyedata/terraform-modules/compare/v6.4.0...v6.4.1) (2024-06-18)


### Bug Fixes

* iam role policy name for datawatch efs access ([d57720a](https://github.com/bigeyedata/terraform-modules/commit/d57720aa5f975b28d0be0abe48add99115dc3279))



# [6.4.0](https://github.com/bigeyedata/terraform-modules/compare/v6.3.1...v6.4.0) (2024-06-14)


### Features

* add private API service (papi) 1 ([7cb575d](https://github.com/bigeyedata/terraform-modules/commit/7cb575de7163c8874fc4c85eae5fb871801ff578))



## [6.3.1](https://github.com/bigeyedata/terraform-modules/compare/v6.3.0...v6.3.1) (2024-06-13)


### Bug Fixes

* revert send monocle and toretto traffic to datawork instead ([b65bade](https://github.com/bigeyedata/terraform-modules/commit/b65badebf010084ebd5174aa10d01e9cd7a68bc0))



# [6.3.0](https://github.com/bigeyedata/terraform-modules/compare/v6.2.0...v6.3.0) (2024-06-13)


### Features

* enable heap dump on OOM for some java services ([d7e66fe](https://github.com/bigeyedata/terraform-modules/commit/d7e66fef33f50f025270c8ba057c7bc0c1006fef))



# [6.2.0](https://github.com/bigeyedata/terraform-modules/compare/v6.1.1...v6.2.0) (2024-06-13)


### Features

* add ability to mount EFS volume in app containers ([569bb5c](https://github.com/bigeyedata/terraform-modules/commit/569bb5cc95fc0c0f8e3f750cef7c0da1b217a2c5))



## [6.1.1](https://github.com/bigeyedata/terraform-modules/compare/v6.1.0...v6.1.1) (2024-06-12)


### Bug Fixes

* send monocle and toretto traffic to datawork instead ([cf4cf05](https://github.com/bigeyedata/terraform-modules/commit/cf4cf055d46fb86ad31586476d7f766dc786e4ae))



# [6.1.0](https://github.com/bigeyedata/terraform-modules/compare/v6.0.0...v6.1.0) (2024-05-31)


### Features

* allow using firelens for ECS logs ([3aeb288](https://github.com/bigeyedata/terraform-modules/commit/3aeb2881fbf11e9cbcf7f31c38b6fa079dc9ee42))



# [6.0.0](https://github.com/bigeyedata/terraform-modules/compare/v5.0.0...v6.0.0) (2024-05-23)


## Breaking Changes - Variable removals

Downtime: No

If set, the following variables will need to be removed from your configuration as they
have been removed from this Terraform module:
- `temporal_opensearch_instance_count`
- `temporal_opensearch_enable_master_nodes`
- `temporal_opensearch_zone_awareness_zone_count`

These are now no longer settable, but instead controlled via `var.redundant_infrastructure`.
 
[7829d35](https://github.com/bigeyedata/terraform-modules/commit/7829d35c993350d1f46594a0b35748f988c02270)

# [5.0.0](https://github.com/bigeyedata/terraform-modules/compare/v4.7.3...v5.0.0) (2024-05-20)


## Breaking Changes - State Moves

Downtime: Yes if steps are not taken.

Several resource addresses have changed, requiring some manual steps to
prepare the terraform state for a non-destructive apply. These changes
were made to accommodate the injection of several other resources,
as well as to avoid overriding the `desired_count` of the autoscaling
ECS services.

If no manual changes are made, then the next `terraform apply` will
be destructive.

Always inspect the output of the `terraform plan` and `terraform apply`
commands to ensure the changes Terraform plans are the ones you expect.

### Autoscaling desired_count

[ead3a6d](https://github.com/bigeyedata/terraform-modules/commit/ead3a6d5cd64769f8ac6cb947d35a541be262552)

The resource name for the `aws_ecs_service`'s in the
`simpleservice` module have been changed to reflect whether the
`desired_count` is controlled.

Run the following commands:

```sh
terraform state mv 'module.bigeye.module.web.aws_ecs_service.this' 'module.bigeye.module.web.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.temporalui.aws_ecs_service.this' 'module.bigeye.module.temporalui.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.datawatch.aws_ecs_service.this' 'module.bigeye.module.datawatch.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.datawork.aws_ecs_service.this' 'module.bigeye.module.datawork.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.lineagework.aws_ecs_service.this' 'module.bigeye.module.lineagework.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.metricwork.aws_ecs_service.this' 'module.bigeye.module.metricwork.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.scheduler.aws_ecs_service.this' 'module.bigeye.module.scheduler.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.haproxy.aws_ecs_service.this' 'module.bigeye.module.haproxy.aws_ecs_service.controlled_count[0]'
```

If you are autoscaling monocle & toretto, run the following:

```sh
terraform state mv 'module.bigeye.module.toretto.aws_ecs_service.this' 'module.bigeye.module.toretto.aws_ecs_service.uncontrolled_count[0]'
terraform state mv 'module.bigeye.module.monocle.aws_ecs_service.this' 'module.bigeye.module.monocle.aws_ecs_service.uncontrolled_count[0]'
```

If you are not autoscaling monocle & toretto, run the following:

```sh
terraform state mv 'module.bigeye.module.toretto.aws_ecs_service.this' 'module.bigeye.module.toretto.aws_ecs_service.controlled_count[0]'
terraform state mv 'module.bigeye.module.monocle.aws_ecs_service.this' 'module.bigeye.module.monocle.aws_ecs_service.controlled_count[0]'
```

### Bring-your-own Resources

You can now bring your own IAM Roles as well as a RabbitMQ broker.

* IAM Roles [c73561e](https://github.com/bigeyedata/terraform-modules/commit/c73561e9371d1d489e9c44181928a5edee225e1f)
* RabbitMQ [77e9169](https://github.com/bigeyedata/terraform-modules/commit/77e91698a3a034d2c604c768772c5d14c689c558)

These resources are now conditional and therefore their resource
addresses have changed.

You must run the following commands.

```sh
# RabbitMQ
terraform state mv 'module.bigeye.module.rabbitmq' 'module.bigeye.module.rabbitmq[0]';

# ECS Role
terraform state mv 'module.bigeye.aws_iam_role.ecs' 'module.bigeye.aws_iam_role.ecs[0]';
terraform state mv 'module.bigeye.aws_iam_role_policy.ecs_execution' 'module.bigeye.aws_iam_role_policy.ecs_execution[0]';
terraform state mv 'module.bigeye.aws_iam_role_policy.ecs_secrets' 'module.bigeye.aws_iam_role_policy.ecs_secrets[0]';

# Admin Container Role
terraform state mv 'module.bigeye.module.bigeye_admin.aws_iam_role.this' 'module.bigeye.module.bigeye_admin.aws_iam_role.this[0]';
terraform state mv 'module.bigeye.module.bigeye_admin.aws_iam_role_policy.this' 'module.bigeye.module.bigeye_admin.aws_iam_role_policy.this[0]';

# Monocle Role
terraform state mv 'module.bigeye.aws_iam_role.monocle' 'module.bigeye.aws_iam_role.monocle[0]';
terraform state mv 'module.bigeye.aws_iam_role_policy.monocle' 'module.bigeye.aws_iam_role_policy.monocle[0]';

# Datawatch Role
terraform state mv 'module.bigeye.aws_iam_role.datawatch' 'module.bigeye.aws_iam_role.datawatch[0]';
terraform state mv 'module.bigeye.aws_iam_role_policy.datawatch_s3' 'module.bigeye.aws_iam_role_policy.datawatch_s3[0]';
terraform state mv 'module.bigeye.aws_iam_role_policy.datawatch_temporalsecrets' 'module.bigeye.aws_iam_role_policy.datawatch_temporalsecrets[0]';
terraform state mv 'module.bigeye.aws_iam_role_policy.datawatch_listsecrets' 'module.bigeye.aws_iam_role_policy.datawatch_listsecrets[0]';
terraform state mv 'module.bigeye.aws_iam_role_policy.datawatch_secrets' 'module.bigeye.aws_iam_role_policy.datawatch_secrets[0]';
```

## Bug Fixes

* do not access route53 if not managing dns ([80ad921](https://github.com/bigeyedata/terraform-modules/commit/80ad92134807639610479022aa3451133c1b23da))


## Other Features

* add outputs for cloudwatch and s3 resources ([1d6c2be](https://github.com/bigeyedata/terraform-modules/commit/1d6c2be5d33e485064dbd396182abf6f44c0d2a5))



## [4.7.3](https://github.com/bigeyedata/terraform-modules/compare/v4.7.2...v4.7.3) (2024-05-15)


### Bug Fixes

* update opernsearch autotune rollback setting ([1166591](https://github.com/bigeyedata/terraform-modules/commit/1166591a61ba1a10421e9e41684c08da220f5459))



## [4.7.2](https://github.com/bigeyedata/terraform-modules/compare/v4.7.1...v4.7.2) (2024-05-15)


### Bug Fixes

* update password strength rules for generated opensearch password ([3190b83](https://github.com/bigeyedata/terraform-modules/commit/3190b83b8cff4c25e6c231d359681f6c208a3c3e))



## [4.7.1](https://github.com/bigeyedata/terraform-modules/compare/v4.7.0...v4.7.1) (2024-05-15)


### Bug Fixes

* add missing flag for replica option group ([954c17b](https://github.com/bigeyedata/terraform-modules/commit/954c17bc57ae5badc27e31b6ee90159775ae3a46))
* use dynamic config for opensearch availability zone count ([de8d837](https://github.com/bigeyedata/terraform-modules/commit/de8d8377aa9e60ebe42817ead8fbe6ca606d4e3f))



# [4.7.0](https://github.com/bigeyedata/terraform-modules/compare/v4.6.1...v4.7.0) (2024-05-15)


### Features

* allow passing in rds db option group settings ([fa5d9db](https://github.com/bigeyedata/terraform-modules/commit/fa5d9dbbeadd772fa377022878b7da348b88d542))



## [4.6.1](https://github.com/bigeyedata/terraform-modules/compare/v4.6.0...v4.6.1) (2024-05-14)


### Bug Fixes

* always use 3 opensearch zones if zone aware is enabled ([669b3d5](https://github.com/bigeyedata/terraform-modules/commit/669b3d56638b255d3e8024654e44582a47f3dbc5))
* set opensearch data and master node types to the same ([5194ae4](https://github.com/bigeyedata/terraform-modules/commit/5194ae41321d818de4caf1790cdde086c2b9cae8))



# [4.6.0](https://github.com/bigeyedata/terraform-modules/compare/v4.5.0...v4.6.0) (2024-05-14)


### Features

* disable MQ workers for lineagework service ([87cf93f](https://github.com/bigeyedata/terraform-modules/commit/87cf93f6420e62685155066a05545c880a1a9c41))



# [4.5.0](https://github.com/bigeyedata/terraform-modules/compare/v4.4.0...v4.5.0) (2024-05-13)


### Features

* add opensearch for temporal visibility store with one data node ([bd3a8ee](https://github.com/bigeyedata/terraform-modules/commit/bd3a8eef5c99d623623c6ef939de23b38c95296a))
* allow temporal visibility store to be driven by SQL ([4edadf2](https://github.com/bigeyedata/terraform-modules/commit/4edadf2af158a2b052240954a9a283a7894d82ef))
* enable production settings on temporal visibility store ([e162989](https://github.com/bigeyedata/terraform-modules/commit/e1629898abffca2ea46b6ee9b23fd6ee89c0f68f))



# [4.4.0](https://github.com/bigeyedata/terraform-modules/compare/v4.3.0...v4.4.0) (2024-05-13)


### Features

* add lineagework service ([9d8a03c](https://github.com/bigeyedata/terraform-modules/commit/9d8a03c784deddc42ea38acff37d24b01300bc0b))



# [4.3.0](https://github.com/bigeyedata/terraform-modules/compare/v4.1.2...v4.3.0) (2024-05-09)


### Features

* add additional outputs for subnet ids ([82b0e3a](https://github.com/bigeyedata/terraform-modules/commit/82b0e3ac0ea162022b03f49483ff94d40c7b4b16))



# [4.2.0](https://github.com/bigeyedata/terraform-modules/compare/v4.1.1...v4.2.0) (2024-05-09)


### Features

* add additional outputs for subnet ids ([82b0e3a](https://github.com/bigeyedata/terraform-modules/commit/82b0e3ac0ea162022b03f49483ff94d40c7b4b16))


## [4.1.2](https://github.com/bigeyedata/terraform-modules/compare/v4.1.1...v4.1.2) (2024-05-09)


### Bug Fixes

* change the default setting for general_log on replica ([7bf436b](https://github.com/bigeyedata/terraform-modules/commit/7bf436b8af6d3ed51d156c85da66582c545d5634))
* create temporal parameters by default ([588ea58](https://github.com/bigeyedata/terraform-modules/commit/588ea587a445b3ab07298395e13f01120d64109a))
* database slow log parameter settings ([d97746b](https://github.com/bigeyedata/terraform-modules/commit/d97746bc8606fa40d362c5f24be08aa8f67d548c))



## [4.1.1](https://github.com/bigeyedata/terraform-modules/compare/v4.1.0...v4.1.1) (2024-05-03)


### Bug Fixes

* db parameter apply method not working ([fa561eb](https://github.com/bigeyedata/terraform-modules/commit/fa561ebb6447dd350265f94c768c1c8d74cc5a20))



# [4.1.0](https://github.com/bigeyedata/terraform-modules/compare/v4.0.0...v4.1.0) (2024-05-03)


### Features

* allow configuring database iops ([6972a6c](https://github.com/bigeyedata/terraform-modules/commit/6972a6c0f5ecdc664b9c6dce5c930d858b8d6ff6))



# [4.0.0](https://github.com/bigeyedata/terraform-modules/compare/v3.15.0...v4.0.0) (2024-04-26)


## Breaking Changes

### Variable Re-definition - RDS Parameters

[eb9b737](https://github.com/bigeyedata/terraform-modules/commit/eb9b7374a5d74126a2d17b59a501700aa75fdf06)

Downtime: No

The way RDS parameters were configured made it cumbersome
to specify database parameter changes. If a user wanted to change
a single DB parameter, they would need to provide the rest
of the database parameters into the variable. This represented
an unnecessary maintenance risk.

In version `4.0.0`, the default RDS parameters are now
specified in the following variables:

* `datawatch_rds_default_parameters`
* `datawatch_rds_replica_default_parameters`
* `temporal_rds_default_parameters`

Users can add to or override these defaults by specifying the
following variables (previously these variables contained the
default values):

* `datawatch_rds_parameters`
* `datawatch_rds_replica_parameters`
* `temporal_rds_parameters`

The structure of all of these variables has also changed to
more clearly control merging precedence. The structure has
changed as follows:

```tf
locals {
  previous_structure = [
    {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
    }
  ]

  new_structure = {
    log_output = {
      value = "FILE"
      apply_method = "immediate"
    }
  }
}
```

The parameters are constructed by merging the `_rds_parameters`
with, or on top of (i.e. overriding), the values in the
respective `_default_rds_parameters` variables.

#### Changes Required

If you have modified any of the following variables,
then you will have to make changes.

* `datawatch_rds_parameters`
* `datawatch_rds_replica_parameters`
* `temporal_rds_parameters`

Change the structure of your parameters variable values
to conform to the new syntax. Confirm your changes by
running `terraform plan` and inspecting the output.

### RDS Parameter Value Changes

Downtime: No

The `log_output` DB parameter was defaulted to `"FILE"`.

Now, the `general_log` and `slow_query_log` DB parameters
are now enabled by default if the `rds_enabled_logs` variables
include the `general` and `slowlog` values, respectively.

### Upgrade AWS Provider

[1dc29a3](https://github.com/bigeyedata/terraform-modules/commit/1dc29a3ece38b67ec5af6fc7bcd78e267d063560)

Downtime: No

The required AWS provider was increased from `5.31.0` to
`5.33.0`. This was to allow the AWS Secrets Manager secret versions
to be controlled and prevent drift. Previously, if someone had
modified one of the terraform-controlled AWS Secrets Manager secrets
to have a new value, the Terraform module would not correct that drift.
In this new version, drift detection is possible for AWS Secrets Manager
secret versions. See the
[release notes](https://github.com/hashicorp/terraform-provider-aws/releases/tag/v5.33.0)
for more information.

To upgrade, you must run:

```tf
terraform init -upgrade
```

If you have pinned your AWS terraform provider version to something less
than `5.33.0`, you will need to update that value and run `terraform init -upgrade`.


## Bug Fixes

* ensure the AWSCURRENT version of ASM secrets is controlled ([1ee7c40](https://github.com/bigeyedata/terraform-modules/commit/1ee7c408afc7074c57f18425f72a9f3b5be1cd80))


# [3.15.0](https://github.com/bigeyedata/terraform-modules/compare/v3.14.0...v3.15.0) (2024-04-26)


### Features

* add variable to configure database logs ([4e8da7a](https://github.com/bigeyedata/terraform-modules/commit/4e8da7adcebf0bac983b915b9083db09fdeafab6))



# [3.14.0](https://github.com/bigeyedata/terraform-modules/compare/v3.13.1...v3.14.0) (2024-04-26)


### Features

* enable ecs exec for some of the services ([9418ef3](https://github.com/bigeyedata/terraform-modules/commit/9418ef368001e71c848a77e9cbb029fe4ae035cc))



## [3.13.1](https://github.com/bigeyedata/terraform-modules/compare/v3.13.0...v3.13.1) (2024-04-25)


### Bug Fixes

* temporal frontend service should only run the frontend component ([13dfdc5](https://github.com/bigeyedata/terraform-modules/commit/13dfdc593c2469f2f7434c584406a6f8e668b1dd))



# [3.13.0](https://github.com/bigeyedata/terraform-modules/compare/v3.12.0...v3.13.0) (2024-04-24)


### Bug Fixes

* use fargate_version var ([b6fa30a](https://github.com/bigeyedata/terraform-modules/commit/b6fa30a3d9bba7ae8e6f959032437a7f99971a9c))


### Features

* add security group rule for metrics checking ([fc7a2c2](https://github.com/bigeyedata/terraform-modules/commit/fc7a2c22cb57206de9f8827f918910ae507bbffa))
* split temporal into components ([11d42e3](https://github.com/bigeyedata/terraform-modules/commit/11d42e302edfff1af54bd2579901f17a7bc82a73))



# [3.12.0](https://github.com/bigeyedata/terraform-modules/compare/v3.11.2...v3.12.0) (2024-04-23)


### Features

* add encryption and salt secrets ([3d5ef9b](https://github.com/bigeyedata/terraform-modules/commit/3d5ef9bd428dcea2fa3cc9fe535fe3a5a69db92f))



## [3.11.2](https://github.com/bigeyedata/terraform-modules/compare/v3.11.1...v3.11.2) (2024-04-19)


### Bug Fixes

* set default for performance insights back to true ([e521370](https://github.com/bigeyedata/terraform-modules/commit/e521370078543642508d63b43cd31de97985fe17))



## [3.11.1](https://github.com/bigeyedata/terraform-modules/compare/v3.11.0...v3.11.1) (2024-04-17)


### Bug Fixes

* update logic enabling performance insights on RDS ([3689493](https://github.com/bigeyedata/terraform-modules/commit/36894935b44b5e6a3c83de265ded77fe4fd84047))



# [3.11.0](https://github.com/bigeyedata/terraform-modules/compare/v3.10.0...v3.11.0) (2024-04-17)


### Features

* enable performance insights on datawatch mysql replica ([c36f20f](https://github.com/bigeyedata/terraform-modules/commit/c36f20fd0b799e33606e1256065da2c03d53834e))



# [3.10.0](https://github.com/bigeyedata/terraform-modules/compare/v3.9.1...v3.10.0) (2024-04-05)


### Features

* add additional ingress cidrs for internal resources ([ffb2c8f](https://github.com/bigeyedata/terraform-modules/commit/ffb2c8f30c29098af7c9ccbc6ba5dd0ad7909d6f))
* add additional_ingress_cidrs var for outward-facing resources ([08a1917](https://github.com/bigeyedata/terraform-modules/commit/08a19174c9107d06bf7e293ce6de06e901ae81dd))



## [3.9.1](https://github.com/bigeyedata/terraform-modules/compare/v3.9.0...v3.9.1) (2024-04-04)


### Bug Fixes

* add sentry dsn to web container ([7173a30](https://github.com/bigeyedata/terraform-modules/commit/7173a30959c6fa78efffee6167f8c2f5dc3c7942))



# [3.9.0](https://github.com/bigeyedata/terraform-modules/compare/v3.8.3...v3.9.0) (2024-04-03)


### Features

* allow setting replica DB engine version ([c801fb2](https://github.com/bigeyedata/terraform-modules/commit/c801fb24407ca3bbbaa1e7b53a1ff13e4ca9cc8b))



## [3.8.3](https://github.com/bigeyedata/terraform-modules/compare/v3.8.2...v3.8.3) (2024-03-27)


### Bug Fixes

* scheduler datawatch address to datawork ([7371a93](https://github.com/bigeyedata/terraform-modules/commit/7371a933b46bb1fe7f40b2a9542016075d1c6a76))



## [3.8.2](https://github.com/bigeyedata/terraform-modules/compare/v3.8.1...v3.8.2) (2024-03-18)


### Bug Fixes

* binlog_format should be ROW for replica by default ([25a6b26](https://github.com/bigeyedata/terraform-modules/commit/25a6b263448ed85264de653855819119425e5fc9))
* write iops metric for RDS ([a0c85a5](https://github.com/bigeyedata/terraform-modules/commit/a0c85a56b2ad67434520b84d85c87cee2c522131))



## [3.8.1](https://github.com/bigeyedata/terraform-modules/compare/v3.8.0...v3.8.1) (2024-03-15)


### Bug Fixes

* add app tag for temporal, redis, rabbit ([b2d54ee](https://github.com/bigeyedata/terraform-modules/commit/b2d54eed04d8fd42a53c913a26ef203a6e23e998))



# [3.8.0](https://github.com/bigeyedata/terraform-modules/compare/v3.7.0...v3.8.0) (2024-03-15)


### Features

* create parameter group by default for datawatch replica ([6ce59d6](https://github.com/bigeyedata/terraform-modules/commit/6ce59d67b4b2b63a196e3c41c552a555359b6ccc))



# [3.7.0](https://github.com/bigeyedata/terraform-modules/compare/v3.6.2...v3.7.0) (2024-03-12)


### Bug Fixes

* reorder environment variable merge list to allow var to override ([7afaf17](https://github.com/bigeyedata/terraform-modules/commit/7afaf17d7b495bcaecdca2f06f3b98d8be08643f))


### Features

* add rds parameters variables ([1ecf236](https://github.com/bigeyedata/terraform-modules/commit/1ecf236fbe2b36588de5950544b9b14d752b01a5))



## [3.6.2](https://github.com/bigeyedata/terraform-modules/compare/v3.6.1...v3.6.2) (2024-03-08)


### Bug Fixes

* alarm defaults for redis and rabbitmq ([413127a](https://github.com/bigeyedata/terraform-modules/commit/413127ae3386ee0c51bc0b861970e4ea03c95cb3))
* elasticache alarms incorrect namespace ([23d31a8](https://github.com/bigeyedata/terraform-modules/commit/23d31a8cb2101d3f5c63b8b9b23706f07e6453d0))
* load balancer and target group alarm ids should use arn_suffix ([f875b75](https://github.com/bigeyedata/terraform-modules/commit/f875b75f0e347eba8c501e4beffae01dccf363c4))



## [3.6.1](https://github.com/bigeyedata/terraform-modules/compare/v3.6.0...v3.6.1) (2024-03-07)


### Bug Fixes

* add agent large payload bucket name env var ([f026974](https://github.com/bigeyedata/terraform-modules/commit/f026974147d7d32dbcb0c9295994f6b6bafa2059))



# [3.6.0](https://github.com/bigeyedata/terraform-modules/compare/v3.5.1...v3.6.0) (2024-03-05)


### Features

* add ability to specify models s3 bucket name ([4a8e9c2](https://github.com/bigeyedata/terraform-modules/commit/4a8e9c24b1a06585e7baa0526099478f356dc60d))



## [3.5.1](https://github.com/bigeyedata/terraform-modules/compare/v3.5.0...v3.5.1) (2024-03-05)


### Bug Fixes

* logic update for when to install RDS performance insights ([b03da76](https://github.com/bigeyedata/terraform-modules/commit/b03da766ef201be57a9431de2c7e2e9dd4dc0886))



# [3.5.0](https://github.com/bigeyedata/terraform-modules/compare/v3.4.1...v3.5.0) (2024-03-04)


### Features

* add optional VPC S3 flow logs ([e2bc49a](https://github.com/bigeyedata/terraform-modules/commit/e2bc49ad38243da87f2edb2550e70cbcb9854d63))
* enable performance insights by default if instances support it ([72aeeb5](https://github.com/bigeyedata/terraform-modules/commit/72aeeb5acf4fdc56509496150ba9661fb951ae2e))



## [3.4.1](https://github.com/bigeyedata/terraform-modules/compare/v3.4.0...v3.4.1) (2024-03-04)


### Bug Fixes

* update rabbitmq admin port to 443 ([fd42768](https://github.com/bigeyedata/terraform-modules/commit/fd4276868fa0b420098a8e030225cf00e398c9bc))



# [3.4.0](https://github.com/bigeyedata/terraform-modules/compare/v3.3.2...v3.4.0) (2024-03-01)


### Features

* add variable to control from email for byo smtp server setups ([30f2f14](https://github.com/bigeyedata/terraform-modules/commit/30f2f143fee3423048353a24d60b95e6f64411c0))



## [3.3.2](https://github.com/bigeyedata/terraform-modules/compare/v3.3.1...v3.3.2) (2024-02-29)


### Bug Fixes

* always ACM cert creation flag logic ([5a2495d](https://github.com/bigeyedata/terraform-modules/commit/5a2495d069b1b8a4ede870d046f9a52730e7a80b))



## [3.3.1](https://github.com/bigeyedata/terraform-modules/compare/v3.2.0...v3.3.1) (2024-02-29)


### Bug Fixes

* only create ingress rule if create_security_groups = true ([0dd6209](https://github.com/bigeyedata/terraform-modules/commit/0dd62091ddb10344c5ad9c8125402315f0f70219))



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
