data "aws_iam_policy_document" "iam_policy_doc_support" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["support.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_support" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSupportServiceRolePolicy"
  role       = "AWSServiceRoleForSupport"
}

resource "aws_iam_role" "iam_role_support" {
  name                 = aws_iam_role_policy_attachment.iam_role_policy_attachment_support.role
  assume_role_policy   = data.aws_iam_policy_document.iam_policy_doc_support.json
  path                 = "/aws-service-role/support.amazonaws.com/"
  managed_policy_arns  = [aws_iam_role_policy_attachment.iam_role_policy_attachment_support.policy_arn]
  max_session_duration = 3600
  tags                 = { Terraform = "true" }
}
