#!/bin/bash
# Script to test authentication and access protected routes

echo "=========================================="
echo "Testing Authentication"
echo "=========================================="

API_URL="http://localhost:8000"

echo ""
echo "1. Testing registration (if needed)..."
REGISTER_RESPONSE=$(curl -s -X POST "$API_URL/auth/register/" \
    -H "Content-Type: application/json" \
    -d '{
        "login": "testuser",
        "password": "testpass123",
        "name": "Test User",
        "is_admin": false
    }')

echo "Response: $REGISTER_RESPONSE"

echo ""
echo "2. Testing login..."
LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/auth/token/" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin&password=admin")

echo "Response: $LOGIN_RESPONSE"

# Extract token from response
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo ""
    echo "✗ Failed to get token. Trying alternative method..."
    TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))" 2>/dev/null)
fi

if [ -n "$TOKEN" ]; then
    echo "✓ Token received: ${TOKEN:0:20}..."
    
    echo ""
    echo "3. Testing protected route /order with token..."
    ORDER_RESPONSE=$(curl -s -X GET "$API_URL/order/" \
        -H "Authorization: Bearer $TOKEN")
    
    echo "Response: $ORDER_RESPONSE"
    
    if echo "$ORDER_RESPONSE" | grep -q "Not authenticated"; then
        echo "✗ Still not authenticated - check token format"
    else
        echo "✓ Successfully accessed protected route!"
    fi
else
    echo ""
    echo "✗ Could not extract token from login response"
    echo "Full login response:"
    echo "$LOGIN_RESPONSE"
    echo ""
    echo "Try logging in manually:"
    echo "curl -X POST '$API_URL/auth/token/' \\"
    echo "  -H 'Content-Type: application/x-www-form-urlencoded' \\"
    echo "  -d 'username=admin&password=admin'"
fi

echo ""
echo "=========================================="
echo "Test Complete"
echo "=========================================="
echo ""
echo "Default credentials (from .env_example):"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "To get a token manually:"
echo "curl -X POST '$API_URL/auth/token/' \\"
echo "  -H 'Content-Type: application/x-www-form-urlencoded' \\"
echo "  -d 'username=admin&password=admin'"
echo ""
echo "To use the token:"
echo "curl -X GET '$API_URL/order/' \\"
echo "  -H 'Authorization: Bearer YOUR_TOKEN_HERE'"

