data "aws_iam_policy_document" "iam_policy_doc_terraform_cloud" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [var.idp_run_role_arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = [var.idp_client_id]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values   = ["organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:*"]
    }
  }
}

resource "aws_iam_role" "iam_role_terraform_cloud" {
  assume_role_policy   = data.aws_iam_policy_document.iam_policy_doc_terraform_cloud.json
  path                 = "/"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  max_session_duration = 3600
  tags                 = { Terraform = "true" }
}

resource "aws_iam_openid_connect_provider" "terraform" {
  url             = "https://app.terraform.io"
  client_id_list  = [var.idp_client_id]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  tags            = { Terraform = "true" }
}
