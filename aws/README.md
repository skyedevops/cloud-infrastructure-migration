# AWS Helpers

AWS-specific one-off scripts and quick-reference commands that complement the
Terraform configuration. Use these to bootstrap, debug, or operate the stack
from the command line.

| Script                       | Purpose                                         |
|------------------------------|-------------------------------------------------|
| `setup-github-oidc.sh`       | One-time: print the OIDC role ARN for CI        |
| `get-alb-endpoint.sh`        | Resolve the ALB DNS name from Terraform outputs |
| `ssm-connect.sh`             | Open a Session Manager shell to an EC2 instance |
| `tail-cloudwatch.sh`         | Tail the web app's CW log group                 |
| `dump-rds-schema.sh`         | Dump the RDS schema to the backups bucket       |

These assume you have `aws` CLI v2 configured (`aws configure sso` or
`AWS_PROFILE`) and `terraform` on PATH.
