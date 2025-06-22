#!/bin/bash

# Quick deployment script for DigitalOcean droplet

echo "🚀 Deploying Outline Wiki to DigitalOcean..."

# Update system
apt update && apt upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    apt install -y docker-compose
fi

# Create deployment directory
mkdir -p /opt/outline
cd /opt/outline

# Download deployment files
echo "Downloading deployment files..."
wget https://raw.githubusercontent.com/Instabidsai/outline-deployment/main/docker-compose-simple.yml
wget https://raw.githubusercontent.com/Instabidsai/outline-deployment/main/.env
wget https://raw.githubusercontent.com/Instabidsai/outline-deployment/main/nginx.conf

# Create data directories
mkdir -p data/redis data/outline ssl

# Generate self-signed SSL for testing (replace with real certs later)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx.key \
  -out ssl/nginx.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=hub.instabids.ai"

# Set database password
echo "Setting up environment..."
sed -i 's/your-db-password/outline2024secure/g' .env

# Pull images
docker-compose -f docker-compose-simple.yml pull

# Start services
echo "Starting Outline..."
docker-compose -f docker-compose-simple.yml up -d

# Wait for services
sleep 10

# Check status
docker-compose -f docker-compose-simple.yml ps

echo "✅ Deployment complete!"
echo ""
echo "Outline should be accessible at:"
echo "👉 http://$(curl -s ifconfig.me):3000"
echo ""
echo "For HTTPS, configure your domain to point to this server."
echo "Then update the URL in .env and restart."