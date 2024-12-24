variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "credentials_file" {
  description = "Path to the GCP service account JSON credentials"
  type        = string
}

variable "region" {
  description = "Region where the instance will be deployed"
  type        = string
}

variable "zone" {
  description = "Zone where the instance will be deployed"
  type        = string
}

variable "instance_name" {
  description = "Name of the VM instance"
  type        = string
}

# Machine Type
variable "machine_type" {
  description = "Machine type of the VM instance"
  type        = string

  validation {
    condition = (
      !var.enable_confidential_vm || (
        contains(["n2d", "n2", "e2"], split("-", var.machine_type)[0])
      )
    )
    error_message = <<EOT
Confidential VMs are only supported on N2D, N2, and E2 machine families.
Please select a machine type like n2-standard-2, e2-medium, or n2d-highmem-4.
EOT
  }
}

variable "image" {
  description = "Image to use for the VM boot disk"
  type        = string
}

variable "network" {
  description = "The network to attach to the VM instance"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork to attach to the VM instance"
  type        = string
}

variable "cmek_key_name" {
  description = "The name of the Customer-Managed Encryption Key (CMEK)"
  type = string
}

variable "tags" {
  description = "Tags to associate with the instance"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Metadata to attach to the instance"
  type        = map(string)
  default     = {}
}

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

variable "enable_sole_tenancy" {
  description = "Enable Sole Tenancy for the instance"
  type        = bool
  default     = false
}

variable "sole_tenancy_node_groups" {
  description = "List of node group names for sole tenancy"
  type        = list(string)
  default     = []
}
