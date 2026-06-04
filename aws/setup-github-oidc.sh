#!/usr/bin/env bash
# aws/setup-github-oidc.sh — Print the GitHub Actions deploy role ARN.
# Use this ARN as the AWS_DEPLOY_ROLE_ARN secret in GitHub.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT/terraform"
terraform output -raw github_actions_role_arn 2>/dev/null \
  || { echo "Run 'terraform apply' first." >&2; exit 1; }
