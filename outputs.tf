output "vm_name" {
  description = "The name of the VM instance"
  value       = google_compute_instance.vm.name
}

output "vm_internal_ip" {
  description = "The internal IP of the VM instance"
  value       = google_compute_instance.vm.network_interface.0.network_ip
}

output "vm_self_link" {
  description = "The self link of the VM instance"
  value       = google_compute_instance.vm.self_link
}
