variable "use_centralized_external_lb" {
  description = "This will migrate to using a single external LB instead of one per service.  This will be the default in a future release"
  type        = bool
  default     = false
}

variable "install_individual_external_lbs" {
  description = "false will remove the external internal LBs.  This will be the default in a future release"
  type        = bool
  default     = true
}

variable "use_centralized_external_lb_solr" {
  description = "This will migrate to using a single external LB for solr.  This will be the default in a future release"
  type        = bool
  default     = false
}

variable "use_centralized_internal_lb" {
  description = "This will migrate to using a single internal LB instead of one per service.  This will be the default in a future release"
  type        = bool
  default     = false
}

variable "install_individual_internal_lbs" {
  description = "false will remove the individual internal LBs.  This will be the default in a future release"
  type        = bool
  default     = true
}

variable "haproxy_lineageapi_enabled" {
  description = "This is a feature flag to allow a controlled rollforward/rollback for routing lineage API calls to a dedicated lineageapi service.  By default this routes all backend requests through haproxy to the datawatch service (ie no change in behavior)"
  type        = bool
  default     = false
}

variable "disable_unused_monocle_dd_flags" {
  description = "temporary flag to see if disabling unneeded datadog telemetry will have an affect on cpu util"
  type        = bool
  default     = true
}

# ready for removal 2025-08-01
variable "load_balancing_anomaly_mitigation" {
  description = "Enable Anomaly mitigation LB algorithm on target groups.  LeastOutstandingRequests routing algorithm is used if set to false.  Cannot be used with session stickiness"
  type        = bool
  default     = true
}

# ready for removal
variable "lineageplus_solr_cnames" {
  description = "Deprecated.  Use var.lineageplus_solr_aliases"
  type        = list(string)
  default     = []
}
