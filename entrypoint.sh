#!/bin/sh

echo "[$(date)] Starting Xray..."
/usr/local/bin/xray run -c /etc/xray/config.json &

echo "[$(date)] Waiting 10 seconds for Xray to initialize..."
sleep 10

echo "[$(date)] Starting Nginx..."
exec nginx -g "daemon off;"
