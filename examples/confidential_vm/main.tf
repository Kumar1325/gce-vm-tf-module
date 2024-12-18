module "gce_vm" {
  source = "../../"

  project_id       = "my-gcp-project"
  credentials_file = "path/to/credentials.json"
  region           = "us-central1"
  zone             = "us-central1-a"

  instance_name    = "confidential-vm"
  machine_type     = "n2-standard-4" # Allowed machine type
  image            = "debian-cloud/debian-11"
  network          = "default"
  subnetwork       = "default"

  # Enable Confidential VM
  enable_confidential_vm = true

  tags = ["confidential", "web"]

  metadata = {
    startup-script = "echo Hello, Confidential VM!"
  }
}
