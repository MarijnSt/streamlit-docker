# Streamlit Docker Deployment

This repo serves as a test to deploy Streamlit through Docker on a DigitalOcean droplet.

## 📋 Prerequisites

- Docker and Docker Compose installed locally (for testing)
- A DigitalOcean account and droplet
- SSH access to your DigitalOcean droplet
- Docker installed on your DigitalOcean droplet

## 🚀 Quick Start - Local Testing

Test the app locally before deploying:

```bash
# Build and run with Docker Compose
docker compose up --build

# Or build and run with Docker directly
docker build -t streamlit-app .
docker run -p 8501:8501 streamlit-app
```

Access the app at: http://localhost:8501

## 🌊 DigitalOcean Deployment Guide

### Step 1: Set Up DigitalOcean Droplet

1. **Create a Droplet**
   - Log into DigitalOcean
   - Create a new Droplet (Ubuntu 22.04 LTS recommended)
   - Choose your preferred size (Basic $6/month should be sufficient)
   - Add your SSH key
   - Note your droplet's IP address

2. **SSH into your droplet**
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

3. **Install Docker and Docker Compose**
   ```bash
   # Update system
   apt update && apt upgrade -y
   
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   
   # Install Docker Compose
   apt install docker-compose-plugin -y
   
   # Verify installation
   docker --version
   docker compose version
   ```

### Step 2: Configure Firewall

```bash
# On your DigitalOcean droplet
ufw allow OpenSSH
ufw allow 8501/tcp
ufw enable
```

Or configure via DigitalOcean's Cloud Firewall:
- Allow inbound on port 8501 (TCP)
- Allow inbound on port 22 (SSH)

### Step 3: Deploy Your App

**Option A: Automated Deployment (Recommended)**

From your local machine, run the deployment script:

```bash
./deploy.sh YOUR_DROPLET_IP root
```

**Option B: Manual Deployment**

1. Copy files to your droplet:
   ```bash
   scp -r ./* root@YOUR_DROPLET_IP:/opt/streamlit-app/
   ```

2. SSH into your droplet:
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

3. Build and run:
   ```bash
   cd /opt/streamlit-app
   docker compose up -d --build
   ```

### Step 4: Access Your App

Open your browser and navigate to:
```
http://YOUR_DROPLET_IP:8501
```

## 🛠️ Useful Commands

### On Your Droplet

```bash
# View logs
docker compose logs -f

# Restart the app
docker compose restart

# Stop the app
docker compose down

# Rebuild and restart
docker compose up -d --build

# Check container status
docker compose ps

# Execute commands in the container
docker compose exec streamlit-app bash
```

### Updating Your App

After making changes locally:

```bash
# Use the deployment script
./deploy.sh YOUR_DROPLET_IP root

# Or manually
rsync -avz --exclude 'venv' ./ root@YOUR_DROPLET_IP:/opt/streamlit-app/
ssh root@YOUR_DROPLET_IP 'cd /opt/streamlit-app && docker compose up -d --build'
```

## 🔒 Production Considerations

1. **Use a Domain Name**
   - Point a domain to your droplet's IP
   - Set up Nginx as a reverse proxy
   - Enable HTTPS with Let's Encrypt

2. **Security**
   - Create a non-root user for running the application
   - Keep Docker and system packages updated
   - Use secrets management for sensitive data

3. **Monitoring**
   - Set up logging and monitoring
   - Configure automatic backups
   - Set up alerts for downtime

## 📝 Project Structure

```
.
├── app.py              # Main Streamlit application
├── requirements.txt    # Python dependencies
├── Dockerfile          # Docker image definition
├── docker-compose.yml  # Docker Compose configuration
├── .dockerignore       # Files to exclude from Docker build
├── deploy.sh           # Automated deployment script
└── README.md           # This file
```

## 🐛 Troubleshooting

**Container won't start:**
```bash
docker compose logs
```

**Port already in use:**
```bash
# Check what's using port 8501
sudo lsof -i :8501

# Change port in docker-compose.yml
ports:
  - "8502:8501"  # Use 8502 instead
```

**Can't access from browser:**
- Check firewall settings (UFW and DigitalOcean Cloud Firewall)
- Verify container is running: `docker compose ps`
- Check logs: `docker compose logs`

## 📚 Additional Resources

- [Streamlit Documentation](https://docs.streamlit.io/)
- [Docker Documentation](https://docs.docker.com/)
- [DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials)
