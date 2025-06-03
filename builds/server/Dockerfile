
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    nginx \
    && rm -rf /var/lib/apt/lists/*


COPY server.x86_64 /app/
COPY server.sh /app/
COPY server.pck /app/
COPY reverse_proxy_for_health_check.conf /etc/nginx/conf.d/reverse_proxy_for_health_check.conf
COPY entry_point.sh /app/

WORKDIR /app

EXPOSE 8080


RUN chmod +x server.x86_64
RUN chmod +x entry_point.sh

CMD ["./entry_point.sh"] 
