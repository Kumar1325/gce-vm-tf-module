variable "enable_iap" {
  description = "Enable IAP tunneling for the VM"
  type        = bool
  default     = false
}

variable "enable_confidential_vm" {
  description = "Enable Confidential VM for the instance"
  type        = bool
  default     = false
}

variable "enable_shielded_secure_boot" {
  description = "Enable Shielded VM secure boot"
  type        = bool
  default     = true
}

variable "enable_shielded_vtpm" {
  description = "Enable Shielded VM vTPM"
  type        = bool
  default     = true
}

variable "enable_shielded_integrity_monitoring" {
  description = "Enable Shielded VM integrity monitoring"
  type        = bool
  default     = true
}

variable "sole_tenancy_node_groups" {
  description = "List of node group names for sole tenancy"
  type        = list(string)
  default     = []
}
