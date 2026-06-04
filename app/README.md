# Cloud Migration Sample App

A minimal 3-tier **Node.js 20 / Express** application that talks to RDS (MySQL)
and ElastiCache (Redis). It exists to exercise the Terraform stack:

- `GET /`        — public metadata
- `GET /healthz` — liveness
- `GET /readyz`  — readiness (pings DB + Redis)
- `GET /cache`   — `INCR` a counter in Redis
- `POST /visit`  — `INSERT` a row in MySQL

## Local development

```bash
cd app
npm install
cp .env.example .env
# Fill in DB_*, REDIS_HOST from `terraform output`

npm run dev
```

## Endpoints behind the ALB

The ASG runs on port 3000. The target group health-checks `/`. Add a second
listener rule if you want `/readyz` to feed the ALB health check.

## Configuration

The app prefers Secrets Manager in production. A short IAM policy in
`terraform/iam.tf` grants `secretsmanager:GetSecretValue` on
`var.db_password_secret_arn`; the app fetches and parses it at startup.

For local dev, use the plaintext env vars in `.env.example`.
