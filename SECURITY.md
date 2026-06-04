# Security

## Reporting a vulnerability

Please **do not** open a public GitHub issue for security problems. Email
`security@skyedevops.example` (or open a private security advisory on GitHub)
with:

- A description of the vulnerability and impact
- Steps to reproduce
- Affected versions / commits

We aim to acknowledge reports within 3 business days.

## Security baseline

This project ships with the following baseline:

- S3 buckets: public access blocked, AES-256 server-side encryption, versioning
- RDS: encrypted storage, automated backups, `publicly_accessible = false`
- EC2: reached via SSM Session Manager (no inbound SSH in production)
- WAFv2 in front of the ALB (managed rule sets + IP rate limiting)
- IAM: least-privilege role for EC2, no static credentials, instance profile
- Deletion protection enabled for production resources

## Threat model (assumptions)

- The AWS account root user is locked down and not used.
- CI uses OIDC for short-lived credentials.
- Terraform state is stored in an encrypted S3 bucket with a DynamoDB lock.
- The DB password is stored in Secrets Manager and read by EC2 at boot.

If your environment differs, adjust the relevant variables (e.g.
`ssh_cidr_blocks`, `domain_name`, `alert_email`).
