
resource "aws_db_subnet_group" "mudev-postgres-subnet-group" {
  subnet_ids = var.default_subnet_ids
  tags       = { Terraform = "true" }
}

resource "aws_docdb_subnet_group" "mudev-postgres-subnet-group" {
  subnet_ids = var.default_subnet_ids
  tags       = { Terraform = "true" }
}

resource "aws_db_parameter_group" "mudev-postgres-parameter-group" {
  family      = "postgres16"
  description = "Default parameter group for postgres16"
  tags        = { Terraform = "true" }
}

resource "aws_db_option_group" "mudev-postgres-option-group" {
  engine_name              = "postgres"
  option_group_description = "Default option group for postgres 16"
  major_engine_version     = "16"
  tags                     = { Terraform = "true" }
}

resource "aws_kms_key" "rds" {
  enable_key_rotation                = true
  bypass_policy_lockout_safety_check = false
}

resource "aws_db_instance" "mudev-postgres" {
  allocated_storage          = 20
  auto_minor_version_upgrade = true
  availability_zone          = var.default_availability_zone
  apply_immediately          = false
  parameter_group_name       = aws_db_parameter_group.mudev-postgres-parameter-group.name
  option_group_name          = aws_db_option_group.mudev-postgres-option-group.name
  # Set backup_retention_period to 1day for saving cost
  backup_retention_period               = 1 #trivy:ignore:AVD-AWS-0077
  backup_target                         = "region"
  backup_window                         = "13:51-14:21"
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot                 = true
  customer_owned_ip_enabled             = false
  db_subnet_group_name                  = aws_db_subnet_group.mudev-postgres-subnet-group.name
  dedicated_log_volume                  = false
  deletion_protection                   = true
  delete_automated_backups              = false
  engine                                = "postgres"
  engine_version                        = "16.2"
  iam_database_authentication_enabled   = true
  instance_class                        = "db.t3.micro"
  iops                                  = 0
  kms_key_id                            = aws_kms_key.rds.arn
  license_model                         = "postgresql-license"
  maintenance_window                    = "tue:15:34-tue:16:04"
  max_allocated_storage                 = 1000
  monitoring_interval                   = 0
  multi_az                              = false
  network_type                          = "IPV4"
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.rds.arn
  username                              = var.default_db_username
  manage_master_user_password           = true
  performance_insights_retention_period = 7
  port                                  = 5432
  publicly_accessible                   = false
  skip_final_snapshot                   = false
  storage_encrypted                     = true
  storage_throughput                    = 0
  storage_type                          = "gp2"
  vpc_security_group_ids                = [var.default_security_group_id]

  timeouts {}
  tags = { Terraform = "true" }
}
