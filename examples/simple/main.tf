module "gce_vm" {
  source           = "../../" # Path to the module
  project_id       = var.project_id
  region           = var.region
  zone             = var.zone
  instance_name    = var.instance_name
  machine_type     = var.machine_type
  image            = var.image
  network          = var.network
  subnetwork       = var.subnetwork
  cmek_key_name    = var.cmek_key_name
  service_account_email = var.service_account_email
  tags             = var.tags
  metadata = var.metadata
}
