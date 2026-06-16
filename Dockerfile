FROM teddysun/xray:26.5.9 AS xray-bin
FROM envoyproxy/envoy:v1.31.6

COPY --from=xray-bin /usr/local/bin/xray /usr/local/bin/xray
COPY config.json /etc/xray/config.json
COPY envoy.yaml /etc/envoy/envoy.yaml

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD /usr/local/bin/xray run -c /etc/xray/config.json 2>&1 & \
    sleep 5 && \
    envoy -c /etc/envoy/envoy.yaml --log-level warn
