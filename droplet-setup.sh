#!/bin/bash
# Outline Wiki Droplet Setup Script
# This script sets up Outline on a fresh Ubuntu 22.04 droplet

set -e

echo "=== Outline Wiki Droplet Setup ==="
echo "This script will install Docker, clone the repository, and deploy Outline"
echo ""

# Update system
echo "1. Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Docker
echo "2. Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
echo "3. Installing Docker Compose..."
apt-get install -y docker-compose-plugin

# Install additional tools
echo "4. Installing additional tools..."
apt-get install -y git nginx certbot python3-certbot-nginx

# Clone the repository
echo "5. Cloning Outline deployment repository..."
cd /opt
git clone https://github.com/Instabidsai/outline-deployment.git
cd outline-deployment

# Create .env file
echo "6. Creating environment file..."
cat > .env << 'EOF'
# General
NODE_ENV=production
SECRET_KEY=generate64randomcharactershereforsecuritypurposes1234567890abcd
UTILS_SECRET=anotherset64randomcharactershereforsecuritypurposes1234567890ef

# URLs
URL=https://hub.instabids.ai

# Database (Supabase direct connection)
DATABASE_URL=postgres://postgres.wpazqihkhpgyodekxzlz:AcU2AaUAEVcvahVLnRUqDOGNJoQQMJSo@db.wpazqihkhpgyodekxzlz.supabase.co:5432/postgres
DATABASE_CONNECTION_POOL_MIN=1
DATABASE_CONNECTION_POOL_MAX=5
PGSSLMODE=require

# Redis (local)
REDIS_URL=redis://redis:6379

# Slack OAuth
SLACK_CLIENT_ID=9043111574230.9107214033328
SLACK_CLIENT_SECRET=55263f83129b7431a9be4f0a31ec7ee8

# Storage (Supabase)
AWS_S3_UPLOAD_BUCKET_URL=https://wpazqihkhpgyodekxzlz.supabase.co/storage/v1/s3
AWS_S3_UPLOAD_BUCKET_NAME=outline-uploads
AWS_S3_FORCE_PATH_STYLE=true
AWS_ACCESS_KEY_ID=wpazqihkhpgyodekxzlz
AWS_SECRET_ACCESS_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndwYXpxaWhraHBneW9kZWt4emx6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNDg4NDU1NiwiZXhwIjoyMDUwNDYwNTU2fQ.29xBbaKj4TnsGZcNXYlBjwCeA1UvfgOsEvd5YGQBa9A
AWS_REGION=us-east-1

# SSL
FORCE_HTTPS=false
EOF

# Create Docker Compose file for Droplet
echo "7. Creating Docker Compose configuration..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  outline:
    image: outlinewiki/outline:latest
    env_file: .env
    restart: always
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    volumes:
      - ./data/uploads:/var/lib/outline/data

  redis:
    image: redis:7-alpine
    restart: always
    volumes:
      - ./data/redis:/data

  postgres:
    image: postgres:15
    restart: always
    environment:
      POSTGRES_USER: outline
      POSTGRES_PASSWORD: outlinepassword
      POSTGRES_DB: outline
    volumes:
      - ./data/postgres:/var/lib/postgresql/data

volumes:
  postgres_data:
  redis_data:
  uploads_data:
EOF

# Create nginx configuration
echo "8. Creating Nginx configuration..."
cat > /etc/nginx/sites-available/outline << 'EOF'
server {
    listen 80;
    server_name hub.instabids.ai;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/outline /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload nginx
nginx -t
systemctl reload nginx

echo "9. Starting Docker containers..."
docker compose up -d

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Point hub.instabids.ai DNS to this server's IP address"
echo "2. Run: certbot --nginx -d hub.instabids.ai"
echo "3. Access Outline at https://hub.instabids.ai"
echo ""
echo "To check container status: docker compose ps"
echo "To view logs: docker compose logs -f"
echo ""
