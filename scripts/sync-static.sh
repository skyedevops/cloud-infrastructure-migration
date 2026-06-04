#!/usr/bin/env bash
# scripts/sync-static.sh — Sync local app build output to the S3 static assets bucket
# and invalidate CloudFront.
# Usage: BUCKET=my-bucket DIST=ABC... ./scripts/sync-static.sh ./app/dist
set -euo pipefail

SRC="${1:-./app/dist}"
BUCKET="${BUCKET:-}"
DIST_ID="${DIST_ID:-}"

if [[ -z "$BUCKET" || -z "$DIST_ID" ]]; then
  echo "Usage: BUCKET=name DIST_ID=ABC123 $0 $SRC" >&2
  exit 1
fi

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: source directory not found: $SRC" >&2
  exit 1
fi

echo "==> syncing $SRC -> s3://$BUCKET"
aws s3 sync "$SRC" "s3://$BUCKET/" --delete

echo "==> invalidating CloudFront distribution $DIST_ID"
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*"

echo "Done."
