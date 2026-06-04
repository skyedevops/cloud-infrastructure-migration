#!/usr/bin/env bash
# aws/get-alb-endpoint.sh — Print the ALB DNS name.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT/terraform"
terraform output -raw alb_dns_name
