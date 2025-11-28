#!/bin/bash
# Script to check frontend deployment

echo "=========================================="
echo "Checking Frontend Deployment"
echo "=========================================="

echo ""
echo "1. Checking if frontend is built..."
if [ -d "/mnt/e/Python/FastAPI/10/front/dist" ]; then
    echo "✓ Frontend build directory exists"
    echo "  Files in dist:"
    ls -la /mnt/e/Python/FastAPI/10/front/dist | head -10
else
    echo "✗ Frontend is NOT built"
    echo "  Run: cd /mnt/e/Python/FastAPI/10/front && npm run build"
fi

echo ""
echo "2. Checking if frontend is deployed to server..."
if [ -d "/var/www/project/front/dist" ]; then
    echo "✓ Frontend is deployed"
    echo "  Files in /var/www/project/front/dist:"
    ls -la /var/www/project/front/dist | head -10
else
    echo "✗ Frontend is NOT deployed to server"
    echo "  Run: sudo cp -r /mnt/e/Python/FastAPI/10/front/dist /var/www/project/front/"
fi

echo ""
echo "3. Checking Nginx configuration..."
if [ -f "/etc/nginx/sites-available/front.conf" ]; then
    echo "✓ Frontend Nginx config exists"
    echo "  Content:"
    cat /etc/nginx/sites-available/front.conf
else
    echo "✗ Frontend Nginx config NOT found"
    echo "  Run: sudo cp /mnt/e/Python/FastAPI/10/deploy/front.conf /etc/nginx/sites-available/"
fi

echo ""
echo "4. Checking if Nginx site is enabled..."
if [ -L "/etc/nginx/sites-enabled/front.conf" ]; then
    echo "✓ Frontend site is enabled"
else
    echo "✗ Frontend site is NOT enabled"
    echo "  Run: sudo ln -s /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/"
fi

echo ""
echo "5. Testing Nginx configuration..."
sudo nginx -t 2>&1

echo ""
echo "6. Checking Nginx status..."
sudo systemctl status nginx --no-pager -l | head -10

echo ""
echo "7. Testing HTTP access to frontend..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
echo "  HTTP Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "200" ]; then
    echo "  ✓ Frontend is accessible"
    echo "  Content preview:"
    curl -s http://localhost/ | head -20
else
    echo "  ✗ Frontend is NOT accessible (Status: $HTTP_STATUS)"
fi

echo ""
echo "=========================================="
echo "Diagnosis Complete"
echo "=========================================="
echo ""
echo "If frontend is not showing login page:"
echo "1. Clear browser localStorage (F12 -> Application -> Local Storage -> Clear)"
echo "2. Check browser console for errors (F12 -> Console)"
echo "3. Check API_URL in .env.production file"
echo "4. Make sure frontend is built and deployed"

