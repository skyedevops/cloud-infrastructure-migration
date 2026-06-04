plugin "terraform" {
  enabled = true
  version = "0.10.0"
}

plugin "aws" {
  enabled = true
  version = "0.21.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
