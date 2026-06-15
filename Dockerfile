FROM teddysun/xray:26.3.27

# Install nginx and netcat for port checking
RUN apk add --no-cache nginx curl bash netcat-openbsd

# Create necessary directories
RUN mkdir -p /var/log/xray /run/nginx /etc/xray /usr/share/nginx/html

# Copy configuration files
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080

# CRITICAL: Increase start-period to 180 seconds
HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=5 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
