FROM alpine:3.19 AS base
RUN apk add --no-cache ca-certificates curl wget unzip

FROM base AS xray-builder
RUN wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp && \
    mv /tmp/xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip /tmp/xray

FROM nginx:alpine
RUN apk add --no-cache ca-certificates curl bash
COPY --from=xray-builder /usr/local/bin/xray /usr/local/bin/xray
RUN mkdir -p /var/log/xray /run/nginx /etc/xray
COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# CRITICAL FIX: Use exec for the foreground process
RUN echo '#!/bin/sh\n\
set -e\n\
echo "[$(date)] Starting Xray..."\n\
/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 &\n\
XRAY_PID=$!\n\
sleep 5\n\
if ! kill -0 $XRAY_PID 2>/dev/null; then\n\
    echo "[$(date)] ERROR: Xray failed to start"\n\
    exit 1\n\
fi\n\
echo "[$(date)] Xray started (PID: $XRAY_PID)"\n\
# exec replaces the shell with nginx as PID 1\n\
exec nginx -g "daemon off;"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
