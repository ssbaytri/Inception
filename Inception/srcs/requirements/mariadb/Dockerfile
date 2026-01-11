FROM debian:13

# Install MariaDB
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Copy setup script
COPY tools/setup_mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_mariadb.sh

# Expose MySQL port
EXPOSE 3306

# Run setup script
CMD ["setup_mariadb.sh"]
