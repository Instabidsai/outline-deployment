# 🚀 Quick Start Guide - Outline with Supabase

## Option 1: Deploy on Any Linux Server (Recommended)

If you have any existing Linux server or VPS:

```bash
# 1. Clone the repository
git clone https://github.com/Instabidsai/outline-deployment.git
cd outline-deployment

# 2. Run setup script
chmod +x setup-supabase.sh
./setup-supabase.sh

# 3. Edit .env with your credentials
nano .env

# 4. Start Outline
docker-compose -f docker-compose-supabase.yml up -d
```

## Option 2: Deploy on DigitalOcean Droplet

```bash
# Create a new droplet (or use existing):
# - 2GB RAM minimum
# - Ubuntu 22.04
# - Any region

# SSH into droplet and run:
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
apt install docker-compose -y

# Then follow Option 1 steps
```

## Option 3: Test Locally First

```bash
# On your local machine
git clone https://github.com/Instabidsai/outline-deployment.git
cd outline-deployment
./setup-supabase.sh
# Edit .env
docker-compose -f docker-compose-supabase.yml up
```

## Required Credentials

### 1. Supabase (you already have this)
- Database password
- Service key from: https://supabase.com/dashboard/project/tqthesdjiewlcxpvqmjl/settings/api

### 2. Slack App (create new)
1. Go to https://api.slack.com/apps
2. Create New App > From scratch
3. App Name: "Instabids AI Hub"
4. Pick your workspace
5. OAuth & Permissions > Add Redirect URL:
   - `https://hub.instabids.ai/auth/slack.callback`
   - Or `http://localhost:3000/auth/slack.callback` for testing
6. OAuth Scopes: `identity.basic`, `identity.email`, `identity.avatar`
7. Copy Client ID and Client Secret

### 3. SendGrid (optional)
- Get API key from SendGrid dashboard
- Or skip email setup initially

## Troubleshooting

### Can't connect to Supabase?
- Check database password is correct
- Ensure service key has proper permissions

### Slack login not working?
- Verify redirect URL matches exactly
- Check Client ID and Secret are correct

### Storage not working?
- The storage bucket is auto-created
- Ensure service key is correct

## Next Steps

After Outline is running:
1. Create your first admin account
2. Set up collections
3. Get API token for MCP integration
4. Configure team access
