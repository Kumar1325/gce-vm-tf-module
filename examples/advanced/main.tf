module "gce_vm" {
  source = "../../" # Path to the module

  project_id       = "my-gcp-project"
  credentials_file = "path/to/credentials.json"
  region           = "us-central1"
  zone             = "us-central1-a"

  instance_name    = "advanced-vm"
  machine_type     = "e2-medium"
  image            = "debian-cloud/debian-11"
  network          = "default"
  subnetwork       = "default"

  # Enable advanced features
  enable_iap                      = true
  enable_confidential_vm          = true
  enable_shielded_secure_boot     = true
  enable_shielded_vtpm            = true
  enable_shielded_integrity_monitoring = true
  sole_tenancy_node_groups        = ["my-node-group"]

  tags = ["web", "iap-enabled"]

  metadata = {
    startup-script = "echo Advanced GCP VM setup!"
  }
}
