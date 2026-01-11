#!/bin/bash

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

echo "=== FTP Server Setup ==="

# Create FTP user if doesn't exist
if ! id -u $FTP_USER > /dev/null 2>&1; then
    echo "Creating FTP user..."
    useradd -m -d /var/www/html -s /bin/bash $FTP_USER
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    usermod -aG www-data $FTP_USER
    echo "✓ FTP user created"
else
    echo "✓ FTP user exists"
    # Ensure user is in www-data group
    usermod -aG www-data $FTP_USER
fi

echo "=== Setting Permissions ==="

# Wait a moment for volume to be fully mounted
sleep 2

# CRITICAL: Set root ownership on home directory (vsftpd chroot requirement)
echo "Setting /var/www/html to root:root 755..."
chown root:root /var/www/html
chmod 755 /var/www/html

# Wait for WordPress to create wp-content
if [ ! -d /var/www/html/wp-content ]; then
    echo "Waiting for WordPress to create wp-content..."
    timeout=30
    while [ ! -d /var/www/html/wp-content ] && [ $timeout -gt 0 ]; do
        sleep 1
        timeout=$((timeout-1))
    done
fi

# Set permissions on wp-content if it exists
if [ -d /var/www/html/wp-content ]; then
    echo "Setting wp-content permissions..."
    chown -R www-data:www-data /var/www/html/wp-content
    chmod -R 775 /var/www/html/wp-content
    echo "✓ wp-content set to www-data:www-data 775"
fi

# Set permissions on uploads if it exists
if [ -d /var/www/html/wp-content/uploads ]; then
    echo "Setting uploads permissions..."
    chown -R www-data:www-data /var/www/html/wp-content/uploads
    chmod -R 775 /var/www/html/wp-content/uploads
    echo "✓ uploads set to www-data:www-data 775"
fi

# Verify ftpuser group membership
echo "User groups:"
groups $FTP_USER

echo "=== Final Permissions ==="
ls -ld /var/www/html
ls -ld /var/www/html/wp-content 2>/dev/null || echo "wp-content not yet created"
ls -ld /var/www/html/wp-content/uploads 2>/dev/null || echo "uploads not yet created"

echo "=== Starting vsftpd ==="
exec /usr/sbin/vsftpd /etc/vsftpd.conf