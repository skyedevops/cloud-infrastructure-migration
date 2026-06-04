# Phase 4: Optimization

## Objectives
- Reduce cost while meeting performance/availability SLOs.
- Use managed services to remove operational burden.

## Areas of Focus

### Compute Right-Sizing
- Review CloudWatch `CPUUtilization` and `MemoryUtilization` (with CW agent).
- Move under-utilized instances to smaller families.
- Use Compute Savings Plans / Reserved Instances for steady-state.

### Auto-Scaling
The ASG has a target-tracking policy on `ASGAverageCPUUtilization` at 60%.
Add more policies as needed:
- Request count per target (ALB → ASG)
- Memory utilization (requires CW agent metrics)
- SQS backlog (for worker tiers)

### Caching
- Move expensive queries into ElastiCache.
- Use CloudFront for static and cacheable dynamic responses.
- Tune `cache_policy_id` in the CloudFront distribution.

### Database
- Enable Performance Insights (RDS console).
- Add read replicas for read-heavy workloads.
- Use connection pooling (RDS Proxy).

### Storage Tiering
The S3 buckets include lifecycle rules that transition objects:
- 30 days → STANDARD_IA
- 90 days → GLACIER (static assets) or 180 days (backups)
- 365 days → expiration (backups only)

### Cost Allocation
- Apply the `Project`, `Environment`, `Owner` tags to all resources.
- Enable AWS Cost Explorer + a Cost Anomaly Detection monitor.
- Set up a budget via `aws_budgets_budget` (extend `monitoring.tf`).

## Cost Optimization Checklist
- [ ] Rightsize EC2 (check Compute Optimizer)
- [ ] Purchase Savings Plan / RIs
- [ ] Move cold data to IA / Glacier
- [ ] Delete unused EBS volumes and snapshots
- [ ] S3 Intelligent-Tiering for unknown access patterns
- [ ] Spot instances for fault-tolerant workloads
