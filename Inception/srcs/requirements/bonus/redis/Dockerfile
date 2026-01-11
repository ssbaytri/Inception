FROM debian:13

# Install Redis
RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Copy Redis configuration
COPY conf/redis.conf /etc/redis/redis.conf

# Create data directory
RUN mkdir -p /data

# Expose Redis port
EXPOSE 6379

# Start Redis with our config
CMD ["redis-server", "/etc/redis/redis.conf"]