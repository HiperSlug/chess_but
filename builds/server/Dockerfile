
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    python3\
    python3-pip \
    && rm -rf /var/lib/apt/lists/*


COPY server.x86_64 /app/
COPY server.sh /app/
COPY server.pck /app/
COPY health_check.py /app/
COPY entry_point.sh /app/

WORKDIR /app

EXPOSE 443
EXPOSE 80
EXPOSE 1111

ENV PYTHONBUFFERED = 1

RUN chmod +x server.x86_64
RUN chmod +x health_check.py
RUN chmon +x entry_point.sh

CMD ["./entry_point.sh"] 
