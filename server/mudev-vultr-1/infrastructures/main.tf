terraform {
  required_version = "1.10.3"

  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.19.0"
    }
  }
  cloud {}
}

variable "vultr_api_key" { type = string }

provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_instance" "mudev_vultr_ubuntu_1" {
  region          = "nrt"
  plan            = "(LEGACY-4) vc2-1c-1gb"
  os_id           = 365
  backups         = "disabled"
  ddos_protection = false
  tags            = ["Terraform"]
}

output "mudev_vultr_1_public_ip" {
  value = vultr_instance.mudev_vultr_ubuntu_1.main_ip
}
