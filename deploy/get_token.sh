#!/bin/bash
# Script to get authentication token and show how to use it

API_URL="http://localhost:8000"
USERNAME="${1:-admin}"
PASSWORD="${2:-admin}"

echo "=========================================="
echo "Getting Authentication Token"
echo "=========================================="

echo ""
echo "Requesting token for user: $USERNAME"
echo ""

RESPONSE=$(curl -s -X POST "$API_URL/auth/token/" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$USERNAME&password=$PASSWORD")

# Try to extract token using Python (more reliable)
TOKEN=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('access_token', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    # Fallback: try grep
    TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
fi

if [ -n "$TOKEN" ]; then
    echo "✓ Token received successfully!"
    echo ""
    echo "Your token:"
    echo "$TOKEN"
    echo ""
    echo "=========================================="
    echo "How to use this token:"
    echo "=========================================="
    echo ""
    echo "1. In curl command:"
    echo "   curl -X GET '$API_URL/order/' \\"
    echo "     -H 'Authorization: Bearer $TOKEN'"
    echo ""
    echo "2. In browser (Swagger UI):"
    echo "   - Go to: $API_URL/docs"
    echo "   - Click 'Authorize' button (top right)"
    echo "   - Paste token in 'Value' field: $TOKEN"
    echo "   - Click 'Authorize', then 'Close'"
    echo ""
    echo "3. Save token to environment variable:"
    echo "   export TOKEN='$TOKEN'"
    echo "   curl -X GET '$API_URL/order/' -H \"Authorization: Bearer \$TOKEN\""
    echo ""
    echo "4. Test protected endpoint now:"
    echo ""
    curl -s -X GET "$API_URL/order/" \
        -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || \
    curl -s -X GET "$API_URL/order/" \
        -H "Authorization: Bearer $TOKEN"
else
    echo "✗ Failed to get token"
    echo ""
    echo "Response:"
    echo "$RESPONSE"
    echo ""
    echo "Check:"
    echo "1. Backend is running: curl $API_URL/"
    echo "2. Credentials are correct (default: admin/admin)"
    echo "3. User exists in database"
fi

