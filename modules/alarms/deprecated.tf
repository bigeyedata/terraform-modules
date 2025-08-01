variable "monitor_individual_external_lbs" {
  description = "false will remove monitoring for the individual LBs and only monitor the centralized external lb.  This will be the default in a future release"
  type        = bool
  default     = true
}

variable "monitor_individual_internal_lbs" {
  description = "false will remove monitoring for the individual LBs and only monitor the centralized internal lb.  This will be the default in a future release"
  type        = bool
  default     = true
}
