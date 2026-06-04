# GCP (future multi-cloud target)

This directory is reserved for a future Google Cloud Platform variant of the
project. The architecture maps roughly to:

| AWS                        | GCP                                  |
|----------------------------|--------------------------------------|
| VPC + subnets              | VPC + subnets                        |
| EC2 + ASG + Launch Template| Managed Instance Groups + Templates  |
| Application Load Balancer  | Cloud Load Balancing (HTTP(S))       |
| RDS                        | Cloud SQL                            |
| ElastiCache (Redis)        | Memorystore                          |
| S3                         | Cloud Storage                        |
| CloudFront                 | Cloud CDN                            |
| CloudWatch                 | Cloud Monitoring + Logging           |
| Secrets Manager            | Secret Manager                       |

Until then, this directory contains only this README and a placeholder
`.gitkeep`.

## When to add it
- BigQuery / ML workloads live in GCP
- Existing GCP footprint to integrate with
- Data analytics tier in one cloud, app tier in another
