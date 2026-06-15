#!/bin/sh

# Apply sysctl optimizations
sysctl -p /etc/sysctl.conf 2>/dev/null || true

echo "[$(date)] Starting Xray with BBR..."
/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 &

echo "[$(date)] Waiting..."
sleep 5

echo "[$(date)] Starting Nginx..."
exec nginx -g "daemon off;"
