#!/bin/bash
# WSL Deployment Script for FastAPI Backend and React Frontend
# Ubuntu 24.04.01

set -e

echo "=========================================="
echo "WSL Deployment Script"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_DIR/back"
FRONTEND_DIR="$PROJECT_DIR/front"

echo -e "${GREEN}Project directory: $PROJECT_DIR${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update system
echo -e "\n${YELLOW}Updating system packages...${NC}"
sudo apt update

# Install Python and dependencies
echo -e "\n${YELLOW}Installing Python and dependencies...${NC}"
sudo apt install -y python3 python3-pip python3-venv python-is-python3

# Install Node.js
if ! command_exists node; then
    echo -e "\n${YELLOW}Installing Node.js...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
else
    echo -e "${GREEN}Node.js already installed: $(node -v)${NC}"
fi

# Install Nginx
if ! command_exists nginx; then
    echo -e "\n${YELLOW}Installing Nginx...${NC}"
    sudo apt install -y nginx
else
    echo -e "${GREEN}Nginx already installed: $(nginx -v 2>&1)${NC}"
fi

# Setup Backend
echo -e "\n${YELLOW}Setting up Backend...${NC}"
cd "$BACKEND_DIR"

if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

echo "Activating virtual environment..."
source .venv/bin/activate

echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Setup Frontend
echo -e "\n${YELLOW}Setting up Frontend...${NC}"
cd "$FRONTEND_DIR"

if [ ! -d "node_modules" ]; then
    echo "Installing Node.js dependencies..."
    npm install
fi

echo "Building frontend..."
npm run build

# Create project directory in /var/www
echo -e "\n${YELLOW}Setting up project directory...${NC}"
sudo mkdir -p /var/www/project
sudo cp -r "$BACKEND_DIR" /var/www/project/back
sudo cp -r "$FRONTEND_DIR" /var/www/project/front

# Set permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data /var/www/project
sudo chmod -R 755 /var/www/project

echo -e "\n${GREEN}Deployment setup complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Configure systemd service: sudo cp deploy/back.service /etc/systemd/system/"
echo "2. Configure Nginx: sudo cp deploy/*.conf /etc/nginx/sites-available/"
echo "3. Enable services: sudo systemctl enable back.service"
echo "4. Start services: sudo systemctl start back.service nginx"

