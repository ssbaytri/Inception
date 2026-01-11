#!/bin/bash

# Read passwords from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/admin_pass)
WP_USER_PASSWORD=$(cat /run/secrets/user_pass)

# Read non-sensitive config from environment variables (from .env via docker-compose)
DB_HOST="mariadb"
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"

echo "Waiting for MariaDB to be ready..."
# Wait for MariaDB to be accessible
until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    echo "MariaDB is unavailable - sleeping"
    sleep 2
done
echo "MariaDB is ready!"

# Check if WordPress is already installed
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Setting up WordPress..."
    
    # Download WordPress
    wp core download --path=/var/www/html --allow-root
    
    # Create wp-config.php
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$DB_HOST:3306" \
        --path=/var/www/html \
        --allow-root
    
    # Install WordPress
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --path=/var/www/html \
        --allow-root
    
    # Create a second user (non-admin)
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --path=/var/www/html \
        --allow-root

    # Configure Redis Cache
    echo "Installing Redis Object Cache plugin..."
    wp plugin install redis-cache --activate --path=/var/www/html --allow-root
    
    wp config set WP_REDIS_HOST redis --path=/var/www/html --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --path=/var/www/html --allow-root
    wp config set WP_CACHE true --raw --path=/var/www/html --allow-root
    
    wp redis enable --path=/var/www/html --allow-root
    
    echo "WordPress setup complete with Redis cache!"
    
else
    echo "WordPress already installed, skipping setup..."
fi

# Set correct permissions
chown -R www-data:www-data /var/www/html
chmod -R 777 /var/www/html

echo "Starting PHP-FPM..."
# Start PHP-FPM in foreground (PID 1)
exec php-fpm8.4 -F