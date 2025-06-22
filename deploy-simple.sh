#!/bin/bash

# Simple deployment script for Outline with Supabase

echo "🚀 Deploying Outline Wiki..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Creating .env from template..."
    cp .env.example .env
    echo "Please edit .env with your credentials and run again."
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Check required variables
if [ -z "$SLACK_CLIENT_ID" ] || [ -z "$SLACK_CLIENT_SECRET" ] || [ -z "$SUPABASE_SERVICE_KEY" ] || [ -z "$DATABASE_PASSWORD" ]; then
    echo "❌ Missing required environment variables!"
    echo "Please ensure these are set in .env:"
    echo "  - SLACK_CLIENT_ID"
    echo "  - SLACK_CLIENT_SECRET"
    echo "  - SUPABASE_SERVICE_KEY"
    echo "  - DATABASE_PASSWORD"
    exit 1
fi

# Generate secrets if not provided
if [ -z "$SECRET_KEY" ]; then
    export SECRET_KEY=$(openssl rand -hex 32)
    echo "SECRET_KEY=$SECRET_KEY" >> .env
fi

if [ -z "$UTILS_SECRET" ]; then
    export UTILS_SECRET=$(openssl rand -hex 32)
    echo "UTILS_SECRET=$UTILS_SECRET" >> .env
fi

echo "✅ Configuration verified"

# Start Redis first
echo "Starting Redis..."
docker-compose -f docker-compose-supabase.yml up -d redis

# Wait for Redis
sleep 5

# Run database migrations
echo "Running database migrations..."
docker-compose -f docker-compose-supabase.yml run --rm outline yarn db:migrate

# Start Outline
echo "Starting Outline..."
docker-compose -f docker-compose-supabase.yml up -d outline

# Start nginx
echo "Starting Nginx..."
docker-compose -f docker-compose-supabase.yml up -d nginx

echo "✅ Deployment complete!"
echo ""
echo "Your Outline wiki is starting up at:"
echo "👉 https://hub.instabids.ai"
echo ""
echo "It may take a minute for the application to be ready."
echo "You can check logs with: docker-compose -f docker-compose-supabase.yml logs -f"