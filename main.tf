# Google Compute Engine Instance
resource "google_compute_instance" "vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = var.image
    }
    kms_key_self_link = var.cmek_key_name
  }

  # Network interface with optional IAP tunneling
  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      # This is required for external access
      nat_ip = var.enable_iap ? null : google_compute_address.vm_static_ip.address
    }
  }

  # Static IP if IAP is disabled
  resource "google_compute_address" "vm_static_ip" {
    name   = "${var.instance_name}-static-ip"
    region = var.region
    count  = var.enable_iap ? 0 : 1
  }

  # Add optional tags
  tags = var.tags

  # Shielded VM configurations
  shielded_instance_config {
    enable_secure_boot          = var.enable_shielded_secure_boot
    enable_vtpm                 = var.enable_shielded_vtpm
    enable_integrity_monitoring = var.enable_shielded_integrity_monitoring
  }

  # Confidential VM configurations
  confidential_instance_config {
    enable_confidential_compute = var.enable_confidential_vm
  }

  # Optional Sole Tenancy
  dynamic "scheduling" {
    for_each = var.enable_sole_tenancy ? [1] : []
    content {
      node_affinities {
        key      = "compute.googleapis.com/node-group-name"
        operator = "IN"
        values   = [var.sole_tenancy_node_group]
      }
    }
  }

  # Metadata or startup scripts
  metadata = var.metadata
}
