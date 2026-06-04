#!/usr/bin/env bash
# aws/ssm-connect.sh — Open an SSM Session Manager shell to a web instance.
# Usage: ./aws/ssm-connect.sh [instance-id]
# If no id is given, picks the first running web instance.
set -euo pipefail

ID="${1:-}"
if [[ -z "$ID" ]]; then
  ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=cloud-migration-web" "Name=instance-state-name,Values=running" \
    --query "Reservations[].Instances[].InstanceId" --output text | awk '{print $1}')
fi

if [[ -z "$ID" ]]; then
  echo "No running instance found" >&2
  exit 1
fi

echo "Connecting to $ID..."
aws ssm start-session --target "$ID"
