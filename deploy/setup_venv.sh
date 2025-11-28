#!/bin/bash
# Script to setup virtual environment for backend

set -e

BACKEND_DIR="/var/www/project/back"
VENV_DIR="$BACKEND_DIR/.venv"

echo "=========================================="
echo "Setting up Virtual Environment"
echo "=========================================="

if [ ! -d "$BACKEND_DIR" ]; then
    echo "ERROR: Backend directory not found: $BACKEND_DIR"
    echo "Please copy backend first: sudo ./deploy/copy_backend.sh"
    exit 1
fi

cd "$BACKEND_DIR"

echo ""
echo "1. Creating virtual environment..."
if [ -d "$VENV_DIR" ]; then
    echo "  Virtual environment already exists, removing old one..."
    sudo rm -rf "$VENV_DIR"
fi

# Create venv with sudo
sudo python3 -m venv .venv

echo ""
echo "2. Setting permissions..."
sudo chown -R www-data:www-data "$VENV_DIR"
sudo chmod -R 755 "$VENV_DIR"

echo ""
echo "3. Activating virtual environment and installing dependencies..."
# Use the venv python to install packages
sudo "$VENV_DIR/bin/pip" install --upgrade pip

if [ -f "$BACKEND_DIR/requirements.txt" ]; then
    echo "  Installing from requirements.txt..."
    sudo "$VENV_DIR/bin/pip" install -r requirements.txt
    echo "✓ Dependencies installed"
else
    echo "  WARNING: requirements.txt not found"
    echo "  Installing basic packages..."
    sudo "$VENV_DIR/bin/pip" install fastapi uvicorn python-dotenv
fi

echo ""
echo "4. Verifying installation..."
if [ -f "$VENV_DIR/bin/uvicorn" ]; then
    echo "✓ uvicorn installed: $($VENV_DIR/bin/uvicorn --version 2>&1 | head -1)"
else
    echo "✗ uvicorn not found"
    exit 1
fi

echo ""
echo "5. Setting final permissions..."
sudo chown -R www-data:www-data "$BACKEND_DIR"
sudo chmod -R 755 "$BACKEND_DIR"
sudo chmod +x "$VENV_DIR/bin/python"
sudo chmod +x "$VENV_DIR/bin/uvicorn"

echo ""
echo "=========================================="
echo "Virtual Environment Setup Complete!"
echo "=========================================="
echo ""
echo "Virtual environment is ready at: $VENV_DIR"
echo ""
echo "Next steps:"
echo "1. Create .env file if needed:"
echo "   sudo ./deploy/setup_env.sh"
echo ""
echo "2. Create wrapper script and update service:"
echo "   sudo ./deploy/fix_service.sh"
echo ""
echo "3. Start the service:"
echo "   sudo systemctl start back.service"

