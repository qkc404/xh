FROM teddysun/xray:26.5.9

RUN apk add --no-cache nginx curl

RUN mkdir -p /var/log/xray /run/nginx /etc/xray /usr/share/nginx/html

# Optimize sysctl for low latency
RUN echo "net.core.rmem_max = 134217728" >> /etc/sysctl.conf && \
    echo "net.core.wmem_max = 134217728" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_rmem = 4096 87380 134217728" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_wmem = 4096 65536 134217728" >> /etc/sysctl.conf && \
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf && \
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf

COPY config.json /etc/xray/config.json
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
