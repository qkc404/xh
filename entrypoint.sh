#!/bin/sh
set -e

echo "[$(date)] Starting Xray..."
/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 &
XRAY_PID=$!

echo "[$(date)] Waiting for Xray to initialize..."
sleep 10

if ! kill -0 $XRAY_PID 2>/dev/null; then
    echo "[$(date)] ERROR: Xray failed to start"
    exit 1
fi

echo "[$(date)] Xray started successfully (PID: $XRAY_PID)"

# Test nginx configuration
echo "[$(date)] Testing nginx configuration..."
nginx -t

echo "[$(date)] Starting Nginx..."
exec nginx -g "daemon off;"
