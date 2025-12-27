terraform {
  required_version = "1.10.3"
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

module "iam" {
  source = "./modules/iam"

  tfc_organization_name = var.tfc_organization_name
  tfc_project_name      = var.tfc_project_name
  tfc_workspace_name    = var.tfc_workspace_name

  aws_idp_run_role_arn = var.aws_idp_run_role_arn
  aws_idp_client_id    = var.aws_idp_client_id
}
