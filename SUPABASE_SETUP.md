# Outline with Supabase Backend

Since we're using Supabase as our backend, we can leverage:
- Supabase PostgreSQL database (instead of self-hosted)
- Supabase Storage (instead of DigitalOcean Spaces)
- Supabase Auth (can integrate with Slack OAuth)

## Quick Deployment on DigitalOcean App Platform

We'll deploy Outline as a DigitalOcean App using Docker.

### Environment Variables for Supabase Integration:

```
DATABASE_URL=postgresql://postgres.[PROJECT_REF]:[PASSWORD]@db.[PROJECT_REF].supabase.co:5432/postgres
REDIS_URL=redis://default:password@redis-server:6379
URL=https://hub.instabids.ai

# Supabase Storage
AWS_ACCESS_KEY_ID=[SUPABASE_SERVICE_KEY]
AWS_SECRET_ACCESS_KEY=[SUPABASE_SERVICE_KEY]
AWS_REGION=us-east-1
AWS_S3_UPLOAD_BUCKET_URL=https://[PROJECT_REF].supabase.co/storage/v1
AWS_S3_UPLOAD_BUCKET_NAME=outline-uploads
AWS_S3_FORCE_PATH_STYLE=true
AWS_S3_ACL=private

# Slack OAuth
SLACK_CLIENT_ID=[FROM_SLACK_APP]
SLACK_CLIENT_SECRET=[FROM_SLACK_APP]
```

## Benefits of Using Supabase:

1. **Managed PostgreSQL** - No need to maintain database
2. **Built-in Storage** - No need for S3/Spaces
3. **Realtime capabilities** - Can sync with other tools
4. **Row Level Security** - Better access control
5. **Already paid for** - Using existing infrastructure
