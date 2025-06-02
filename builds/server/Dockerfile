
FROM ubuntu

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

COPY health_check_workaround.py /app/

HEALTHCHECK NONE

WORKDIR /app

EXPOSE 443

RUN chmod +x server.x86_64

CMD ["./server.x86_64"]

