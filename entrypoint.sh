#!/bin/sh
set -e

echo "[$(date)] Starting Xray..."
/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 &
XRAY_PID=$!

sleep 5

if ! kill -0 $XRAY_PID 2>/dev/null; then
    echo "[$(date)] ERROR: Xray failed to start"
    exit 1
fi

echo "[$(date)] Xray started (PID: $XRAY_PID)"
echo "[$(date)] Starting Nginx..."

# exec replaces shell with nginx as PID 1 (critical for Cloud Run)
exec nginx -g "daemon off;"
