terraform {
  required_version = "1.10.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }
}

variable "tfc_organization_name" { type = string }
variable "tfc_project_name" { type = string }
variable "tfc_workspace_name" { type = string }

variable "aws_idp_run_role_arn" { type = string }
variable "aws_idp_client_id" { type = string }
