#!/bin/bash

# Start health check in background
python3 ./health_check.py &

# Run main server
exec ./server.x86_64