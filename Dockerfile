FROM outlinewiki/outline:latest

# Copy custom environment script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# DigitalOcean App Platform uses PORT environment variable
ENV PORT=8080

# Expose the port
EXPOSE 8080

# Use our custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]