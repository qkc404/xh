# Stage 1: Base setup (common for both Xray and Nginx)
FROM alpine:3.19 AS base

# Install common dependencies
RUN apk add --no-cache ca-certificates curl wget unzip

# Stage 2: Xray binary download
FROM base AS xray-builder

# Download Xray-core v26.3.27 (latest stable with full XHTTP support)
RUN wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp && \
    mv /tmp/xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip /tmp/xray

# Stage 3: Runtime image with Nginx + Xray
FROM nginx:alpine

# Install required packages (Alpine-based nginx image uses apk)
RUN apk add --no-cache ca-certificates curl bash

# Copy Xray binary from builder stage
COPY --from=xray-builder /usr/local/bin/xray /usr/local/bin/xray

# Create necessary directories
RUN mkdir -p /var/log/xray /run/nginx /etc/xray

# Copy configuration files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf

# Expose Cloud Run's required port
EXPOSE 8080

# Health check endpoint (must be served by Nginx)
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Entrypoint script to manage both processes
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "[$(date)] Starting Xray..."\n\
/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 &\n\
XRAY_PID=$!\n\
\n\
# Give Xray time to bind to its port\n\
sleep 5\n\
\n\
# Verify Xray is still running\n\
if ! kill -0 $XRAY_PID 2>/dev/null; then\n\
    echo "[$(date)] ERROR: Xray failed to start"\n\
    exit 1\n\
fi\n\
echo "[$(date)] Xray started (PID: $XRAY_PID)"\n\
\n\
echo "[$(date)] Starting Nginx..."\n\
# Use exec to replace shell with nginx as PID 1 for proper signal handling\n\
exec nginx -g "daemon off;"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
