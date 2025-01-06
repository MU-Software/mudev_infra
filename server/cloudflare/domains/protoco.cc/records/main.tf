terraform {
  required_version = "1.10.3"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.49.1"
    }
  }
  cloud {}
}

variable "cloudflare_zone_id" { type = string }
variable "mudev_aws_1_instance_ipv4" { type = string }
variable "mudev_vultr_1_instance_ipv4" { type = string }
