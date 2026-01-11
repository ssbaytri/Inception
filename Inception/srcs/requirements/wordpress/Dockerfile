FROM debian:13

# Install PHP-FPM and required extensions
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*


# Install WP-CLI (WordPress Command Line tool)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

COPY tools/setup_wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_wp.sh

# Create directory for PHP-FPM
RUN mkdir -p /run/php

# Create WordPress directory
RUN mkdir -p /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Run setup script
CMD ["setup_wp.sh"]
