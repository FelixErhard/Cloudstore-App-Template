# In dieser Datei werden die Eingabe-Variablen der Terraform Konfiguration definiert.

# Diese Eingabe-Variable ist ein System-Requirement für Cloudstore-Apps.
variable "vm_name" {
  type    = string
  default = "terraform-student-vm"
}
variable "deployment_id" { 
  type = string 
}