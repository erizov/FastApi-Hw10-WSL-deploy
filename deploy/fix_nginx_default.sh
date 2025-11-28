#!/bin/bash
# Script to fix Nginx default page issue

set -e

echo "=========================================="
echo "Fixing Nginx Default Page Issue"
echo "=========================================="

echo ""
echo "Step 1: Disabling default Nginx site..."
if [ -L "/etc/nginx/sites-enabled/default" ]; then
    sudo rm /etc/nginx/sites-enabled/default
    echo "✓ Default site disabled"
elif [ -f "/etc/nginx/sites-enabled/default" ]; then
    sudo rm /etc/nginx/sites-enabled/default
    echo "✓ Default site removed"
else
    echo "✓ Default site already disabled"
fi

echo ""
echo "Step 2: Ensuring frontend configuration exists..."
if [ ! -f "/etc/nginx/sites-available/front.conf" ]; then
    echo "Creating frontend configuration..."
    sudo cp /mnt/e/Python/FastAPI/10/deploy/front.conf /etc/nginx/sites-available/front.conf
    echo "✓ Frontend config created"
else
    echo "✓ Frontend config exists"
fi

echo ""
echo "Step 3: Enabling frontend site..."
sudo ln -sf /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/front.conf
echo "✓ Frontend site enabled"

echo ""
echo "Step 4: Checking enabled sites..."
echo "Enabled Nginx sites:"
ls -la /etc/nginx/sites-enabled/

echo ""
echo "Step 5: Testing Nginx configuration..."
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
echo "Step 6: Verifying frontend files..."
if [ -f "/var/www/project/front/index.html" ]; then
    echo "✓ Frontend index.html exists"
else
    echo "✗ Frontend index.html NOT found!"
    echo "  You need to build and deploy frontend:"
    echo "  cd /mnt/e/Python/FastAPI/10/front"
    echo "  npm run build"
    echo "  sudo cp -r dist/* /var/www/project/front/"
fi

echo ""
echo "Step 7: Testing HTTP access..."
sleep 2
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    RESPONSE=$(curl -s http://localhost/ | head -c 200)
    if echo "$RESPONSE" | grep -q "Welcome to nginx"; then
        echo "✗ Still showing default Nginx page!"
        echo "  Response preview: $RESPONSE"
        echo ""
        echo "Troubleshooting:"
        echo "1. Check enabled sites: ls -la /etc/nginx/sites-enabled/"
        echo "2. Check Nginx error log: sudo tail -f /var/log/nginx/error.log"
        echo "3. Verify frontend files: ls -la /var/www/project/front/"
    elif echo "$RESPONSE" | grep -q "<!DOCTYPE\|<html\|<div id=\"root\""; then
        echo "✓ Frontend is now showing!"
    else
        echo "⚠ Unexpected response"
        echo "  Preview: $RESPONSE"
    fi
else
    echo "✗ Frontend not accessible (HTTP $HTTP_STATUS)"
fi

echo ""
echo "=========================================="
echo "Fix Complete!"
echo "=========================================="

