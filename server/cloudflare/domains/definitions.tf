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

variable "cloudflare_account_id" { type = string }
variable "mudev_aws_1_instance_ipv4" { type = string }
variable "mudev_vultr_1_instance_ipv4" { type = string }

module "mudev_cc" {
  source = "./mudev.cc"

  cloudflare_account_id       = var.cloudflare_account_id
  mudev_aws_1_instance_ipv4   = var.mudev_aws_1_instance_ipv4
  mudev_vultr_1_instance_ipv4 = var.mudev_vultr_1_instance_ipv4
}

module "protoco_cc" {
  source = "./protoco.cc"

  cloudflare_account_id       = var.cloudflare_account_id
  mudev_aws_1_instance_ipv4   = var.mudev_aws_1_instance_ipv4
  mudev_vultr_1_instance_ipv4 = var.mudev_vultr_1_instance_ipv4
}
