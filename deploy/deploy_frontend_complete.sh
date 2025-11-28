#!/bin/bash
# Complete frontend deployment script

set -e

echo "=========================================="
echo "Complete Frontend Deployment"
echo "=========================================="

PROJECT_DIR="/mnt/e/Python/FastAPI/10"
FRONTEND_DIR="$PROJECT_DIR/front"
TARGET_DIR="/var/www/project/front"

echo ""
echo "Step 1: Checking if frontend is built..."
cd "$FRONTEND_DIR"

if [ ! -d "dist" ]; then
    echo "Frontend is not built. Building now..."
    
    # Check .env files
    if [ ! -f ".env.production" ]; then
        echo "Creating .env.production..."
        echo "VITE_API_URL=/" > .env.production
    fi
    
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi
    
    echo "Building frontend..."
    npm run build
else
    echo "✓ Frontend is already built"
fi

if [ ! -d "dist" ]; then
    echo "✗ Build failed - dist directory not created"
    exit 1
fi

echo ""
echo "Step 2: Checking dist contents..."
echo "Files in dist:"
ls -la dist/ | head -10

if [ ! -f "dist/index.html" ]; then
    echo "✗ index.html not found in dist!"
    exit 1
fi

echo "✓ index.html found in dist"

echo ""
echo "Step 3: Deploying to server..."
sudo mkdir -p "$TARGET_DIR"
echo "Cleaning target directory..."
sudo rm -rf "$TARGET_DIR"/*

echo "Copying files..."
sudo cp -r dist/* "$TARGET_DIR/"

echo "Setting permissions..."
sudo chown -R www-data:www-data "$TARGET_DIR"
sudo chmod -R 755 "$TARGET_DIR"

echo "✓ Files deployed"

echo ""
echo "Step 4: Verifying deployment..."
if [ -f "$TARGET_DIR/index.html" ]; then
    echo "✓ index.html deployed successfully"
    echo "  Location: $TARGET_DIR/index.html"
    echo "  Size: $(du -h $TARGET_DIR/index.html | cut -f1)"
else
    echo "✗ index.html NOT found after deployment!"
    exit 1
fi

echo ""
echo "Step 5: Updating Nginx configuration..."
# Check if files are in dist/ or directly in front/
if [ -f "$TARGET_DIR/index.html" ]; then
    # Files are directly in front/, update config
    echo "Files are in $TARGET_DIR (not in dist/)"
    echo "Updating Nginx config to use correct path..."
    
    # Create/update front.conf with correct path
    sudo tee /etc/nginx/sites-available/front.conf > /dev/null <<'NGINXEOF'
server {
    listen 80;
    server_name localhost;

    root /var/www/project/front;
    index index.html;

    # Proxy API requests to backend
    location /auth/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /base/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /lead/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /dialog/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /order/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # For SPA: redirect all paths to index.html
    location / {
        try_files $uri /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
NGINXEOF
    echo "✓ Nginx config updated"
fi

echo ""
echo "Step 6: Disabling default Nginx site..."
sudo rm -f /etc/nginx/sites-enabled/default
echo "✓ Default site disabled"

echo ""
echo "Step 7: Enabling frontend site..."
sudo ln -sf /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/front.conf
echo "✓ Frontend site enabled"

echo ""
echo "Step 8: Testing Nginx configuration..."
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
echo "Step 9: Testing frontend access..."
sleep 2
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
echo "HTTP Status: $HTTP_STATUS"

if [ "$HTTP_STATUS" = "200" ]; then
    RESPONSE=$(curl -s http://localhost/ | head -c 300)
    if echo "$RESPONSE" | grep -q "Welcome to nginx"; then
        echo "✗ Still showing default page"
    elif echo "$RESPONSE" | grep -q "<!DOCTYPE\|<html\|<div id=\"root\""; then
        echo "✓ Frontend is accessible!"
        echo "  Response preview:"
        echo "$RESPONSE" | head -5
    else
        echo "⚠ Unexpected response"
    fi
else
    echo "✗ Frontend not accessible (HTTP $HTTP_STATUS)"
fi

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Frontend should now be available at:"
echo "  http://localhost/"
echo ""
echo "If you still see 'Welcome to nginx':"
echo "1. Clear browser cache: Ctrl+Shift+R"
echo "2. Check: curl http://localhost/ | head -20"
echo "3. Check Nginx logs: sudo tail -f /var/log/nginx/error.log"

