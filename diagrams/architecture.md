# Architecture Diagram

This diagram is renderable in GitHub, GitLab, VS Code, and most modern Markdown viewers.

```mermaid
flowchart LR
    User([User]) -->|HTTPS| CF[Amazon CloudFront]
    CF -->|S3 OAC| S3[(S3 Static Assets)]
    CF -->|HTTP/HTTPS| ALB[Application Load Balancer]

    subgraph Public Subnets
      ALB
    end

    ALB -->|HTTP:80| EC2_1[EC2 #1\nAL2023 + httpd]
    ALB -->|HTTP:80| EC2_2[EC2 #2\nAL2023 + httpd]

    subgraph Private Subnets
      EC2_1
      EC2_2
      RDS[(Amazon RDS\nMySQL Multi-AZ)]
      EC[(ElastiCache\nRedis)]
    end

    EC2_1 --> EC
    EC2_2 --> EC
    EC2_1 --> RDS
    EC2_2 --> RDS

    NAT[NAT Gateway] -.-> EC2_1
    NAT -.-> EC2_2

    CW[CloudWatch\nDashboard + Alarms] --- ALB
    CW --- EC2_1
    CW --- EC2_2
    CW --- RDS
    CW --- EC
    CW -->|SNS| Email[Email Alerts]

    GHA[GitHub Actions] -->|Terraform Apply| AWS[(AWS Account)]
    GHA -->|S3 Sync + CF Invalidate| S3
```

## ASCII fallback

```
                      [User]
                         |
                         v
                  [CloudFront] <---> [S3 Static Assets]
                         |
                         v
                  [Application Load Balancer]
                  /                \
                 /                  \
        [EC2 Web 1]            [EC2 Web 2]      <-- Public Subnets
            \                      /
             \                    /
              +--------+---------+
                       |
                       v
        +-----------------------+        +-------------------+
        |  ElastiCache (Redis)  |        |   RDS (Multi-AZ)  |
        +-----------------------+        +-------------------+
                  (Private Subnets)

        [CloudWatch] -- metrics & logs ---> [SNS -> Email]
        [GitHub Actions] -- Terraform plan/apply --> [AWS]
```
