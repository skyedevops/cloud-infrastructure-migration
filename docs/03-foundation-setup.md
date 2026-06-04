# Phase 2: Foundation Setup

## Objectives
- Establish a multi-account AWS Organization (if applicable).
- Build the network baseline: VPC, subnets, route tables, gateways.
- Apply the security baseline: IAM, Security Groups, NACLs.
- Configure centralized logging and monitoring.

## Terraform Resources (this project)
The `terraform/` directory provisions:

| Resource                        | File                  |
|--------------------------------|-----------------------|
| VPC, subnets, IGW              | `main.tf`, `nat.tf`   |
| NAT Gateway + private RTs      | `nat.tf`              |
| Security groups                | `networking.tf`       |
| IAM role + instance profile    | `iam.tf`              |
| S3 + CloudFront (static)       | `static_assets.tf`    |
| ALB + target group + listener  | `load_balancer.tf`    |
| Launch template + ASG          | `compute.tf`          |
| RDS + parameter group          | `database.tf`         |
| ElastiCache Redis              | `cache.tf`            |
| CloudWatch dashboard + alarms  | `monitoring.tf`       |
| Backups bucket                 | `backups.tf`          |

## Pre-requisites
1. AWS account with admin permissions (or a deploy role).
2. Terraform >= 1.0 installed locally.
3. AWS CLI configured (`aws configure`).
4. An S3 bucket + DynamoDB table for state (use `scripts/bootstrap-state.sh`).
5. (Optional) ACM domain in Route 53 if enabling HTTPS.

## Steps
```bash
# 1. Bootstrap remote state
BUCKET=my-tf-state TABLE=my-tf-locks REGION=us-east-1 \
  ./scripts/bootstrap-state.sh

# 2. Copy and edit environment tfvars
cp terraform/terraform.tfvars.dev.example terraform/terraform.tfvars.dev
$EDITOR terraform/terraform.tfvars.dev
export TF_VAR_db_password='strong-password'

# 3. Validate and apply
./scripts/validate.sh
AUTO_APPROVE=true ./scripts/deploy.sh dev
```

## Security Baseline
- All S3 buckets have `block_public_access` and server-side encryption.
- EC2 SGs allow SSH only from `ssh_cidr_blocks` (use SSM Session Manager in prod).
- RDS is `publicly_accessible = false` and restricted to EC2 SG.
- IAM users use least privilege; EC2 has an instance profile, no static keys.
- Deletion protection is on for prod resources.
