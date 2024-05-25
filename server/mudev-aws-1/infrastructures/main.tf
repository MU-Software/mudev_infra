terraform {
  required_version = "1.8.4"
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

  aws_idp_run_role_arn = var.aws_idp_run_role_arn
  aws_idp_client_id    = var.aws_idp_client_id
}

module "resources" {
  source = "./modules/resources"

  default_security_group_id = aws_security_group.default_security_group.id
  default_subnet_id         = aws_subnet.default_subnets[var.aws_default_availability_zone].id
  default_subnet_ids        = [for subnet in aws_subnet.default_subnets : subnet.id]
  default_availability_zone = var.aws_default_availability_zone
  default_db_username       = var.default_db_username
}

output "mudev_aws_1_public_ip" {
  value = module.resources.mudev_aws_1_public_ip
}
