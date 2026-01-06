#!/bin/bash

# Deployment script for DigitalOcean
# This script helps deploy the Streamlit app to your DigitalOcean droplet

set -e

echo "================================"
echo "Streamlit Docker Deployment"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if server IP is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide the server IP address${NC}"
    echo "Usage: ./deploy.sh <server-ip> [user]"
    echo "Example: ./deploy.sh 164.90.123.45 root"
    exit 1
fi

SERVER_IP=$1
SERVER_USER=${2:-root}
APP_DIR="/opt/streamlit-app"

echo -e "${GREEN}Deploying to: ${SERVER_USER}@${SERVER_IP}${NC}"
echo ""

# Step 1: Copy files to server
echo -e "${YELLOW}Step 1: Copying files to server...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} "mkdir -p ${APP_DIR}"
rsync -avz --exclude 'venv' --exclude '__pycache__' --exclude '.git' \
    ./ ${SERVER_USER}@${SERVER_IP}:${APP_DIR}/

# Step 2: Build and run Docker container
echo -e "${YELLOW}Step 2: Building and starting Docker container...${NC}"
ssh ${SERVER_USER}@${SERVER_IP} << EOF
    cd ${APP_DIR}
    
    # Stop and remove existing container if it exists
    docker compose down 2>/dev/null || true
    
    # Build the image
    docker compose build
    
    # Start the container
    docker compose up -d
    
    # Show status
    docker compose ps
EOF

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "Your app should be accessible at: ${GREEN}http://${SERVER_IP}:8501${NC}"
echo ""
echo "Useful commands:"
echo "  - View logs: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${APP_DIR} && docker compose logs -f'"
echo "  - Restart app: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${APP_DIR} && docker compose restart'"
echo "  - Stop app: ssh ${SERVER_USER}@${SERVER_IP} 'cd ${APP_DIR} && docker compose down'"

