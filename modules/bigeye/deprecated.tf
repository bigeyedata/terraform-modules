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
