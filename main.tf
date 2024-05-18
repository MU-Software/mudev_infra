terraform {
  required_version = "1.8.3"
  cloud {}
}

variable "tfc_organization_name" { type = string }
variable "tfc_project_name" { type = string }
variable "tfc_workspace_name" { type = string }

variable "idp_run_role_arn" { type = string }
variable "idp_client_id" { type = string }

variable "default_db_username" { type = string }

module "mudev_aws_1" {
  source = "./server/mudev-aws-1/terraform"

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

  idp_run_role_arn = var.idp_run_role_arn
  idp_client_id    = var.idp_client_id

  default_db_username = var.default_db_username
}
