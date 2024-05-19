terraform {
  required_version = "1.8.3"
  cloud {}
}

variable "tfc_organization_name" { type = string }
variable "tfc_project_name" { type = string }
variable "tfc_workspace_name" { type = string }

variable "vultr_api_key" { type = string }
variable "aws_idp_run_role_arn" { type = string }
variable "aws_idp_client_id" { type = string }

variable "default_db_username" { type = string }

module "cloudflare" {
  source = "./server/cloudflare"
}

module "mudev_aws_1" {
  source = "./server/mudev-aws-1/infrastructures"

  aws_region = "ap-northeast-2"
  aws_regions = [
    "ap-northeast-2a",
    "ap-northeast-2b",
    "ap-northeast-2c",
    "ap-northeast-2d",
  ]
  aws_default_availability_zone = "ap-northeast-2c"

  tfc_organization_name = var.tfc_organization_name
  tfc_project_name      = var.tfc_project_name
  tfc_workspace_name    = var.tfc_workspace_name

  aws_idp_run_role_arn = var.aws_idp_run_role_arn
  aws_idp_client_id    = var.aws_idp_client_id

  default_db_username = var.default_db_username
}

module "mudev_vultr_1" {
  source = "./server/mudev-vultr-1/infrastructures"

  vultr_api_key = var.vultr_api_key
}

output "mudev_aws_1_public_ip" {
  value = module.mudev_aws_1.mudev_aws_1_public_ip
}

output "mudev_vultr_1_public_ip" {
  value = module.mudev_vultr_1.mudev_vultr_1_public_ip
}
