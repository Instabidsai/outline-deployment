#!/bin/bash

# Quick Setup Script for Outline with Supabase
# This connects Outline to your existing Supabase infrastructure

echo "🚀 Outline + Supabase Quick Setup"
echo "================================="
echo ""
echo "This script will help you set up Outline using your existing Supabase backend."
echo ""

# Required information
echo "📋 You'll need:"
echo "1. Supabase project password"
echo "2. Supabase service key (from Settings > API)"
echo "3. Slack app credentials"
echo "4. SendGrid API key (optional)"
echo ""

# Generate secrets
SECRET_KEY=$(openssl rand -hex 32)
UTILS_SECRET=$(openssl rand -hex 32)

# Create .env file
cat > .env << EOF
# Generated Outline Configuration
NODE_ENV=production
SECRET_KEY=$SECRET_KEY
UTILS_SECRET=$UTILS_SECRET

# Supabase Database (Project: Agents)
DATABASE_URL=postgresql://postgres:[YOUR_DB_PASSWORD]@db.tqthesdjiewlcxpvqmjl.supabase.co:5432/postgres
REDIS_URL=redis://redis:6379

# Application URL
URL=https://hub.instabids.ai

# Supabase Storage (using S3 compatibility)
AWS_ACCESS_KEY_ID=[YOUR_SUPABASE_SERVICE_KEY]
AWS_SECRET_ACCESS_KEY=[YOUR_SUPABASE_SERVICE_KEY]
AWS_REGION=us-east-1
AWS_S3_UPLOAD_BUCKET_URL=https://tqthesdjiewlcxpvqmjl.supabase.co/storage/v1
AWS_S3_UPLOAD_BUCKET_NAME=outline-uploads
AWS_S3_FORCE_PATH_STYLE=true
AWS_S3_ACL=private

# Slack OAuth
SLACK_CLIENT_ID=[YOUR_SLACK_CLIENT_ID]
SLACK_CLIENT_SECRET=[YOUR_SLACK_CLIENT_SECRET]

# Email (optional)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=[YOUR_SENDGRID_API_KEY]
SMTP_FROM_EMAIL=notifications@instabids.ai
SMTP_REPLY_EMAIL=support@instabids.ai

# Features
ENABLE_UPDATES=true
DEFAULT_LANGUAGE=en_US
EOF

echo "✅ Created .env file"
echo ""
echo "📝 Next steps:"
echo "1. Edit .env and add your credentials"
echo "2. Run: docker-compose up -d"
echo "3. Visit https://hub.instabids.ai"
echo ""
echo "🔑 To get your Supabase credentials:"
echo "- Database password: The one you set when creating the project"
echo "- Service key: https://supabase.com/dashboard/project/tqthesdjiewlcxpvqmjl/settings/api"
echo ""
echo "🔗 To create Slack app:"
echo "1. Go to https://api.slack.com/apps"
echo "2. Create new app: 'Instabids AI Hub'"
echo "3. Add redirect URL: https://hub.instabids.ai/auth/slack.callback"
echo "4. Add scopes: identity.basic, identity.email, identity.avatar"
