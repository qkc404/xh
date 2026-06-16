FROM envoyproxy/envoy:v1.31.6

RUN apt-get update && apt-get install -y wget unzip && \
    wget -q -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.5.9/Xray-linux-64.zip && \
    unzip -q /tmp/xray.zip -d /tmp && \
    mv /tmp/xray /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip /tmp/xray

COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["/bin/sh", "-c", "/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 & envoy -c /etc/envoy/envoy.yaml --log-level warn"]
