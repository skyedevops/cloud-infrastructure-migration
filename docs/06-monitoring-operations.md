# Phase 5: Monitoring & Operations

## Objectives
- Single-pane-of-glass observability.
- Proactive alerting with low-noise thresholds.
- Documented incident response and runbooks.

## Components Provisioned

### CloudWatch Dashboard
`aws_cloudwatch_dashboard.main` (in `monitoring.tf`) shows:
- ALB request count, 2xx, 5xx
- ALB target response time
- ASG CPU
- RDS CPU + free storage

Open it at: `https://console.aws.amazon.com/cloudwatch/home#dashboards:name=<project>-overview`

### Alarms
- `alb-5xx` — ALB 5xx > 10 in 3 min
- `alb-response-time` — p95 > 1s for 5 min
- `asg-cpu-high` — ASG CPU > 80% for 10 min
- `rds-cpu` — RDS CPU > 80% for 15 min
- `rds-storage-low` — RDS free storage < 2 GiB

Alarms notify the SNS topic (if `alert_email` is set).

### Log Groups
- `/aws/ec2/<project>/web` — web app logs (retention 30d)
- RDS exports: `error`, `general`, `slowquery`

## CloudWatch Agent
The launch template installs `amazon-cloudwatch-agent` via `user_data`.
A reference config can be placed in `app/cw-agent-config.json` and used to push
custom metrics from the instance.

## Incident Response
1. Page on-call via SNS → PagerDuty/Opsgenie integration.
2. Open the dashboard; identify the failing component.
3. Apply the runbook in `docs/runbooks/<service>.md`.
4. Postmortem within 5 business days.

## Backups & DR
- RDS: automated backups, 7-day retention. Final snapshot on destroy.
- S3 backups bucket: 30d → IA, 180d → Glacier, 365d expire.
- Consider cross-region replication for prod (extend `backups.tf`).
