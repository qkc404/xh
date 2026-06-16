FROM teddysun/xray:26.5.9 AS xray-bin
FROM envoyproxy/envoy:v1.31.6

COPY --from=xray-bin /usr/local/bin/xray /usr/local/bin/xray
COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["/bin/sh", "-c", "/usr/local/bin/xray run -c /etc/xray/config.json 2>&1 & envoy -c /etc/envoy/envoy.yaml --log-level warn"]
