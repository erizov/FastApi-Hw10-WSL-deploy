#!/bin/bash
# Script to test backend import before starting service

echo "=========================================="
echo "Testing Backend Import"
echo "=========================================="

BACKEND_DIR="/var/www/project/back"
VENV_DIR="$BACKEND_DIR/.venv"

cd "$BACKEND_DIR"

echo ""
echo "1. Activating virtual environment..."
source "$VENV_DIR/bin/activate"

echo ""
echo "2. Setting PYTHONPATH..."
export PYTHONPATH="$BACKEND_DIR"

echo ""
echo "3. Testing Python import..."
python3 -c "import app.main; print('✓ app.main imported successfully')" || {
    echo "✗ Failed to import app.main"
    echo ""
    echo "Checking Python path..."
    python3 -c "import sys; print('\n'.join(sys.path))"
    exit 1
}

echo ""
echo "4. Testing uvicorn import..."
python3 -c "import uvicorn; print('✓ uvicorn imported successfully')" || {
    echo "✗ Failed to import uvicorn"
    exit 1
}

echo ""
echo "5. Testing direct uvicorn command..."
"$VENV_DIR/bin/python" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 &
UVICORN_PID=$!
sleep 3

if ps -p $UVICORN_PID > /dev/null; then
    echo "✓ uvicorn started successfully (PID: $UVICORN_PID)"
    echo "  Stopping test server..."
    kill $UVICORN_PID
    wait $UVICORN_PID 2>/dev/null
else
    echo "✗ uvicorn failed to start"
    exit 1
fi

echo ""
echo "=========================================="
echo "All tests passed! Backend is ready."
echo "=========================================="

