terraform {
  required_version = "1.8.4"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  cloud {}
}

variable "cloudflare_account_id" { type = string }
variable "mudev_aws_1_instance_ipv4" { type = string }
variable "mudev_vultr_1_instance_ipv4" { type = string }

module "records" {
  source = "./records"

  cloudflare_zone_id          = cloudflare_zone.protoco_cc.id
  mudev_aws_1_instance_ipv4   = var.mudev_aws_1_instance_ipv4
  mudev_vultr_1_instance_ipv4 = var.mudev_vultr_1_instance_ipv4
}

resource "cloudflare_zone" "protoco_cc" {
  account_id = var.cloudflare_account_id
  paused     = false
  plan       = "free"
  type       = "full"
  zone       = "protoco.cc"
}

resource "cloudflare_bot_management" "protoco_cc" {
  enable_js  = false
  fight_mode = false
  zone_id    = cloudflare_zone.protoco_cc.id
}
