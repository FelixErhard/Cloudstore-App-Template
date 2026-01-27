# In dieser Datei werden die Outputs der Terraform Konfiguration definiert.


# Dieser Output ist ein System-Requirement für Cloudstore-Apps.
output "instance_id" {
  description = "OpenStack instance ID"
  value       = openstack_compute_instance_v2.vm.id
}


# AB HIER können Sie weitere Outputs definieren, die Sie benötigen.
