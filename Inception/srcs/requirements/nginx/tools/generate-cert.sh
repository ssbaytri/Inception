#!/bin/bash

DOMAIN=${DOMAIN_NAME:-localhost}

# Create SSL directory
mkdir -p /etc/nginx/ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/OU=42/CN=${DOMAIN}"

echo "SSL certificate generated for ${DOMAIN}!"