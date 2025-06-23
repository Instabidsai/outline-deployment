FROM outlinewiki/outline:latest

# Copy the fix scripts
COPY supabase-fix-entrypoint.sh /supabase-fix-entrypoint.sh
RUN chmod +x /supabase-fix-entrypoint.sh

# DigitalOcean App Platform uses PORT environment variable
ENV PORT=8080

# Expose the port
EXPOSE 8080

# Use our Supabase compatibility fix
ENTRYPOINT ["/supabase-fix-entrypoint.sh"]
CMD ["node", "./build/server/index.js"]
