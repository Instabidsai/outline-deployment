FROM outlinewiki/outline:latest

# Copy custom entrypoint scripts
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY docker-entrypoint-fix.sh /docker-entrypoint-fix.sh
RUN chmod +x /docker-entrypoint.sh /docker-entrypoint-fix.sh

# DigitalOcean App Platform uses PORT environment variable
ENV PORT=8080

# Expose the port
EXPOSE 8080

# Use our fix entrypoint that patches Sequelize for Supabase compatibility
ENTRYPOINT ["/docker-entrypoint-fix.sh", "/docker-entrypoint.sh"]
