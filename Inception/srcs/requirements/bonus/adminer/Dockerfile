FROM debian:13

# Install PHP and required extensions
RUN apt-get update && apt-get install -y \
    php \
    php-mysql \
    php-pdo \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download Adminer (single PHP file)
RUN curl -L https://www.adminer.org/latest.php -o /var/www/index.php

# Expose port 8080
EXPOSE 8080

# Start PHP built-in server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www"]