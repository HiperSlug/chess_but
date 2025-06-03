#!/bin/bash

nginx -t || { echo "Nginx config test failed"; exit 1; }

nginx || { echo "Nginx failed to start"; exit 1; }

exec /app/server.x86_64