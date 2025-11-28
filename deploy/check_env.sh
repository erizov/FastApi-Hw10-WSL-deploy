#!/bin/bash
# Script to check and fix .env file format

BACKEND_DIR="/var/www/project/back"
ENV_FILE="$BACKEND_DIR/.env"

echo "=========================================="
echo "Checking .env file format"
echo "=========================================="

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: .env file not found at $ENV_FILE"
    exit 1
fi

echo ""
echo "Current .env file content:"
echo "----------------------------------------"
sudo cat "$ENV_FILE"
echo "----------------------------------------"

echo ""
echo "Checking for common issues..."

# Check for spaces around =
if sudo grep -q " = " "$ENV_FILE"; then
    echo "⚠ WARNING: Found spaces around '=' in .env file"
    echo "  This can cause issues. Fixing..."
    
    # Create a backup
    sudo cp "$ENV_FILE" "$ENV_FILE.bak"
    
    # Remove spaces around = (but keep spaces in values if they're quoted)
    sudo sed -i 's/ = /=/g' "$ENV_FILE"
    
    echo "✓ Fixed spaces around '='"
fi

# Check for required variables
REQUIRED_VARS=(
    "OPENAI_API_KEY"
    "OPENAI_MODEL"
    "AUTH_SECRET_KEY"
    "AUTH_TOKEN_EXPIRE_MINUTES"
    "AUTH_LOGIN"
    "AUTH_PASSWORD"
    "DATABASE_URL"
    "BASE_LOCAL_PATH"
    "BASE_LOCAL_INDEX"
)

echo ""
echo "Checking required variables..."
MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
    if sudo grep -q "^${var}=" "$ENV_FILE"; then
        echo "✓ $var is set"
    else
        echo "✗ $var is MISSING"
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo ""
    echo "WARNING: Missing required variables:"
    printf '  - %s\n' "${MISSING_VARS[@]}"
fi

echo ""
echo "Testing Python config loading..."
cd "$BACKEND_DIR"
source "$BACKEND_DIR/.venv/bin/activate" 2>/dev/null || {
    echo "ERROR: Cannot activate virtual environment"
    exit 1
}

export PYTHONPATH="$BACKEND_DIR"

python3 << 'PYEOF'
import os
import sys

# Change to backend directory
os.chdir('/var/www/project/back')

try:
    from app.config import settings
    print("✓ Config loaded successfully")
    print(f"  OPENAI_MODEL: {settings.OPENAI_MODEL}")
    print(f"  DATABASE_URL: {settings.DATABASE_URL[:50]}...")
except Exception as e:
    print(f"✗ Failed to load config: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
PYEOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ .env file is valid and can be loaded"
else
    echo ""
    echo "✗ .env file has issues that prevent config loading"
    echo "  Please check the errors above and fix the .env file"
fi

