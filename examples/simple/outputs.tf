output "vm_name" {
  description = "The name of the VM instance"
  value       = module.gce_vm.vm_name
}

output "vm_internal_ip" {
  description = "The internal IP of the VM instance"
  value       = module.gce_vm.vm_internal_ip
}

output "vm_self_link" {
  description = "The self link of the VM instance"
  value       = module.gce_vm.vm_self_link
}