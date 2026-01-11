#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo "Starting MariaDB setup..."
echo "Database: $MYSQL_DATABASE"
echo "User: $MYSQL_USER"

# Create runtime directory for MySQL socket
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chmod 755 /run/mysqld

# Create initialization SQL file
cat > /tmp/init.sql << EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

echo "Initializing database..."
# Initialize database using bootstrap mode
mariadbd --user=mysql --bootstrap < /tmp/init.sql

# Clean up
rm -f /tmp/init.sql

echo "Starting MariaDB server..."
# Start MariaDB normally (this becomes PID 1)
exec mariadbd --user=mysql --bind-address=0.0.0.0