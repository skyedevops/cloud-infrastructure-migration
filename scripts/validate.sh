#!/usr/bin/env bash
# scripts/validate.sh — Run terraform fmt, init, validate, and tflint.
# Usage: ./scripts/validate.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform"

cd "$TF_DIR"

echo "==> terraform fmt -check -diff"
terraform fmt -check -diff -recursive

echo "==> terraform init -backend=false"
terraform init -backend=false -input=false

echo "==> terraform validate"
terraform validate

if command -v tflint >/dev/null 2>&1; then
  echo "==> tflint"
  tflint --recursive
else
  echo "==> tflint not installed; skipping"
fi

echo "All checks passed."
