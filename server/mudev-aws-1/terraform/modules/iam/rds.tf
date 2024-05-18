data "aws_iam_policy_document" "iam_policy_doc_rds" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["rds.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_rds" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonRDSServiceRolePolicy"
  role       = "AWSServiceRoleForRDS"
}

resource "aws_iam_role" "iam_role_rds" {
  name                 = aws_iam_role_policy_attachment.iam_role_policy_attachment_rds.role
  assume_role_policy   = data.aws_iam_policy_document.iam_policy_doc_rds.json
  path                 = "/aws-service-role/rds.amazonaws.com/"
  managed_policy_arns  = [aws_iam_role_policy_attachment.iam_role_policy_attachment_rds.policy_arn]
  max_session_duration = 3600
  tags                 = { Terraform = "true" }
}

data "aws_iam_policy_document" "iam_policy_doc_rds_monitoring" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["monitoring.rds.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_rds_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = "rds-monitoring-role"
}

resource "aws_iam_role" "iam_role_rds_monitoring" {
  name                 = aws_iam_role_policy_attachment.iam_role_policy_attachment_rds_monitoring.role
  assume_role_policy   = data.aws_iam_policy_document.iam_policy_doc_rds_monitoring.json
  path                 = "/"
  managed_policy_arns  = [aws_iam_role_policy_attachment.iam_role_policy_attachment_rds_monitoring.policy_arn]
  max_session_duration = 3600
  tags                 = { Terraform = "true" }
}
