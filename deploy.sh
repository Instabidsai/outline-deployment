#!/bin/bash

# Outline Deployment Script
# This script helps deploy Outline on a fresh DigitalOcean droplet

set -e

echo "🚀 Starting Outline deployment..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Installing Docker Compose..."
    apt install docker-compose -y
else
    echo "✅ Docker Compose already installed"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p data/postgres data/redis data/uploads ssl certbot/www

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found!"
    echo "Please copy .env.example to .env and configure it"
    exit 1
fi

# Generate secrets if needed
if grep -q "generate_64_char_random_string_here" .env; then
    echo "🔐 Generating secrets..."
    SECRET_KEY=$(openssl rand -hex 32)
    UTILS_SECRET=$(openssl rand -hex 32)
    sed -i "s/generate_64_char_random_string_here/$SECRET_KEY/g" .env
    sed -i "s/generate_another_64_char_random_string_here/$UTILS_SECRET/g" .env
    echo "✅ Secrets generated"
fi

# Start services
echo "🚀 Starting services..."
docker-compose up -d postgres redis

echo "⏳ Waiting for database to be ready..."
sleep 10

# Run migrations
echo "🔧 Running database migrations..."
docker-compose run --rm outline yarn db:migrate

# Start all services
echo "🚀 Starting Outline..."
docker-compose up -d

# Get SSL certificate
echo "🔒 Setting up SSL certificate..."
docker-compose run --rm certbot certonly --webroot \
    --webroot-path=/var/www/certbot \
    --email admin@instabids.ai \
    --agree-tos \
    --no-eff-email \
    -d hub.instabids.ai

# Restart nginx with SSL
docker-compose restart nginx

echo "✅ Deployment complete!"
echo "🌐 Outline should be accessible at https://hub.instabids.ai"
echo ""
echo "Next steps:"
echo "1. Set up your Slack OAuth app at https://api.slack.com/apps"
echo "2. Add the OAuth credentials to your .env file"
echo "3. Restart Outline: docker-compose restart outline"
