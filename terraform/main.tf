

# Terraform Openstack Provider muss konfiguriert werden
# DO NOT TOUCH
terraform {
  required_version = ">= 1.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}


# Authentifizierung und Verbindung zum OpenStack Cloud Provider
# mittels clouds.yaml Datei -> Diese kann auf Openstack erhalten werden.
# Für lokales Testings mittels des Terraform CLIs kann diese sowohl im aktuellen Verzeichnis
# ./terraform abgelegt werden, wie auch für eine projektweite Nutzung
# im Home Verzeichnis ~/.config/openstack/
# für weitere Informationen siehe:
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs#using
# WICHTIG: Damit diese App mittels des Cloudstores deployed werden kann,
# MUSS der cloud name "openstack" lauten.
provider "openstack" {
  cloud = "openstack"
}

# AB HIER erfolgt die eigentliche Ressourcen Definition für Ihre Cloudstore-App
