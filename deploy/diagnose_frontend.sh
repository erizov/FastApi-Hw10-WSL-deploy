#!/bin/bash
# Comprehensive frontend diagnosis script

echo "=========================================="
echo "Frontend Diagnosis"
echo "=========================================="

echo ""
echo "1. Checking if frontend files exist on server..."
if [ -f "/var/www/project/front/index.html" ]; then
    echo "✓ index.html exists"
    echo "  First 20 lines:"
    head -20 /var/www/project/front/index.html
else
    echo "✗ index.html NOT found"
    echo "  Frontend is not deployed!"
fi

echo ""
echo "2. Checking Nginx configuration..."
if [ -f "/etc/nginx/sites-available/front.conf" ]; then
    echo "✓ Frontend config exists"
    echo "  Content:"
    cat /etc/nginx/sites-available/front.conf
else
    echo "✗ Frontend config NOT found"
fi

echo ""
echo "3. Checking if frontend site is enabled..."
if [ -L "/etc/nginx/sites-enabled/front.conf" ]; then
    echo "✓ Frontend site is enabled"
else
    echo "✗ Frontend site is NOT enabled"
fi

echo ""
echo "4. Testing Nginx configuration..."
sudo nginx -t 2>&1

echo ""
echo "5. Checking Nginx status..."
sudo systemctl status nginx --no-pager -l | head -15

echo ""
echo "6. Testing HTTP access..."
HTTP_RESPONSE=$(curl -s http://localhost/)
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)

echo "  HTTP Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ]; then
    echo "  ✓ Frontend is accessible"
    echo ""
    echo "  Response preview (first 500 chars):"
    echo "$HTTP_RESPONSE" | head -c 500
    echo ""
    echo ""
    
    # Check if it's HTML
    if echo "$HTTP_RESPONSE" | grep -q "<!DOCTYPE html\|<html"; then
        echo "  ✓ Response is HTML"
    else
        echo "  ✗ Response is NOT HTML - might be JSON error"
        echo "  Full response:"
        echo "$HTTP_RESPONSE"
    fi
else
    echo "  ✗ Frontend is NOT accessible"
fi

echo ""
echo "7. Checking backend API..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/)
echo "  Backend status (port 8000): $BACKEND_STATUS"

echo ""
echo "8. Testing API proxy through Nginx..."
AUTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost/auth/token/ \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=admin")
echo "  /auth/token/ status: $AUTH_STATUS"

echo ""
echo "9. Checking frontend build..."
if [ -d "/mnt/e/Python/FastAPI/10/front/dist" ]; then
    echo "  ✓ Frontend is built"
    echo "  Files in dist:"
    ls -la /mnt/e/Python/FastAPI/10/front/dist | head -10
else
    echo "  ✗ Frontend is NOT built"
fi

echo ""
echo "10. Checking .env.production..."
if [ -f "/mnt/e/Python/FastAPI/10/front/.env.production" ]; then
    echo "  ✓ .env.production exists"
    echo "  Content:"
    cat /mnt/e/Python/FastAPI/10/front/.env.production
else
    echo "  ✗ .env.production NOT found"
fi

echo ""
echo "=========================================="
echo "Diagnosis Complete"
echo "=========================================="
echo ""
echo "Troubleshooting steps:"
echo ""
echo "1. If frontend is not deployed:"
echo "   cd /mnt/e/Python/FastAPI/10/front"
echo "   npm run build"
echo "   sudo cp -r dist/* /var/www/project/front/"
echo ""
echo "2. If Nginx is not configured:"
echo "   sudo cp /mnt/e/Python/FastAPI/10/deploy/front.conf /etc/nginx/sites-available/"
echo "   sudo ln -s /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/"
echo "   sudo nginx -t && sudo systemctl restart nginx"
echo ""
echo "3. Clear browser cache and localStorage:"
echo "   - Press F12"
echo "   - Application -> Clear Storage -> Clear site data"
echo "   - Or manually clear Local Storage"
echo ""
echo "4. Check browser console (F12 -> Console) for JavaScript errors"

