#!/bin/sh
set -e

echo "🔧 Applying Supabase compatibility fix..."

# Environment variable to disable prepared statements
export NODE_OPTIONS="--require /app/supabase-fix.js"

# Create the fix file
cat > /app/supabase-fix.js << 'EOF'
// Monkey patch Sequelize to disable prepared statements for Supabase
const Module = require('module');
const originalRequire = Module.prototype.require;

Module.prototype.require = function(id) {
  const module = originalRequire.apply(this, arguments);
  
  if (id === 'sequelize' || id.includes('sequelize')) {
    // Patch the Sequelize constructor
    if (module.Sequelize && !module.Sequelize._supabasePatched) {
      const OriginalSequelize = module.Sequelize;
      
      module.Sequelize = function(...args) {
        // Handle connection string format
        if (args.length === 1 && typeof args[0] === 'string') {
          // Parse connection string and add options
          const instance = new OriginalSequelize(args[0], {
            dialectOptions: {
              statement_cache_size: 0,
              idle_in_transaction_session_timeout: 0
            },
            pool: {
              max: 5,
              min: 1,
              acquire: 30000,
              idle: 10000
            }
          });
          return instance;
        }
        // Handle config object format
        else if (args.length === 1 && typeof args[0] === 'object') {
          args[0].dialectOptions = args[0].dialectOptions || {};
          args[0].dialectOptions.statement_cache_size = 0;
          args[0].dialectOptions.idle_in_transaction_session_timeout = 0;
        }
        // Handle multi-parameter format
        else if (args.length >= 4) {
          args[3] = args[3] || {};
          args[3].dialectOptions = args[3].dialectOptions || {};
          args[3].dialectOptions.statement_cache_size = 0;
          args[3].dialectOptions.idle_in_transaction_session_timeout = 0;
        }
        
        return new OriginalSequelize(...args);
      };
      
      // Copy static properties
      Object.setPrototypeOf(module.Sequelize, OriginalSequelize);
      Object.keys(OriginalSequelize).forEach(key => {
        module.Sequelize[key] = OriginalSequelize[key];
      });
      
      module.Sequelize._supabasePatched = true;
      console.log('✅ Supabase patch applied to Sequelize');
    }
  }
  
  return module;
};
EOF

echo "✅ Supabase compatibility fix prepared"

# Run the original docker-entrypoint.sh if it exists
if [ -f /docker-entrypoint.sh ]; then
  exec /docker-entrypoint.sh "$@"
else
  exec "$@"
fi
