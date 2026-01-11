FROM debian:13

# Install NGINX and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy NGINX configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy SSL certificate generation script
COPY tools/generate-cert.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-cert.sh

# Generate self-signed certificate
RUN /usr/local/bin/generate-cert.sh

# Expose HTTPS port
EXPOSE 443

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]