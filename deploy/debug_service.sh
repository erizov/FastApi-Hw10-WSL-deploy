#!/bin/bash
# Script to debug backend service issues

echo "=========================================="
echo "Debugging Backend Service"
echo "=========================================="

BACKEND_DIR="/var/www/project/back"
VENV_DIR="$BACKEND_DIR/.venv"

echo ""
echo "1. Checking service status..."
sudo systemctl status back.service --no-pager -l

echo ""
echo "2. Recent service logs (last 50 lines)..."
sudo journalctl -u back.service -n 50 --no-pager

echo ""
echo "3. Checking if .env file exists and is readable..."
if [ -f "$BACKEND_DIR/.env" ]; then
    echo "✓ .env file exists"
    sudo ls -la "$BACKEND_DIR/.env"
    echo ""
    echo "First few lines of .env (checking format):"
    sudo head -5 "$BACKEND_DIR/.env"
else
    echo "✗ .env file NOT found"
fi

echo ""
echo "4. Testing Python import manually..."
cd "$BACKEND_DIR"
source "$VENV_DIR/bin/activate"
export PYTHONPATH="$BACKEND_DIR"

echo "Testing app.main import..."
python3 -c "import app.main" 2>&1 || {
    echo "✗ Import failed!"
    echo "Full error:"
    python3 -c "import app.main" 2>&1
}

echo ""
echo "5. Testing uvicorn command manually..."
cd "$BACKEND_DIR"
export PYTHONPATH="$BACKEND_DIR"
timeout 5 "$VENV_DIR/bin/python" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 2>&1 || {
    echo "✗ Uvicorn failed to start!"
    echo "This is expected if it's a configuration issue"
}

echo ""
echo "6. Checking file permissions..."
sudo ls -la "$BACKEND_DIR" | head -10
echo ""
echo "Checking .venv permissions..."
sudo ls -la "$VENV_DIR/bin/python" 2>/dev/null || echo "Python not found in venv"

echo ""
echo "7. Checking if required files exist..."
for file in "app/main.py" "app/config.py" "base/db.sqlite"; do
    if [ -f "$BACKEND_DIR/$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file NOT found"
    fi
done

echo ""
echo "=========================================="
echo "Debug Complete"
echo "=========================================="

