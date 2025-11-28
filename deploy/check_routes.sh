#!/bin/bash
# Script to check if all routes are loaded

echo "=========================================="
echo "Checking Backend Routes"
echo "=========================================="

echo ""
echo "1. Testing root endpoint..."
ROOT_RESPONSE=$(curl -s http://localhost:8000/)
echo "$ROOT_RESPONSE"

echo ""
echo ""
echo "2. Testing /docs endpoint (FastAPI documentation)..."
DOCS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs)
echo "Status: $DOCS_STATUS"
if [ "$DOCS_STATUS" = "200" ]; then
    echo "✓ /docs is accessible - routes should be loaded"
else
    echo "✗ /docs is not accessible"
fi

echo ""
echo "3. Testing /redoc endpoint..."
REDOC_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/redoc)
echo "Status: $REDOC_STATUS"
if [ "$REDOC_STATUS" = "200" ]; then
    echo "✓ /redoc is accessible"
else
    echo "✗ /redoc is not accessible"
fi

echo ""
echo "4. Testing /openapi.json (API schema)..."
OPENAPI=$(curl -s http://localhost:8000/openapi.json)
if echo "$OPENAPI" | grep -q "paths"; then
    echo "✓ OpenAPI schema is available"
    echo ""
    echo "Available paths:"
    echo "$OPENAPI" | grep -o '"/[^"]*"' | sort -u | head -20
else
    echo "✗ OpenAPI schema not available or invalid"
fi

echo ""
echo "5. Testing specific route endpoints..."
echo "  /auth/token (should return 422 for missing data, not 404):"
AUTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8000/auth/token)
echo "    Status: $AUTH_STATUS"
if [ "$AUTH_STATUS" = "422" ] || [ "$AUTH_STATUS" = "401" ]; then
    echo "    ✓ /auth/token route exists"
elif [ "$AUTH_STATUS" = "404" ]; then
    echo "    ✗ /auth/token route NOT found"
fi

echo ""
echo "6. Checking service logs for import errors..."
echo "Recent errors in logs:"
sudo journalctl -u back.service -n 50 --no-pager | grep -i -E "(error|exception|traceback|failed|import)" | tail -10 || echo "No errors found"

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "If you see only root endpoint:"
echo "1. Check logs: sudo journalctl -u back.service -f"
echo "2. Check /docs: http://localhost:8000/docs"
echo "3. Check /openapi.json: http://localhost:8000/openapi.json"
echo ""
echo "If routes are not loading, check:"
echo "- Are all route files present in /var/www/project/back/app/routes/?"
echo "- Are there import errors in the logs?"
echo "- Try restarting: sudo systemctl restart back.service"

