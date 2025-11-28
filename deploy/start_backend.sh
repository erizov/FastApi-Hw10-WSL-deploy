#!/bin/bash
# Wrapper script to start backend with correct PYTHONPATH

cd /var/www/project/back
export PYTHONPATH=/var/www/project/back
exec /var/www/project/back/.venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000

