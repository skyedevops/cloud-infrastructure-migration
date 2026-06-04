#!/usr/bin/env bash
# scripts/destroy.sh — Tear down a Terraform environment safely.
# Usage: ./scripts/destroy.sh <environment>
set -euo pipefail

ENVIRONMENT="${1:-dev}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform"
TFVARS="$TF_DIR/terraform.tfvars.$ENVIRONMENT"

if [[ ! -f "$TFVARS" ]]; then
  echo "ERROR: tfvars file not found: $TFVARS" >&2
  exit 1
fi

cd "$TF_DIR"
terraform init -input=false
echo "==> terraform plan -destroy ($ENVIRONMENT)"
terraform plan -destroy -input=false -var-file="$TFVARS" -out=tfplan-destroy

read -r -p "Destroy $ENVIRONMENT infrastructure? Type 'destroy' to confirm: " ans
if [[ "$ans" == "destroy" ]]; then
  terraform apply -input=false -auto-approve tfplan-destroy
else
  echo "Aborted."
fi
