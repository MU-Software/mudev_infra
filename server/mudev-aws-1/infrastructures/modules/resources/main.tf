terraform {
  required_version = "1.8.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
  }
}

variable "default_security_group_id" { type = string }
variable "default_subnet_id" { type = string }
variable "default_subnet_ids" { type = list(string) }
variable "default_availability_zone" { type = string }

variable "default_db_username" { type = string }
