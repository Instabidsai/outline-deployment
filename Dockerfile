FROM outlinewiki/outline:latest

# DigitalOcean App Platform uses PORT environment variable
ENV PORT=8080

# Expose the port
EXPOSE 8080

# The base image already has the correct CMD
