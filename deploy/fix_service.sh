#!/bin/bash
# Quick fix script for 203/EXEC error

set -e

echo "=========================================="
echo "Fixing Backend Service (203/EXEC Error)"
echo "=========================================="

BACKEND_DIR="/var/www/project/back"
VENV_DIR="$BACKEND_DIR/.venv"

# Check if backend directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo "ERROR: Backend directory not found: $BACKEND_DIR"
    echo "Please copy your backend to /var/www/project/back first"
    exit 1
fi

echo ""
echo "Step 1: Creating/checking virtual environment..."
cd "$BACKEND_DIR"

if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

echo "Activating virtual environment..."
source .venv/bin/activate

echo ""
echo "Step 2: Installing/updating dependencies..."
pip install --upgrade pip
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "WARNING: requirements.txt not found, installing basic packages..."
    pip install fastapi uvicorn
fi

echo ""
echo "Step 3: Verifying uvicorn installation..."
if [ ! -f "$VENV_DIR/bin/uvicorn" ]; then
    echo "uvicorn not found, installing..."
    pip install uvicorn
fi

chmod +x "$VENV_DIR/bin/uvicorn"
echo "✓ uvicorn is ready: $VENV_DIR/bin/uvicorn"

echo ""
echo "Step 4: Setting permissions..."
sudo chown -R www-data:www-data "$BACKEND_DIR"
sudo chmod -R 755 "$BACKEND_DIR"
sudo chmod +x "$VENV_DIR/bin/uvicorn"

echo ""
echo "Step 5: Testing uvicorn..."
if "$VENV_DIR/bin/uvicorn" --version > /dev/null 2>&1; then
    echo "✓ uvicorn test successful"
    "$VENV_DIR/bin/uvicorn" --version
else
    echo "✗ uvicorn test failed"
    exit 1
fi

echo ""
echo "Step 6: Updating systemd service..."
# Backup existing service file if it exists
if [ -f "/etc/systemd/system/back.service" ]; then
    echo "Backing up existing service file..."
    sudo cp /etc/systemd/system/back.service /etc/systemd/system/back.service.bak
fi

# Create wrapper script for starting backend
echo "Creating wrapper script for backend startup..."
sudo tee /var/www/project/back/start_backend.sh > /dev/null <<'WRAPPEREOF'
#!/bin/bash
# Wrapper script to start backend with correct PYTHONPATH

cd /var/www/project/back
export PYTHONPATH=/var/www/project/back
exec /var/www/project/back/.venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
WRAPPEREOF

sudo chmod +x /var/www/project/back/start_backend.sh
sudo chown www-data:www-data /var/www/project/back/start_backend.sh
echo "✓ Wrapper script created"

# Create service file directly (most reliable approach)
echo "Creating systemd service file..."
sudo tee /etc/systemd/system/back.service > /dev/null <<'SERVICEEOF'
[Unit]
Description=FastAPI Backend Service
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/project/back
Environment="PATH=/var/www/project/back/.venv/bin:/usr/local/bin:/usr/bin:/bin"
Environment="PYTHONPATH=/var/www/project/back"
# Use wrapper script to ensure PYTHONPATH is set correctly
ExecStart=/var/www/project/back/start_backend.sh

Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
SERVICEEOF

echo "✓ Service file created"

# Check if .env file exists
echo ""
echo "Step 7: Checking .env file..."
if [ ! -f "$BACKEND_DIR/.env" ]; then
    echo "WARNING: .env file not found in $BACKEND_DIR"
    echo "Searching for .env_example..."
    
    ENV_EXAMPLE=""
    # Try to find .env_example in several locations
    for possible_path in \
        "$BACKEND_DIR/.env_example" \
        "/mnt/e/Python/FastAPI/10/back/.env_example" \
        "$HOME/project/back/.env_example" \
        "$(pwd)/back/.env_example"; do
        if [ -f "$possible_path" ]; then
            ENV_EXAMPLE="$possible_path"
            echo "  Found .env_example at: $ENV_EXAMPLE"
            break
        fi
    done
    
    if [ -n "$ENV_EXAMPLE" ]; then
        echo "Creating .env from .env_example..."
        sudo cp "$ENV_EXAMPLE" "$BACKEND_DIR/.env"
        # Fix spaces around = (python-dotenv doesn't like spaces)
        sudo sed -i 's/ = /=/g' "$BACKEND_DIR/.env"
        sudo chown www-data:www-data "$BACKEND_DIR/.env"
        sudo chmod 600 "$BACKEND_DIR/.env"
        echo "✓ .env file created from .env_example (spaces around = removed)"
        echo "  IMPORTANT: Please edit $BACKEND_DIR/.env and set your configuration!"
        echo "  You can edit it with: sudo nano $BACKEND_DIR/.env"
    else
        echo "✗ .env_example not found in common locations."
        echo "  Creating a basic .env file template..."
        sudo tee "$BACKEND_DIR/.env" > /dev/null <<'ENVEOF'
# .env file for FastAPI Backend
# Please fill in the required values

# OpenAI
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4o-mini

# Auth
AUTH_SECRET_KEY=your_secret_key_here
AUTH_TOKEN_EXPIRE_MINUTES=30
AUTH_LOGIN=admin
AUTH_PASSWORD=admin

# Database
DATABASE_URL=sqlite+aiosqlite:///./base/db.sqlite

# Base knowledge
BASE_LOCAL_PATH=base/База знаний массажных кресел.docx
BASE_LOCAL_INDEX=base/index

# Logging
LOG_PRINT=1
LOG_PRINT_DB=0
LOG_PRINT_STEP=0
ENVEOF
        sudo chown www-data:www-data "$BACKEND_DIR/.env"
        sudo chmod 600 "$BACKEND_DIR/.env"
        echo "✓ Basic .env file created"
        echo "  IMPORTANT: Please edit $BACKEND_DIR/.env and set your configuration!"
        echo "  You can edit it with: sudo nano $BACKEND_DIR/.env"
    fi
else
    echo "✓ .env file exists"
    sudo chown www-data:www-data "$BACKEND_DIR/.env"
fi

echo ""
echo "Step 7: Reloading systemd..."
sudo systemctl daemon-reload

echo ""
echo "=========================================="
echo "Fix Complete!"
echo "=========================================="
echo ""
echo "Now try starting the service:"
echo "  sudo systemctl start back.service"
echo "  sudo systemctl status back.service"
echo ""
echo "If it still fails, check logs:"
echo "  sudo journalctl -u back.service -n 50"

