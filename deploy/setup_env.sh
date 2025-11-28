#!/bin/bash
# Script to setup .env file for backend

set -e

BACKEND_DIR="/var/www/project/back"
PROJECT_BACK_DIR=""

echo "=========================================="
echo "Setting up .env file for Backend"
echo "=========================================="

# Find the original back directory
for possible_path in \
    "/mnt/e/Python/FastAPI/10/back" \
    "$HOME/project/back" \
    "$(pwd)/back" \
    "$(dirname "$(pwd)")/back"; do
    if [ -d "$possible_path" ] && [ -f "$possible_path/.env_example" ]; then
        PROJECT_BACK_DIR="$possible_path"
        echo "Found project back directory: $PROJECT_BACK_DIR"
        break
    fi
done

if [ -z "$PROJECT_BACK_DIR" ]; then
    echo "ERROR: Could not find back directory with .env_example"
    echo "Please specify the path to your back directory:"
    read -p "Path: " PROJECT_BACK_DIR
    if [ ! -d "$PROJECT_BACK_DIR" ] || [ ! -f "$PROJECT_BACK_DIR/.env_example" ]; then
        echo "ERROR: Invalid path or .env_example not found"
        exit 1
    fi
fi

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo "ERROR: Backend directory not found: $BACKEND_DIR"
    echo "Please run the deployment script first or copy backend to $BACKEND_DIR"
    exit 1
fi

# Copy .env_example to .env
echo ""
echo "Copying .env_example to $BACKEND_DIR/.env..."
sudo cp "$PROJECT_BACK_DIR/.env_example" "$BACKEND_DIR/.env"
sudo chown www-data:www-data "$BACKEND_DIR/.env"
sudo chmod 600 "$BACKEND_DIR/.env"

echo "✓ .env file created"
echo ""
echo "The .env file has been created from .env_example"
echo "You may want to review and edit it:"
echo "  sudo nano $BACKEND_DIR/.env"
echo ""
echo "IMPORTANT: Make sure to set your actual values, especially:"
echo "  - OPENAI_API_KEY"
echo "  - AUTH_SECRET_KEY"
echo "  - AUTH_LOGIN and AUTH_PASSWORD"

