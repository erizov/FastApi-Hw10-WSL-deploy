#!/bin/bash
# Script to copy backend to /var/www/project/back

set -e

echo "=========================================="
echo "Copying Backend to Server"
echo "=========================================="

# Find the source backend directory
SOURCE_BACK=""
for possible_path in \
    "/mnt/e/Python/FastAPI/10/back" \
    "$HOME/project/back" \
    "$(pwd)/back" \
    "$(dirname "$(pwd)")/back"; do
    if [ -d "$possible_path" ] && [ -d "$possible_path/app" ]; then
        SOURCE_BACK="$possible_path"
        echo "Found source backend: $SOURCE_BACK"
        break
    fi
done

if [ -z "$SOURCE_BACK" ]; then
    echo "ERROR: Could not find backend directory with app/ subdirectory"
    echo "Please specify the path to your back directory:"
    read -p "Path: " SOURCE_BACK
    if [ ! -d "$SOURCE_BACK" ] || [ ! -d "$SOURCE_BACK/app" ]; then
        echo "ERROR: Invalid path or app/ directory not found"
        exit 1
    fi
fi

TARGET_DIR="/var/www/project/back"

echo ""
echo "Source: $SOURCE_BACK"
echo "Target: $TARGET_DIR"

# Create target directory if it doesn't exist
sudo mkdir -p "$TARGET_DIR"

echo ""
echo "Copying files..."
echo "This may take a moment..."

# Copy all files, preserving structure
sudo cp -r "$SOURCE_BACK"/* "$TARGET_DIR/" 2>/dev/null || {
    # If cp -r fails, try rsync
    echo "Using rsync instead..."
    sudo rsync -av "$SOURCE_BACK/" "$TARGET_DIR/"
}

# Set permissions
echo ""
echo "Setting permissions..."
sudo chown -R www-data:www-data "$TARGET_DIR"
sudo chmod -R 755 "$TARGET_DIR"

# Make sure .venv has correct permissions if it exists
if [ -d "$TARGET_DIR/.venv" ]; then
    sudo chown -R www-data:www-data "$TARGET_DIR/.venv"
    sudo chmod -R 755 "$TARGET_DIR/.venv"
fi

echo ""
echo "Verifying copy..."
if [ -d "$TARGET_DIR/app" ] && [ -f "$TARGET_DIR/app/main.py" ]; then
    echo "✓ Backend copied successfully"
    echo "  - app/ directory: $(sudo ls -d "$TARGET_DIR/app" 2>/dev/null | wc -l) found"
    echo "  - main.py: $(sudo ls "$TARGET_DIR/app/main.py" 2>/dev/null | wc -l) found"
else
    echo "✗ ERROR: Copy verification failed"
    echo "  Checking what was copied:"
    sudo ls -la "$TARGET_DIR" | head -10
    exit 1
fi

echo ""
echo "=========================================="
echo "Backend Copy Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Make sure .env file exists:"
echo "   sudo ls -la $TARGET_DIR/.env"
echo ""
echo "2. If .env is missing, create it (run from project root):"
echo "   cd /mnt/e/Python/FastAPI/10  # or your project path"
echo "   chmod +x deploy/setup_env.sh"
echo "   sudo ./deploy/setup_env.sh"
echo ""
echo "3. Set up virtual environment (run from project root):"
echo "   cd /mnt/e/Python/FastAPI/10  # or your project path"
echo "   chmod +x deploy/setup_venv.sh"
echo "   sudo ./deploy/setup_venv.sh"
echo ""
echo "4. Create wrapper script and update service (run from project root):"
echo "   cd /mnt/e/Python/FastAPI/10  # or your project path"
echo "   chmod +x deploy/fix_service.sh"
echo "   sudo ./deploy/fix_service.sh"
echo ""
echo "5. Start the service:"
echo "   sudo systemctl start back.service"
echo "   sudo systemctl status back.service"

