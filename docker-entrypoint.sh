#!/bin/sh

# Generate secrets if not provided
if [ -z "$SECRET_KEY" ]; then
  export SECRET_KEY=$(openssl rand -hex 32)
fi

if [ -z "$UTILS_SECRET" ]; then
  export UTILS_SECRET=$(openssl rand -hex 32)
fi

# Set Redis URL if Redis is linked
if [ -n "$REDIS_HOST" ]; then
  export REDIS_URL="redis://$REDIS_HOST:6379"
fi

# Set default port
export PORT=${PORT:-3000}

# Run database migrations
yarn db:migrate

# Start the application
exec yarn start