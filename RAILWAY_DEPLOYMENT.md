# Railway Deployment Guide for Outline Wiki

## Quick Start

### 1. Deploy to Railway
1. Go to [railway.app/new](https://railway.app/new)
2. Click "Deploy from GitHub repo"
3. Select `Instabidsai/outline-deployment`
4. Railway will detect the Dockerfile automatically

### 2. Set Environment Variables
Copy ALL of these environment variables to Railway:

```
NODE_ENV=production
SECRET_KEY=[generate 64 character random string]
UTILS_SECRET=[generate 64 character random string]
URL=https://hub.instabids.ai
FORCE_HTTPS=true

# Database - Use the connection string from local .env file
DATABASE_URL=[your supabase connection string]

# Redis - Use the connection string from local .env file
REDIS_URL=[your redis connection string]

# Slack OAuth - Already configured
SLACK_CLIENT_ID=9043111574230.9107214033328
SLACK_CLIENT_SECRET=[from local .env file]

# Storage - Use credentials from local .env file
AWS_ACCESS_KEY_ID=[from local .env file]
AWS_SECRET_ACCESS_KEY=[from local .env file]
AWS_REGION=us-east-1
AWS_S3_UPLOAD_BUCKET_URL=https://wpazqihkhpgyodekxzlz.supabase.co/storage/v1
AWS_S3_UPLOAD_BUCKET_NAME=outline-uploads
AWS_S3_FORCE_PATH_STYLE=true
AWS_S3_ACL=private

# Features
ENABLE_UPDATES=true
WEB_CONCURRENCY=1
MAXIMUM_IMPORT_SIZE=5120000
RATE_LIMITER_ENABLED=true
RATE_LIMITER_REQUESTS=1000
RATE_LIMITER_DURATION_WINDOW=60
SECURE_COOKIES=true
```

### 3. Deploy
- Click "Deploy Now"
- Wait 2-3 minutes for build to complete

### 4. Add Custom Domain
1. Go to Settings → Domains
2. Add: `hub.instabids.ai`
3. Update DNS with Railway's CNAME

### 5. Verify Deployment
- Access https://hub.instabids.ai
- Login with Slack
- Create your first document!

## Troubleshooting

### Database Connection Issues
If you see database connection errors:
1. Enable IPv4 add-on in Supabase ($4/month)
2. Use direct connection instead of pooler

### Redis Connection Issues
1. Check Redis firewall rules in DigitalOcean
2. Ensure Railway's IPs are whitelisted

## Local Environment Variables
The actual values for sensitive environment variables are stored in:
`C:\Users\Not John Or Justin\Documents\outline-railway-deployment\.env.railway`