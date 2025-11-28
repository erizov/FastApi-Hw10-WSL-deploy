#!/bin/bash
# Script to check what Nginx is actually returning

echo "=========================================="
echo "Checking Nginx Response"
echo "=========================================="

echo ""
echo "1. Full HTTP response:"
echo "----------------------------------------"
curl -s http://localhost/ | head -50
echo "----------------------------------------"

echo ""
echo "2. HTTP headers:"
curl -s -I http://localhost/ | head -20

echo ""
echo "3. Checking if it's default Nginx page:"
RESPONSE=$(curl -s http://localhost/ | head -c 200)
if echo "$RESPONSE" | grep -q "Welcome to nginx"; then
    echo "✗ Still showing default Nginx page!"
    echo ""
    echo "Checking enabled sites:"
    ls -la /etc/nginx/sites-enabled/
    echo ""
    echo "Checking frontend config:"
    cat /etc/nginx/sites-available/front.conf | head -10
else
    echo "✓ Not default page"
fi

echo ""
echo "4. Checking if it's frontend HTML:"
if echo "$RESPONSE" | grep -q "<!DOCTYPE html\|<html\|<div id=\"root\""; then
    echo "✓ Looks like frontend HTML"
else
    echo "⚠ Doesn't look like frontend HTML"
    echo "  First 200 chars: $RESPONSE"
fi

echo ""
echo "5. Checking if index.html exists:"
if [ -f "/var/www/project/front/index.html" ]; then
    echo "✓ index.html exists"
    echo "  First 20 lines:"
    head -20 /var/www/project/front/index.html
else
    echo "✗ index.html NOT found!"
    echo "  Checking what's in /var/www/project/front/:"
    ls -la /var/www/project/front/ | head -10
fi

echo ""
echo "6. Checking Nginx error log:"
sudo tail -20 /var/log/nginx/error.log 2>/dev/null || echo "No error log or permission denied"

echo ""
echo "=========================================="

