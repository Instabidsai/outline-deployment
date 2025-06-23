# Droplet Deployment Instructions

## Prerequisites

1. Create a DigitalOcean Droplet:
   - **OS**: Ubuntu 22.04 LTS
   - **Size**: s-2vcpu-2gb ($18/month) or larger
   - **Region**: NYC3 (or closest to you)
   - **Options**: Enable IPv6, Monitoring
   - **SSH Key**: Add your SSH key

2. Point DNS:
   - Add an A record for `hub.instabids.ai` pointing to your Droplet's IPv4
   - Add an AAAA record for `hub.instabids.ai` pointing to your Droplet's IPv6

## Quick Deployment

1. **SSH into your droplet:**
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

2. **Run the setup script:**
   ```bash
   curl -O https://raw.githubusercontent.com/Instabidsai/outline-deployment/main/droplet-setup.sh
   chmod +x droplet-setup.sh
   ./droplet-setup.sh
   ```

3. **Get SSL certificate:**
   ```bash
   certbot --nginx -d hub.instabids.ai
   ```

4. **Access Outline:**
   - Visit https://hub.instabids.ai
   - Login with Slack

## Manual Deployment

If you prefer to do it manually:

### 1. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
apt-get install -y docker-compose-plugin
```

### 2. Clone Repository
```bash
cd /opt
git clone https://github.com/Instabidsai/outline-deployment.git
cd outline-deployment
```

### 3. Configure Environment
```bash
cp .env.example .env
nano .env
```

Update these values:
- `DATABASE_URL`: Your Supabase direct connection URL
- `SLACK_CLIENT_SECRET`: Your actual Slack secret
- `AWS_SECRET_ACCESS_KEY`: Your Supabase service role key
- `SECRET_KEY` and `UTILS_SECRET`: Generate new 64-character strings

### 4. Start Services
```bash
docker compose -f docker-compose.droplet.yml up -d
```

### 5. Setup Nginx
```bash
apt-get install -y nginx certbot python3-certbot-nginx
```

Create `/etc/nginx/sites-available/outline`:
```nginx
server {
    listen 80;
    server_name hub.instabids.ai;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Enable and test:
```bash
ln -s /etc/nginx/sites-available/outline /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx
```

### 6. Get SSL Certificate
```bash
certbot --nginx -d hub.instabids.ai
```

## Monitoring

Check container status:
```bash
docker compose -f docker-compose.droplet.yml ps
```

View logs:
```bash
docker compose -f docker-compose.droplet.yml logs -f outline
```

Restart services:
```bash
docker compose -f docker-compose.droplet.yml restart
```

## Troubleshooting

### Database Connection Issues
If you see IPv6 connection errors, ensure:
1. Your Droplet has IPv6 enabled
2. You're using the direct database URL (not pooler)
3. The Supabase project allows connections from your Droplet IP

### SSL Issues
If SSL setup fails:
1. Ensure DNS is properly configured
2. Port 80 and 443 are open
3. Nginx is running

### Container Issues
If containers won't start:
```bash
docker compose -f docker-compose.droplet.yml down
docker compose -f docker-compose.droplet.yml up -d
docker compose -f docker-compose.droplet.yml logs
```

## Backup

To backup your data:
```bash
# Backup Redis
docker compose -f docker-compose.droplet.yml exec redis redis-cli SAVE
cp /opt/outline-deployment/data/redis/dump.rdb ~/backup/

# Backup uploads
tar -czf ~/backup/uploads.tar.gz /opt/outline-deployment/data/uploads/
```

## Support

- **Repository**: https://github.com/Instabidsai/outline-deployment
- **Outline Docs**: https://docs.getoutline.com
