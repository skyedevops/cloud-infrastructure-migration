# Cloud Infrastructure Migration & Optimization

A reference project that migrates a 3-tier web application to AWS and optimizes it
for cost, performance, reliability, and security. Everything is reproducible
with **Terraform** and automatable via **GitHub Actions**.

![Architecture](diagrams/architecture.md)

## Highlights

- **VPC** with public/private subnets across multiple AZs and NAT egress
- **Application Load Balancer** (HTTP → optional HTTPS via ACM)
- **EC2 Auto Scaling Group** with target-tracking CPU scaling and rolling instance refresh
- **RDS (MySQL)** Multi-AZ, encrypted, automated backups, CW log exports
- **ElastiCache (Redis)** with encryption in transit + at rest
- **S3 + CloudFront** for static assets via Origin Access Control
- **IAM** role for EC2 with SSM Session Manager, CloudWatch Agent, and Secrets Manager access
- **CloudWatch** dashboard + alarms (5xx, latency, CPU, storage) + SNS email alerts
- **S3 backups bucket** with IA → Glacier lifecycle
- **CI/CD**: Terraform plan-on-PR, apply-on-main, app deploy on push (OIDC, no static keys)

## Repository layout

```
cloud-infrastructure-migration/
├── .github/workflows/        # GitHub Actions: terraform plan/apply, app deploy
├── app/                      # Sample Node.js + Express application
├── aws/                      # AWS-specific CLI helpers (OIDC, SSM, CW queries)
├── azure/                    # Placeholder for future multi-cloud target
├── diagrams/                 # architecture.md (Mermaid) + architecture.txt
├── docs/                     # Phase 1-6 documentation
├── scripts/                  # deploy.sh, destroy.sh, validate.sh, sync-static.sh, bootstrap-state.sh
├── terraform/                # Infrastructure as Code (root module)
│   ├── main.tf               # VPC, subnets, provider, backend
│   ├── nat.tf                # NAT gateway + private route tables
│   ├── networking.tf         # Security groups
│   ├── iam.tf                # EC2 role / instance profile
│   ├── compute.tf            # Launch template + ASG + scaling policy
│   ├── load_balancer.tf      # ALB + target group + listeners (HTTP/HTTPS) + access logs
│   ├── database.tf           # RDS + parameter group + subnet group
│   ├── cache.tf              # ElastiCache Redis
│   ├── static_assets.tf      # S3 + CloudFront + OAC
│   ├── monitoring.tf         # CloudWatch dashboard, alarms, SNS, log groups
│   ├── backups.tf            # S3 backups bucket with lifecycle
│   ├── secrets.tf            # Secrets Manager for db password
│   ├── waf.tf                # WAFv2 web ACL attached to ALB
│   ├── route53.tf            # DNS records (optional)
│   ├── backup_plan.tf        # AWS Backup plan for RDS
│   ├── oidc.tf               # GitHub OIDC provider + deploy role
│   ├── variables.tf          # All input variables
│   ├── outputs.tf            # All output values
│   ├── terraform.tfvars.dev.example
│   └── terraform.tfvars.prod.example
├── Makefile                  # Convenience targets
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## Prerequisites

- AWS account with admin permissions (or a deploy role)
- Terraform >= 1.0
- AWS CLI v2
- Node.js 20+ (for the sample app)
- A public Route 53 hosted zone (only if you want HTTPS via ACM)

## Quick start

```bash
# 1. Bootstrap remote state
BUCKET=my-tf-state TABLE=my-tf-locks REGION=us-east-1 \
  ./scripts/bootstrap-state.sh

# 2. Configure environment
cp terraform/terraform.tfvars.dev.example terraform/terraform.tfvars.dev
$EDITOR terraform/terraform.tfvars.dev
export TF_VAR_db_password='strong-password'

# 3. Validate and apply
./scripts/validate.sh
AUTO_APPROVE=true ./scripts/deploy.sh dev

# 4. Visit the ALB
open "https://$(terraform -chdir=terraform output -raw alb_dns_name)"
```

## Phases

| # | Phase                          | Doc                                    |
|---|--------------------------------|----------------------------------------|
| 1 | Assessment & Discovery         | [docs/02](docs/02-assessment-and-discovery.md) |
| 2 | Foundation Setup               | [docs/03](docs/03-foundation-setup.md) |
| 3 | Migration Execution            | [docs/04](docs/04-migration-execution.md) |
| 4 | Optimization                   | [docs/05](docs/05-optimization.md)     |
| 5 | Monitoring & Operations        | [docs/06](docs/06-monitoring-operations.md) |
| 6 | CI/CD Automation               | [docs/07](docs/07-cicd-automation.md)  |

## Cost

A single-AZ dev environment runs in the free tier (t3.micro / db.t3.micro /
cache.t3.micro) plus ~$32/mo for a NAT Gateway. See [docs/05](docs/05-optimization.md)
for a savings plan / rightsizing checklist.

## Security

- S3 buckets have public access blocked and SSE-AES256.
- EC2 instances are reached via SSM Session Manager (no SSH keys required).
- DB password is stored in AWS Secrets Manager and read by EC2 at boot.
- ALB has an attached WAFv2 web ACL with AWS managed rule sets (Common, KnownBadInputs).
- All production resources have deletion protection enabled.

See [SECURITY.md](SECURITY.md) for reporting vulnerabilities.

## License

MIT — see [LICENSE](LICENSE).
