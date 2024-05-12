# https://github.com/terraform-linters/tflint-ruleset-terraform/blob/main/docs/rules/README.md
plugin "terraform" {
    enabled = true
    preset = "all"
}

# https://github.com/terraform-linters/tflint-ruleset-aws/blob/master/docs/rules/README.md
plugin "aws" {
    enabled = true
    deep_check = true
    version = "0.31.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
