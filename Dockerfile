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
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
