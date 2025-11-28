#!/bin/bash
# Script to check and fix service configuration

echo "=========================================="
echo "Checking Backend Service Configuration"
echo "=========================================="

BACKEND_DIR="/var/www/project/back"
VENV_DIR="$BACKEND_DIR/.venv"
UVICORN_PATH="$VENV_DIR/bin/uvicorn"

echo ""
echo "1. Checking if backend directory exists..."
if [ -d "$BACKEND_DIR" ]; then
    echo "   ✓ Backend directory exists: $BACKEND_DIR"
else
    echo "   ✗ Backend directory NOT found: $BACKEND_DIR"
    echo "   Please copy the backend to /var/www/project/back"
    exit 1
fi

echo ""
echo "2. Checking if virtual environment exists..."
if [ -d "$VENV_DIR" ]; then
    echo "   ✓ Virtual environment exists: $VENV_DIR"
else
    echo "   ✗ Virtual environment NOT found: $VENV_DIR"
    echo "   Creating virtual environment..."
    cd "$BACKEND_DIR"
    python3 -m venv .venv
    source .venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    echo "   ✓ Virtual environment created"
fi

echo ""
echo "3. Checking if uvicorn exists..."
if [ -f "$UVICORN_PATH" ]; then
    echo "   ✓ uvicorn found: $UVICORN_PATH"
    ls -la "$UVICORN_PATH"
else
    echo "   ✗ uvicorn NOT found: $UVICORN_PATH"
    echo "   Installing dependencies..."
    cd "$BACKEND_DIR"
    source .venv/bin/activate
    pip install uvicorn
    echo "   ✓ Dependencies installed"
fi

echo ""
echo "4. Testing uvicorn execution..."
cd "$BACKEND_DIR"
source .venv/bin/activate
if "$UVICORN_PATH" --version > /dev/null 2>&1; then
    echo "   ✓ uvicorn is executable"
    "$UVICORN_PATH" --version
else
    echo "   ✗ uvicorn is NOT executable"
    echo "   Checking permissions..."
    ls -la "$UVICORN_PATH"
    chmod +x "$UVICORN_PATH"
    echo "   ✓ Permissions fixed"
fi

echo ""
echo "5. Checking Python path..."
PYTHON_PATH=$(which python3)
echo "   Python3 path: $PYTHON_PATH"
if [ -f "$PYTHON_PATH" ]; then
    echo "   ✓ Python3 found"
else
    echo "   ✗ Python3 NOT found"
    exit 1
fi

echo ""
echo "6. Checking permissions..."
if [ -r "$BACKEND_DIR" ] && [ -x "$BACKEND_DIR" ]; then
    echo "   ✓ Backend directory is readable and executable"
else
    echo "   ✗ Permission issues with backend directory"
    echo "   Fixing permissions..."
    sudo chown -R www-data:www-data "$BACKEND_DIR"
    sudo chmod -R 755 "$BACKEND_DIR"
    echo "   ✓ Permissions fixed"
fi

echo ""
echo "=========================================="
echo "Service Check Complete"
echo "=========================================="
echo ""
echo "If all checks passed, try starting the service:"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl start back.service"
echo "  sudo systemctl status back.service"

