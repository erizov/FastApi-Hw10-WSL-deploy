#!/bin/bash
# Script to fix Nginx configuration conflict

set -e

echo "=========================================="
echo "Fixing Nginx Configuration Conflict"
echo "=========================================="

echo ""
echo "Problem: Both frontend and backend configs use 'localhost'"
echo "Solution: Backend will use 'api.localhost', frontend uses 'localhost'"
echo ""

echo "Step 1: Updating backend configuration..."
sudo cp /mnt/e/Python/FastAPI/10/deploy/back.conf /etc/nginx/sites-available/back.conf
echo "✓ Backend config updated (now uses api.localhost only)"

echo ""
echo "Step 2: Ensuring frontend configuration is correct..."
sudo cp /mnt/e/Python/FastAPI/10/deploy/front.conf /etc/nginx/sites-available/front.conf
echo "✓ Frontend config updated (uses localhost)"

echo ""
echo "Step 3: Enabling both sites..."
sudo ln -sf /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/front.conf
sudo ln -sf /etc/nginx/sites-available/back.conf /etc/nginx/sites-enabled/back.conf
echo "✓ Both sites enabled"

echo ""
echo "Step 4: Disabling default site..."
sudo rm -f /etc/nginx/sites-enabled/default
echo "✓ Default site disabled"

echo ""
echo "Step 5: Checking enabled sites..."
echo "Enabled sites:"
ls -la /etc/nginx/sites-enabled/

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
echo "Step 7: Testing frontend (localhost)..."
sleep 2
FRONTEND_RESPONSE=$(curl -s http://localhost/ | head -c 200)
if echo "$FRONTEND_RESPONSE" | grep -q "<!DOCTYPE\|<html\|<div id=\"root\""; then
    echo "✓ Frontend is accessible at http://localhost/"
else
    echo "✗ Frontend not working"
    echo "  Response: $FRONTEND_RESPONSE"
fi

echo ""
echo "Step 8: Testing backend (api.localhost)..."
BACKEND_RESPONSE=$(curl -s http://api.localhost/ | head -c 200)
if echo "$BACKEND_RESPONSE" | grep -q "Hello, World"; then
    echo "✓ Backend is accessible at http://api.localhost/"
else
    echo "⚠ Backend response: $BACKEND_RESPONSE"
fi

echo ""
echo "=========================================="
echo "Fix Complete!"
echo "=========================================="
echo ""
echo "Now:"
echo "  - Frontend: http://localhost/"
echo "  - Backend API: http://api.localhost/"
echo ""
echo "But frontend needs to use relative paths or api.localhost"
echo "Update frontend .env.production:"
echo "  VITE_API_URL=http://api.localhost/"
echo ""
echo "Then rebuild frontend:"
echo "  cd /mnt/e/Python/FastAPI/10/front"
echo "  npm run build"
echo "  sudo cp -r dist/* /var/www/project/front/"

