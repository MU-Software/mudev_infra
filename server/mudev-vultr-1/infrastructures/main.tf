terraform {
  required_version = "1.8.3"

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
