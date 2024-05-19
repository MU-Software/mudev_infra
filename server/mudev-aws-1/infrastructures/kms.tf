resource "aws_kms_key" "ebs" {
  enable_key_rotation                = true
  bypass_policy_lockout_safety_check = false
}

resource "aws_kms_key" "secretsmanager" {
  enable_key_rotation                = true
  bypass_policy_lockout_safety_check = false
}
