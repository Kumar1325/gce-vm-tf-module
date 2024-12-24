module "gce_vm" {
  source                        = "../../"
  project_id                    = "my-gcp-project"
  credentials_file              = "path/to/service-account.json"
  region                        = "us-central1"
  zone                          = "us-central1-a"
  instance_name                 = "ad-joined-vm"
  machine_type                  = "n2-standard-4"
  image                         = "debian-cloud/debian-11"
  network                       = "default"
  subnetwork                    = "default"
  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      AD_DOMAIN="example.com"
      AD_USER="admin-user"
      AD_PASSWORD="admin-password"
      AD_REALM="${AD_DOMAIN^^}"

      sudo apt update -y && sudo apt upgrade -y
      sudo apt install -y realmd sssd sssd-tools adcli krb5-user packagekit samba-common
      echo "Joining the AD domain..."
      echo $AD_PASSWORD | sudo realm join --user=$AD_USER $AD_REALM
      echo "Restarting SSSD..."
      sudo systemctl restart sssd
      echo "%${AD_DOMAIN}\\Domain Admins ALL=(ALL) ALL" | sudo tee /etc/sudoers.d/ad_admins
    EOT
  }
}
