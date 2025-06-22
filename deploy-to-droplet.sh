#!/bin/bash
# Outline Wiki Deployment Script for Instabids AI
# Uses existing Redis and Supabase infrastructure

set -e

echo "🚀 Deploying Outline Wiki to your existing infrastructure..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root or with sudo${NC}" 
   exit 1
fi

# Clone the repository
echo "📥 Downloading Outline deployment configuration..."
if [ -d "/opt/outline" ]; then
    echo "📂 Updating existing installation..."
    cd /opt/outline && git pull
else
    echo "📂 Creating new installation..."
    git clone https://github.com/Instabidsai/outline-deployment.git /opt/outline
fi

cd /opt/outline

# Check if .env already exists
if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file already exists. Creating .env.new instead${NC}"
    ENV_FILE=".env.new"
else
    ENV_FILE=".env"
fi

# Generate secure random keys
SECRET_KEY=$(openssl rand -hex 32)
UTILS_SECRET=$(openssl rand -hex 32)

# Create environment file
echo "🔧 Creating environment configuration..."
cat > $ENV_FILE << 'EOF'
# Outline Wiki Configuration for Instabids AI
# Generated on: $(date)

# Basic Configuration
NODE_ENV=production
URL=https://hub.instabids.ai
PORT=3000

# Security Keys (auto-generated - DO NOT SHARE)
SECRET_KEY=GENERATED_SECRET_KEY
UTILS_SECRET=GENERATED_UTILS_SECRET

# Redis Configuration (using existing cluster)
REDIS_URL=REDIS_CONNECTION_STRING

# Database Configuration (using Supabase)
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@db.wpazqihkhpgyodekxzlz.supabase.co:5432/postgres?sslmode=require
DATABASE_URL_UNPOOLED=postgresql://postgres:YOUR_PASSWORD@db.wpazqihkhpgyodekxzlz.supabase.co:5432/postgres?sslmode=require

# Slack OAuth Configuration
SLACK_CLIENT_ID=YOUR_SLACK_CLIENT_ID
SLACK_CLIENT_SECRET=YOUR_SLACK_CLIENT_SECRET

# File Storage Configuration (Supabase Storage)
AWS_S3_UPLOAD_BUCKET_URL=https://wpazqihkhpgyodekxzlz.supabase.co/storage/v1/s3
AWS_S3_UPLOAD_BUCKET_NAME=outline-uploads
AWS_S3_FORCE_PATH_STYLE=true
AWS_ACCESS_KEY_ID=YOUR_SUPABASE_ANON_KEY
AWS_SECRET_ACCESS_KEY=YOUR_SUPABASE_SERVICE_KEY
AWS_REGION=us-east-1

# Email Configuration (optional)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_FROM_EMAIL=notifications@instabids.ai
SMTP_REPLY_EMAIL=support@instabids.ai
SMTP_USERNAME=apikey
SMTP_PASSWORD=YOUR_SENDGRID_API_KEY
EOF

# Replace generated keys
sed -i "s/GENERATED_SECRET_KEY/$SECRET_KEY/g" $ENV_FILE
sed -i "s/GENERATED_UTILS_SECRET/$UTILS_SECRET/g" $ENV_FILE

# Create docker-compose for minimal setup
echo "🐳 Creating Docker Compose configuration..."
cat > docker-compose-minimal.yml << 'EOF'
version: '3.8'

services:
  outline:
    image: outlinewiki/outline:latest
    container_name: outline
    env_file: .env
    ports:
      - "127.0.0.1:3000:3000"  # Only expose to localhost
    restart: unless-stopped
    volumes:
      - outline_data:/var/lib/outline/data
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - outline_network

networks:
  outline_network:
    driver: bridge

volumes:
  outline_data:
    driver: local
EOF

# Create nginx configuration
echo "🌐 Creating Nginx configuration..."
cat > nginx-outline.conf << 'EOF'
# Nginx configuration for Outline Wiki
# Place this in /etc/nginx/sites-available/outline

server {
    listen 80;
    server_name hub.instabids.ai;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name hub.instabids.ai;

    # SSL configuration (update paths as needed)
    ssl_certificate /etc/letsencrypt/live/hub.instabids.ai/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/hub.instabids.ai/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy to Outline
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # WebSocket support for real-time collaboration
    location /realtime {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

echo ""
echo -e "${GREEN}✅ Deployment files created successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo ""
echo "1. Edit the environment file:"
echo -e "   ${GREEN}nano /opt/outline/$ENV_FILE${NC}"
echo ""
echo "2. Add these values from your existing setup:"
echo "   - YOUR_PASSWORD (Supabase database password)"
echo "   - REDIS_CONNECTION_STRING (from your Redis cluster)"
echo "   - YOUR_SLACK_CLIENT_ID and SECRET"
echo "   - YOUR_SUPABASE_ANON_KEY and SERVICE_KEY"
echo ""
echo "3. Start Outline:"
echo -e "   ${GREEN}cd /opt/outline${NC}"
echo -e "   ${GREEN}docker-compose -f docker-compose-minimal.yml up -d${NC}"
echo ""
echo "4. Set up SSL certificate:"
echo -e "   ${GREEN}certbot certonly --nginx -d hub.instabids.ai${NC}"
echo ""
echo "5. Configure Nginx:"
echo -e "   ${GREEN}cp nginx-outline.conf /etc/nginx/sites-available/outline${NC}"
echo -e "   ${GREEN}ln -s /etc/nginx/sites-available/outline /etc/nginx/sites-enabled/${NC}"
echo -e "   ${GREEN}nginx -t && systemctl reload nginx${NC}"
echo ""
echo -e "${GREEN}🎉 After these steps, Outline will be available at https://hub.instabids.ai${NC}"
