
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*


COPY server.x86_64 /app/
COPY server.sh /app/
COPY server.pck /app/

WORKDIR /app

EXPOSE 4040

RUN chmod +x server.x86_64

CMD ["./server.x86_64"]

