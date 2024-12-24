module "gce_vm" {
  source                        = "../../" # Path to the Terraform module
  project_id                    = "my-gcp-project"
  credentials_file              = "path/to/service-account.json"
  region                        = "us-central1"
  zone                          = "us-central1-a"
  instance_name                 = "sole-tenancy-vm"
  machine_type                  = "n2-standard-4"
  image                         = "debian-cloud/debian-11"
  network                       = "default"
  subnetwork                    = "default"
  tags                          = ["sole-tenancy", "example"]
  metadata                      = { startup-script = "echo 'Sole Tenancy VM setup complete'" }

  # Sole Tenancy configuration
  sole_tenancy                  = true
  sole_tenancy_node_group       = "example-node-group"

  # Shielded VM settings
  enable_secure_boot            = true
  enable_vtpm                   = true
  enable_integrity_monitoring   = true

  # Confidential VM settings
  enable_confidential_compute   = false
}
