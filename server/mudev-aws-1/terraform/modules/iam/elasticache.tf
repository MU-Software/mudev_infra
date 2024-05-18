data "aws_iam_policy_document" "iam_policy_doc_elasticache" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["elasticache.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_elasticache" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/ElastiCacheServiceRolePolicy"
  role       = "AWSServiceRoleForElastiCache"
}

resource "aws_iam_role" "iam_role_elasticache" {
  name                 = aws_iam_role_policy_attachment.iam_role_policy_attachment_elasticache.role
  assume_role_policy   = data.aws_iam_policy_document.iam_policy_doc_elasticache.json
  path                 = "/aws-service-role/elasticache.amazonaws.com/"
  managed_policy_arns  = [aws_iam_role_policy_attachment.iam_role_policy_attachment_elasticache.policy_arn]
  max_session_duration = 3600
  tags                 = { Terraform = "true" }
}
