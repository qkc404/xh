FROM envoyproxy/envoy:v1.31.6

RUN apt-get update && apt-get install -y wget unzip curl && \
    wget -qO /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip -p /tmp/xray.zip xray > /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip

COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start Xray in background, wait 5 seconds, then start Envoy
CMD /usr/local/bin/xray run -c /etc/xray/config.json 2>&1 & \
    sleep 5 && \
    envoy -c /etc/envoy/envoy.yaml --log-level warn
