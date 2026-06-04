#!/usr/bin/env bash
# scripts/deploy.sh — Initialize, plan, and apply Terraform.
# Usage: ./scripts/deploy.sh <environment> [extra tf flags...]
#   e.g. ./scripts/deploy.sh dev
#        ./scripts/deploy.sh prod -var="domain_name=example.com" -var="alert_email=ops@example.com"

set -euo pipefail

ENVIRONMENT="${1:-dev}"
shift || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform"
TFVARS="$TF_DIR/terraform.tfvars.$ENVIRONMENT"

if [[ ! -f "$TFVARS" ]]; then
  echo "ERROR: tfvars file not found: $TFVARS" >&2
  echo "Create one by copying variables.example.tfvars" >&2
  exit 1
fi

if [[ -z "${TF_VAR_db_password:-}" ]]; then
  echo "WARN: TF_VAR_db_password is not set. RDS creation will fail." >&2
fi

cd "$TF_DIR"

echo "==> terraform fmt -check"
terraform fmt -check -recursive

echo "==> terraform init"
terraform init -input=false

echo "==> terraform validate"
terraform validate

echo "==> terraform plan ($ENVIRONMENT)"
terraform plan -input=false -var-file="$TFVARS" -out=tfplan "$@"

if [[ "${AUTO_APPROVE:-false}" == "true" ]]; then
  echo "==> terraform apply (auto-approve)"
  terraform apply -input=false -auto-approve tfplan
else
  read -r -p "Apply plan? [y/N] " ans
  if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
    terraform apply -input=false tfplan
  else
    echo "Aborted."
  fi
fi
