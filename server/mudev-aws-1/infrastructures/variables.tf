variable "tfc_organization_name" { type = string }
variable "tfc_project_name" { type = string }
variable "tfc_workspace_name" { type = string }

variable "aws_idp_run_role_arn" { type = string }
variable "aws_idp_client_id" { type = string }

variable "default_db_username" { type = string }

variable "aws_region" { type = string }
variable "aws_regions" { type = list(string) }
variable "aws_default_availability_zone" { type = string }
