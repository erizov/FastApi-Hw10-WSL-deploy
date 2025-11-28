#!/bin/bash
# Script to fix frontend API configuration

echo "=========================================="
echo "Fixing Frontend API Configuration"
echo "=========================================="

PROJECT_DIR="/mnt/e/Python/FastAPI/10"
FRONTEND_DIR="$PROJECT_DIR/front"

echo ""
echo "Option 1: Use relative paths (recommended)"
echo "  This will make frontend use the same domain for API calls"
echo ""
echo "Option 2: Update .env.production to use / instead of :8000"
echo "  This will route API calls through Nginx proxy"
echo ""

read -p "Choose option (1 or 2, default 2): " OPTION
OPTION=${OPTION:-2}

if [ "$OPTION" = "1" ]; then
    echo ""
    echo "Updating .env.production to use relative paths..."
    cd "$FRONTEND_DIR"
    echo "VITE_API_URL=/" > .env.production
    echo "✓ Updated .env.production"
    echo ""
    echo "Now rebuild frontend:"
    echo "  cd $FRONTEND_DIR"
    echo "  npm run build"
    echo "  sudo cp -r dist/* /var/www/project/front/"
else
    echo ""
    echo "Updating .env.production to use root path..."
    cd "$FRONTEND_DIR"
    echo "VITE_API_URL=/" > .env.production
    echo "✓ Updated .env.production to use /"
    echo ""
    echo "Updating Nginx configuration to proxy API requests..."
    sudo cp "$PROJECT_DIR/deploy/front.conf" /etc/nginx/sites-available/front.conf
    sudo ln -sf /etc/nginx/sites-available/front.conf /etc/nginx/sites-enabled/front.conf
    
    echo ""
    echo "Testing Nginx configuration..."
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
    echo "Now rebuild frontend with new API URL:"
    echo "  cd $FRONTEND_DIR"
    echo "  npm run build"
    echo "  sudo cp -r dist/* /var/www/project/front/"
fi

echo ""
echo "=========================================="
echo "Configuration Updated!"
echo "=========================================="
echo ""
echo "After rebuilding frontend, API calls will go through:"
echo "  http://localhost/auth/token/ (instead of http://localhost:8000/auth/token/)"
echo ""
echo "This will be proxied by Nginx to backend on port 8000"

