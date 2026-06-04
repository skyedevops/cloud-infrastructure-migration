# Phase 3: Migration Execution

## Objectives
- Move the workload tiers onto AWS in the order: static assets → compute → database → cache.

## Migration Order

### 3.1 Static Assets → S3 + CloudFront
1. Build the production static bundle.
2. Upload to the S3 bucket created by `static_assets.tf`.
3. Create a CloudFront invalidation (the deploy script does this).
4. Update DNS (CNAME / Route 53 alias) to the distribution.

```bash
BUCKET=$(terraform -chdir=terraform output -raw s3_static_assets_bucket)
DIST=$(terraform -chdir=terraform output -raw cloudfront_domain)
./scripts/sync-static.sh ./app/build $BUCKET $DIST
```

### 3.2 Application → EC2 Auto Scaling Group
1. Bake the application AMI or use the provided `user_data` script.
2. Deploy the launch template + ASG via `compute.tf`.
3. Register instances with the ALB target group (already wired).
4. Validate health checks return 200.

### 3.3 Database → Amazon RDS
1. Snapshot the source database.
2. `mysqldump` (or `pg_dump`) → upload to S3 backups bucket.
3. Restore into RDS using `mysql`/`psql` client.
4. Cut over application connection strings (via Secrets Manager or parameter store).

### 3.4 Cache → ElastiCache
1. Pre-warm cache if needed (load common keys).
2. Update application config to point to the primary endpoint.
3. Validate hit/miss rates in CloudWatch.

## Cutover
Use a maintenance window for the DB cutover:
- Stop writes on the source
- Final snapshot + restore to RDS
- Flip DNS / config to RDS
- Resume traffic
- Monitor error rates

## Rollback Plan
- Keep the source database in a stopped state for 24h.
- DNS TTL set to 60s before cutover.
- Documented runbook in `docs/runbooks/`.
