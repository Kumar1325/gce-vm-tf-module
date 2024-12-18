module "gce_vm" {
  source           = "../../" # Path to the module
  project_id       = "my-gcp-project"
  credentials_file = "path/to/credentials.json"
  region           = "us-central1"
  zone             = "us-central1-a"
  instance_name    = "example-vm"
  machine_type     = "e2-medium"
  image            = "debian-cloud/debian-11"
  network          = "default"
  subnetwork       = "default"
  tags             = ["example", "web"]
  metadata = {
    startup-script = "echo Hello, Terraform!"
  }
}
