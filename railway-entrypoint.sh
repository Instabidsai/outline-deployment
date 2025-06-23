#!/bin/bash
set -e

echo "🚀 Starting Outline on Railway..."

# Railway provides DATABASE_URL in the correct format
# No need to parse or modify it

# Wait for database to be ready
echo "⏳ Waiting for database..."
until pg_isready -h ${DATABASE_HOST:-db.wpazqihkhpgyodekxzlz.supabase.co} -p ${DATABASE_PORT:-5432}; do
  echo "Database is unavailable - sleeping"
  sleep 2
done

echo "✅ Database is ready!"

# Run migrations
echo "📦 Running database migrations..."
yarn db:migrate

echo "🎯 Starting Outline server..."
exec "$@"
