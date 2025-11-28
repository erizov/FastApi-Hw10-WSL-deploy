#!/bin/bash
# Script to fix login page not showing

set -e

echo "=========================================="
echo "Fixing Login Page Issue"
echo "=========================================="

PROJECT_DIR="/mnt/e/Python/FastAPI/10"
FRONTEND_DIR="$PROJECT_DIR/front"
TARGET_DIR="/var/www/project/front"

echo ""
echo "Step 1: Ensuring .env.production is correct..."
cd "$FRONTEND_DIR"
echo "VITE_API_URL=/" > .env.production
echo "✓ .env.production updated"

echo ""
echo "Step 2: Rebuilding frontend..."
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

echo "Building..."
npm run build

if [ ! -d "dist" ]; then
    echo "✗ Build failed!"
    exit 1
fi

echo "✓ Frontend built successfully"

echo ""
echo "Step 3: Deploying to server..."
sudo rm -rf "$TARGET_DIR"/*
sudo cp -r dist/* "$TARGET_DIR/"
sudo chown -R www-data:www-data "$TARGET_DIR"
echo "✓ Frontend deployed"

echo ""
echo "Step 4: Updating Nginx configuration..."
sudo cp "$PROJECT_DIR/deploy/front.conf" /etc/nginx/sites-available/front.conf
sudo ln -sf /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/front.conf

echo ""
echo "Step 5: Testing and restarting Nginx..."
if sudo nginx -t; then
    sudo systemctl restart nginx
    echo "✓ Nginx restarted"
else
    echo "✗ Nginx configuration error"
    exit 1
fi

echo ""
echo "Step 6: Verifying deployment..."
sleep 2
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✓ Frontend is accessible (HTTP $HTTP_STATUS)"
    
    # Check if it's HTML
    RESPONSE=$(curl -s http://localhost/ | head -c 100)
    if echo "$RESPONSE" | grep -q "<!DOCTYPE\|<html"; then
        echo "✓ Response is HTML"
    else
        echo "⚠ Response might not be HTML"
        echo "  Preview: $RESPONSE"
    fi
else
    echo "✗ Frontend not accessible (HTTP $HTTP_STATUS)"
fi

echo ""
echo "=========================================="
echo "Fix Complete!"
echo "=========================================="
echo ""
echo "IMPORTANT: Clear browser cache and localStorage!"
echo ""
echo "1. Open browser: http://localhost/"
echo "2. Press F12 (Developer Tools)"
echo "3. Go to Application tab (Chrome) or Storage tab (Firefox)"
echo "4. Click 'Clear site data' or manually delete Local Storage"
echo "5. Hard refresh: Ctrl+Shift+R (or Cmd+Shift+R on Mac)"
echo ""
echo "If login page still doesn't show:"
echo "- Check browser console (F12 -> Console) for errors"
echo "- Check Network tab to see what requests are being made"
echo "- Verify API_URL in browser console:"
echo "  Open console and type: import.meta.env.VITE_API_URL"

