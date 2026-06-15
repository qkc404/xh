#!/bin/sh
set -e

echo "[$(date)] Starting Xray..."
/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 &
XRAY_PID=$!

echo "[$(date)] Waiting for Xray to bind to port 10000..."
TIMEOUT=30
while ! nc -z 127.0.0.1 10000 2>/dev/null; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ $TIMEOUT -eq 0 ]; then
        echo "[$(date)] ERROR: Xray port 10000 never opened"
        exit 1
    fi
done
echo "[$(date)] Xray port 10000 is open"

if ! kill -0 $XRAY_PID 2>/dev/null; then
    echo "[$(date)] ERROR: Xray process died"
    exit 1
fi

echo "[$(date)] Xray started successfully (PID: $XRAY_PID)"

echo "[$(date)] Testing nginx configuration..."
nginx -t

echo "[$(date)] Starting Nginx on port 8080..."
exec nginx -g "daemon off;"
