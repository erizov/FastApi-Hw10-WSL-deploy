#!/bin/bash
# Script to test backend routes

echo "=========================================="
echo "Testing Backend Routes"
echo "=========================================="

echo ""
echo "1. Testing root endpoint..."
curl -s http://localhost:8000/ | jq . || curl -s http://localhost:8000/

echo ""
echo ""
echo "2. Testing /docs endpoint..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8000/docs

echo ""
echo "3. Testing /redoc endpoint..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8000/redoc

echo ""
echo "4. Testing /openapi.json..."
curl -s http://localhost:8000/openapi.json | head -20

echo ""
echo "5. Checking service logs for errors..."
echo "Last 20 lines of service log:"
sudo journalctl -u back.service -n 20 --no-pager | grep -i error || echo "No errors found in recent logs"

echo ""
echo "=========================================="
echo "Test Complete"
echo "=========================================="
echo ""
echo "If you see only root endpoint, check:"
echo "1. Service logs: sudo journalctl -u back.service -f"
echo "2. Check if routes are imported: curl http://localhost:8000/openapi.json"
echo "3. Check documentation: http://localhost:8000/docs or http://localhost:8000/redoc"

