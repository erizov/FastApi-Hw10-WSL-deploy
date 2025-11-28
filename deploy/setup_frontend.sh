#!/bin/bash
# Script to setup and deploy frontend

set -e

echo "=========================================="
echo "Setting up Frontend"
echo "=========================================="

PROJECT_DIR="/mnt/e/Python/FastAPI/10"
FRONTEND_DIR="$PROJECT_DIR/front"
TARGET_DIR="/var/www/project/front"

echo ""
echo "Step 1: Checking .env files..."
cd "$FRONTEND_DIR"

if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    echo "VITE_API_URL=http://localhost:8000/" > .env
    echo "✓ .env created"
else
    echo "✓ .env exists"
fi

if [ ! -f ".env.production" ]; then
    echo "Creating .env.production file..."
    echo "VITE_API_URL=http://localhost:8000/" > .env.production
    echo "✓ .env.production created"
else
    echo "✓ .env.production exists"
    echo "Current API_URL:"
    grep VITE_API_URL .env.production
fi

echo ""
echo "Step 2: Installing dependencies..."
if [ ! -d "node_modules" ]; then
    npm install
    echo "✓ Dependencies installed"
else
    echo "✓ Dependencies already installed"
fi

echo ""
echo "Step 3: Building frontend..."
npm run build

if [ -d "dist" ]; then
    echo "✓ Frontend built successfully"
    echo "  Build output:"
    ls -la dist/ | head -10
else
    echo "✗ Build failed - dist directory not found"
    exit 1
fi

echo ""
echo "Step 4: Deploying to server..."
sudo mkdir -p "$TARGET_DIR"
sudo cp -r dist/* "$TARGET_DIR/"
sudo chown -R www-data:www-data "$TARGET_DIR"
echo "✓ Frontend deployed to $TARGET_DIR"

echo ""
echo "Step 5: Setting up Nginx..."
if [ ! -f "/etc/nginx/sites-available/front.conf" ]; then
    echo "Creating Nginx configuration..."
    sudo cp "$PROJECT_DIR/deploy/front.conf" /etc/nginx/sites-available/
    echo "✓ Nginx config created"
else
    echo "✓ Nginx config exists"
fi

if [ ! -L "/etc/nginx/sites-enabled/front.conf" ]; then
    echo "Enabling Nginx site..."
    sudo ln -s /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/
    echo "✓ Nginx site enabled"
else
    echo "✓ Nginx site already enabled"
fi

echo ""
echo "Step 6: Testing Nginx configuration..."
if sudo nginx -t; then
    echo "✓ Nginx configuration is valid"
    echo "Restarting Nginx..."
    sudo systemctl restart nginx
    echo "✓ Nginx restarted"
else
    echo "✗ Nginx configuration has errors"
    exit 1
fi

echo ""
echo "=========================================="
echo "Frontend Setup Complete!"
echo "=========================================="
echo ""
echo "Frontend should be available at:"
echo "  http://localhost/"
echo ""
echo "If login page doesn't show:"
echo "1. Clear browser localStorage:"
echo "   - Press F12"
echo "   - Go to Application/Storage -> Local Storage"
echo "   - Clear all items"
echo "   - Refresh page"
echo ""
echo "2. Check browser console for errors (F12 -> Console)"
echo ""
echo "3. Verify API is accessible:"
echo "   curl http://localhost:8000/"
echo ""
echo "4. Check Nginx logs if needed:"
echo "   sudo tail -f /var/log/nginx/error.log"

