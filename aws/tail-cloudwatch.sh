#!/usr/bin/env bash
# aws/tail-cloudwatch.sh — Tail the web app's CloudWatch log group.
# Usage: ./aws/tail-cloudwatch.sh [project-name] [since-minutes]
set -euo pipefail
PROJECT="${1:-cloud-migration}"
SINCE="${2:-15}"

aws logs tail "/aws/ec2/${PROJECT}/web" --since "${SINCE}m" --follow
