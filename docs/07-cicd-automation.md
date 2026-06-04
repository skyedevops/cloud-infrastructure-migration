# Phase 6: CI/CD Automation

## Objectives
- Fully automated infra changes via GitOps.
- Application deployments on every merge to main.

## Workflows (in `.github/workflows/`)

### `terraform.yml`
- Triggered on PRs (plan) and pushes to `main` (apply).
- Uses OIDC for short-lived AWS credentials (no static keys).
- Comments the plan on the PR for review.
- Gates apply behind a `production` environment (required reviewers).

### `deploy-app.yml`
- Triggered on pushes that change `app/**`.
- Runs tests, builds, syncs to S3, and invalidates CloudFront.

## Required Secrets
| Secret                          | Purpose                                    |
|--------------------------------|--------------------------------------------|
| `AWS_DEPLOY_ROLE_ARN`          | OIDC role to assume                        |
| `TF_STATE_BUCKET`              | S3 bucket for Terraform state              |
| `TF_LOCKS_TABLE`               | DynamoDB table for state locking           |
| `TF_VAR_db_password`           | RDS master password (sensitive)            |
| `STATIC_BUCKET`                | S3 bucket for app assets                   |
| `CLOUDFRONT_DISTRIBUTION_ID`   | CloudFront distribution for invalidation   |

## Branching Strategy
- `main` → production (auto-applies)
- `feature/*` → dev (PR-driven plan only)
- Tag `v*` → release notes; triggers an immutable image build

## Drift Detection
A scheduled job (extend with `on: schedule:`) runs `terraform plan` against
`main` and posts a comment if drift is detected.
