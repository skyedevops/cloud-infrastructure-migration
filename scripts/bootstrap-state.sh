#!/usr/bin/env bash
# scripts/import-state.sh — One-time bootstrap to create the S3 bucket + DynamoDB
# table for the Terraform remote backend.
# Usage: BUCKET=my-tf-state TABLE=my-tf-locks REGION=us-east1 ./scripts/bootstrap-state.sh
set -euo pipefail

BUCKET="${BUCKET:?BUCKET is required}"
TABLE="${TABLE:?TABLE is required}"
REGION="${REGION:-us-east-1}"

echo "==> creating S3 bucket $BUCKET in $REGION"
if [[ "$REGION" == "us-east-1" ]]; then
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
else
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$BUCKET" --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "==> creating DynamoDB lock table $TABLE"
aws dynamodb create-table \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" >/dev/null

echo "Backend resources created."
echo "Now init terraform with:"
echo "  terraform init \\"
echo "    -backend-config=\"bucket=$BUCKET\" \\"
echo "    -backend-config=\"key=cloud-migration/terraform.tfstate\" \\"
echo "    -backend-config=\"region=$REGION\" \\"
echo "    -backend-config=\"dynamodb_table=$TABLE\" \\"
echo "    -backend-config=\"encrypt=true\""
