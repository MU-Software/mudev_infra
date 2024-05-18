terraform {
  required_version = "1.8.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }
  cloud {}
}

provider "aws" {
  region = var.aws_region
}

module "cloudfront" {
  source = "./modules/cloudfront"
}

module "iam" {
  source = "./modules/iam"

  tfc_organization_name = var.tfc_organization_name
  tfc_project_name      = var.tfc_project_name
  tfc_workspace_name    = var.tfc_workspace_name

  idp_run_role_arn = var.idp_run_role_arn
  idp_client_id    = var.idp_client_id
}

module "resources" {
  source = "./modules/resources"

  default_security_group_id = aws_security_group.default_security_group.id
  default_subnet_id         = aws_subnet.default_subnets[var.aws_default_availability_zone].id
  default_subnet_ids        = [for subnet in aws_subnet.default_subnets : subnet.id]
  default_availability_zone = var.aws_default_availability_zone
  default_db_username       = var.default_db_username
}
