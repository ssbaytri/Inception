FROM debian:13

# Install nginx (lightweight web server)
RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy website files
COPY content/ /var/www/html/

# Create simple nginx config
RUN echo 'server { \n\
    listen 8081; \n\
    listen [::]:8081; \n\
    root /var/www/html; \n\
    index index.html; \n\
    server_name _; \n\
    location / { \n\
        try_files $uri $uri/ =404; \n\
    } \n\
}' > /etc/nginx/sites-available/default

# Expose port
EXPOSE 8081

# Start nginx
CMD ["nginx", "-g", "daemon off;"]