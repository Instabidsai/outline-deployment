#!/bin/sh
set -e

echo "🔧 Applying Supabase compatibility fix..."

# Create a patch for the database configuration
cat > /tmp/database-patch.js << 'EOF'
// Patch to disable prepared statements for Supabase compatibility
const originalSequelize = require('sequelize').Sequelize;

require('sequelize').Sequelize = function(...args) {
  // If first argument is an object (config), patch it
  if (args.length === 1 && typeof args[0] === 'object') {
    const config = args[0];
    config.dialectOptions = config.dialectOptions || {};
    config.dialectOptions.statement_cache_size = 0; // Disable prepared statements
    config.dialectOptions.statement_timeout = 30000; // 30 second timeout
    console.log('✅ Supabase compatibility patch applied: prepared statements disabled');
  }
  // If using separate parameters, patch the options
  else if (args.length >= 4 && typeof args[3] === 'object') {
    const options = args[3];
    options.dialectOptions = options.dialectOptions || {};
    options.dialectOptions.statement_cache_size = 0; // Disable prepared statements
    options.dialectOptions.statement_timeout = 30000; // 30 second timeout
    console.log('✅ Supabase compatibility patch applied: prepared statements disabled');
  }
  
  return new originalSequelize(...args);
};

// Export the patched version
module.exports = require('sequelize');
EOF

# Find the main server file and inject our patch
if [ -f /opt/outline/build/server/main.js ]; then
  echo "🔍 Found main.js, injecting patch..."
  # Prepend our patch to the main file
  cp /opt/outline/build/server/main.js /opt/outline/build/server/main.js.backup
  echo "require('/tmp/database-patch.js');" | cat - /opt/outline/build/server/main.js > /tmp/main.js
  mv /tmp/main.js /opt/outline/build/server/main.js
  echo "✅ Patch injected successfully"
fi

# Also try to patch the database config directly if we can find it
if [ -f /opt/outline/build/server/database/sequelize.js ]; then
  echo "🔍 Found sequelize.js, patching directly..."
  sed -i 's/dialectOptions: {/dialectOptions: { statement_cache_size: 0,/g' /opt/outline/build/server/database/sequelize.js
  echo "✅ Direct patch applied"
fi

echo "🚀 Starting Outline with Supabase compatibility..."

# Execute the original entrypoint
exec "$@"
