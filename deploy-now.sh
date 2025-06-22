#!/bin/bash

# Instant Outline Deployment Script
# This will get Outline running in minutes!

echo "🚀 Outline Quick Deploy for Instabids AI"
echo "========================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    apt install docker-compose -y || brew install docker-compose
fi

echo ""
echo "⚠️  IMPORTANT: You need two things from Supabase:"
echo ""
echo "1. Database Password (the one you set when creating the project)"
echo "2. Service Role Key from:"
echo "   https://supabase.com/dashboard/project/tqthesdjiewlcxpvqmjl/settings/api"
echo ""
echo "Press Enter when you have these ready..."
read

# Get credentials
echo -n "Enter your Supabase database password: "
read -s DB_PASSWORD
echo ""
echo -n "Enter your Supabase service role key: "
read -s SERVICE_KEY
echo ""

# Create final .env file
cp .env.production .env

# Replace placeholders
sed -i.bak "s/\[YOUR_SUPABASE_PASSWORD\]/$DB_PASSWORD/g" .env
sed -i.bak "s/\[YOUR_SUPABASE_SERVICE_KEY\]/$SERVICE_KEY/g" .env
rm .env.bak

# Create directories
mkdir -p data/redis data/uploads

echo "✅ Configuration complete!"
echo ""
echo "🚀 Starting Outline..."
docker-compose -f docker-compose-supabase.yml up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 10

# Check if running
if docker ps | grep outline > /dev/null; then
    echo "✅ Outline is running!"
    echo ""
    echo "🌐 Access Outline at:"
    echo "   Local: http://localhost:3000"
    echo "   Domain: https://hub.instabids.ai (once DNS is configured)"
    echo ""
    echo "📝 Next steps:"
    echo "1. Open http://localhost:3000"
    echo "2. Sign in with Slack"
    echo "3. Create your first document!"
    echo ""
    echo "🔧 Useful commands:"
    echo "   View logs: docker-compose -f docker-compose-supabase.yml logs -f"
    echo "   Stop: docker-compose -f docker-compose-supabase.yml down"
    echo "   Restart: docker-compose -f docker-compose-supabase.yml restart"
else
    echo "❌ Something went wrong. Check logs with:"
    echo "docker-compose -f docker-compose-supabase.yml logs"
fi
