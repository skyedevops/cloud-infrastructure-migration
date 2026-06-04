#!/usr/bin/env bash
# aws/dump-rds-schema.sh — Dump the RDS schema to the backups bucket.
# Usage: ./aws/dump-rds-schema.sh [project-name]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT="${1:-cloud-migration}"
cd "$REPO_ROOT/terraform"

ENDPOINT=$(terraform output -raw rds_endpoint)
SECRET_ARN=$(terraform output -raw db_secret_arn)

if [[ -z "$ENDPOINT" || -z "$SECRET_ARN" ]]; then
  echo "Run 'terraform apply' first" >&2
  exit 1
fi

# Read credentials from Secrets Manager
CREDS=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --query SecretString --output text)
USER=$(echo "$CREDS" | jq -r .username)
PASS=$(echo "$CREDS" | jq -r .password)
DB=$(echo "$CREDS" | jq -r .dbname)

TS=$(date -u +%Y%m%dT%H%M%SZ)
FILE="/tmp/${PROJECT}-${TS}.sql"

mysqldump -h "$ENDPOINT" -u "$USER" -p"$PASS" --no-data --routines "$DB" > "$FILE"

BUCKET="${PROJECT}-backups-$(aws sts get-caller-identity --query Account --output text)"
aws s3 cp "$FILE" "s3://${BUCKET}/schema/${TS}.sql"
rm -f "$FILE"
echo "Uploaded to s3://${BUCKET}/schema/${TS}.sql"
