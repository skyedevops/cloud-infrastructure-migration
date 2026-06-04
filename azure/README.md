# Azure (future multi-cloud target)

This directory is reserved for a future Azure landing-zone variant of the
project. The architecture maps roughly to:

| AWS                        | Azure                                |
|----------------------------|--------------------------------------|
| VPC + subnets              | Virtual Network + subnets            |
| EC2 + ASG + Launch Template| Virtual Machine Scale Sets           |
| Application Load Balancer  | Application Gateway                  |
| RDS                        | Azure Database for MySQL             |
| ElastiCache (Redis)        | Azure Cache for Redis                |
| S3                         | Blob Storage                         |
| CloudFront                 | Azure CDN / Front Door               |
| CloudWatch                 | Azure Monitor                        |
| Secrets Manager            | Key Vault                            |
| WAFv2                      | WAF on Application Gateway / Front Door |

Until then, this directory contains only this README and a placeholder
`.gitkeep`.

## When to add it
- Multi-cloud DR (active/passive between AWS and Azure)
- Data-residency requirements
- Lift-and-shift from an existing Azure estate
