# Sample Application

A placeholder static site used to demonstrate the `S3 + CloudFront` path.

## Local development
```bash
# Edit app/index.html, then:
BUCKET=my-bucket DIST=ABC123XYZ ./scripts/sync-static.sh ./app
```

## Production deployment
Pushing to `main` triggers `.github/workflows/deploy-app.yml`, which:
1. Builds the app (if a build script exists).
2. Syncs to S3.
3. Invalidates CloudFront.
