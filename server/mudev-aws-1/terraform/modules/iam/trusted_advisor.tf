data "aws_iam_policy_document" "iam_policy_doc_trusted_advisor" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["trustedadvisor.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_trusted_advisor" {
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSTrustedAdvisorServiceRolePolicy"
  role       = "AWSServiceRoleForTrustedAdvisor"
}

resource "aws_iam_role" "iam_role_trusted_advisor" {
  name                 = aws_iam_role_policy_attachment.iam_role_policy_attachment_trusted_advisor.role
  assume_role_policy   = data.aws_iam_policy_document.iam_policy_doc_trusted_advisor.json
  path                 = "/aws-service-role/trustedadvisor.amazonaws.com/"
  managed_policy_arns  = [aws_iam_role_policy_attachment.iam_role_policy_attachment_trusted_advisor.policy_arn]
  max_session_duration = 3600
  tags                 = { Terraform = "true" }
}
