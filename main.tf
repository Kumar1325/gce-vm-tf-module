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

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
  # Metadata or startup scripts
  metadata = {
    startup-script = "echo Hello, Terraform!"
    block-project-ssh-keys = "true"
  }
}
