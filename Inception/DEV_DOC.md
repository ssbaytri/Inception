# Developer Documentation - Inception

## Overview

This document provides technical information for developers who want to understand, modify, or extend the Inception infrastructure. It covers the architecture, build process, configuration details, and development workflows.

## Setting Up the Development Environment

### Prerequisites

Ensure you have the following installed on your system:

- **Operating System:** Debian 12/13 or Ubuntu 20.04+
- **Docker:** Version 20.10 or higher
- **Docker Compose:** Version 2.0 or higher
- **Git:** For version control
- **Text Editor:** VS Code, vim, nano, etc.
- **Minimum Resources:** 4GB RAM, 20GB disk space

### Installing Docker and Docker Compose
```bash
# Update package index
sudo apt update

# Install Docker
sudo apt install -y docker.io

# Install Docker Compose
sudo apt install -y docker-compose

# Add your user to docker group (avoid using sudo)
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
# Or run: newgrp docker

# Verify installation
docker --version
docker-compose --version
```

### Cloning the Repository
```bash
# Clone the project
git clone <your-repo-url>
cd inception

# Check project structure
ls -la
```

## Project Structure
```
inception/
├── Makefile                      # Build automation
├── README.md                     # Project overview
├── USER_DOC.md                   # User documentation
├── DEV_DOC.md                    # Developer documentation (this file)
├── .gitignore                    # Git ignore rules
├── secrets/                      # Credentials (NOT in git)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── admin_pass.txt
│   ├── user_pass.txt
│   └── ftp_password.txt
└── srcs/                         # Source files
    ├── .env                      # Environment variables
    ├── docker-compose.yml        # Service orchestration
    └── requirements/             # Service definitions
        ├── mariadb/              # Database service
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── setup_mariadb.sh
        ├── nginx/                # Web server service
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── generate-cert.sh
        ├── wordpress/            # Application service
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── setup_wp.sh
        └── bonus/                # Bonus services
            ├── adminer/
            │   └── Dockerfile
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/
            │       └── redis.conf
            ├── static-site/
            │   ├── Dockerfile
            │   └── content/
            │       ├── index.html
            │       ├── style.css
            │       └── script.js
            ├── portainer/
            │   └── Dockerfile
            └── ftp/
                ├── Dockerfile
                ├── conf/
                │   └── vsftpd.conf
                └── tools/
                    └── setup_ftp.sh
```

## Environment Setup from Scratch

### Step 1: Configure Domain Name

Add your domain to `/etc/hosts`:
```bash
sudo nano /etc/hosts

# Add this line (replace ssbaytri with your login):
127.0.0.1   ssbaytri.42.fr
```

### Step 2: Create Data Directories
```bash
# Create directories for persistent data
sudo mkdir -p /home/$USER/data/mariadb
sudo mkdir -p /home/$USER/data/wordpress

# Set ownership
sudo chown -R $USER:$USER /home/$USER/data

# Verify
ls -la /home/$USER/data/
```

### Step 3: Configure Environment Variables

Edit `srcs/.env`:
```bash
nano srcs/.env
```

Example configuration:
```env
# Domain Configuration
DOMAIN_NAME=ssbaytri.42.fr

# MySQL Configuration
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user

# WordPress Admin User (NO PASSWORD HERE!)
WP_ADMIN_USER=subzero
WP_ADMIN_EMAIL=admin@student.42.fr

# WordPress Regular User
WP_USER=regular_user
WP_USER_EMAIL=user@student.42.fr
```

**Important:** Do NOT put passwords in `.env`! They go in `secrets/`.

### Step 4: Configure Secrets

Create password files in `secrets/`:
```bash
# Database user password
echo "your_db_password" > secrets/db_password.txt

# Database root password
echo "your_root_password" > secrets/db_root_password.txt

# WordPress admin password
echo "your_admin_password" > secrets/admin_pass.txt

# WordPress user password
echo "your_user_password" > secrets/user_pass.txt

# FTP password
echo "your_ftp_password" > secrets/ftp_password.txt

# Set proper permissions (security)
chmod 600 secrets/*.txt
```

### Step 5: Configure Git Ignore

Ensure `.gitignore` includes:
```gitignore
# Secrets - NEVER commit these!
secrets/
*.txt

# Environment variables
srcs/.env

# Data directories
data/

# Docker artifacts
*.log
```

## Building and Launching the Project

### Using Makefile (Recommended)
```bash
# Build and start all services
make

# Stop services
make down

# Clean everything (removes data!)
make clean

# Full cleanup (removes images too)
make fclean

# Rebuild from scratch
make re

# View logs
make logs

# Check status
make status
```

### Using Docker Compose Directly
```bash
cd srcs

# Build images
docker-compose build

# Start services in background
docker-compose up -d

# Start services with build
docker-compose up -d --build

# Stop services
docker-compose down

# Stop and remove volumes (deletes data!)
docker-compose down -v

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f wordpress

# Restart specific service
docker-compose restart nginx

# Rebuild specific service
docker-compose up -d --build nginx
```

## Managing Containers and Volumes

### Container Management
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop <container-name>

# Start a container
docker start <container-name>

# Restart a container
docker restart <container-name>

# Remove a container
docker rm <container-name>

# Execute command in container
docker exec <container-name> <command>

# Get a shell in container
docker exec -it <container-name> bash

# View container logs
docker logs <container-name>

# Follow logs in real-time
docker logs -f <container-name>

# Inspect container details
docker inspect <container-name>

# View container resource usage
docker stats
```

### Volume Management
```bash
# List volumes
docker volume ls

# Inspect a volume
docker volume inspect <volume-name>

# Remove a volume
docker volume rm <volume-name>

# Remove all unused volumes
docker volume prune

# Check volume contents from host
ls -la /home/$USER/data/mariadb/
ls -la /home/$USER/data/wordpress/
```

### Network Management
```bash
# List networks
docker network ls

# Inspect network
docker network inspect srcs_inception-net

# Test connectivity between containers
docker exec wordpress ping mariadb
docker exec nginx ping wordpress
```

### Image Management
```bash
# List images
docker images

# Remove an image
docker rmi <image-name>

# Remove unused images
docker image prune

# Remove all unused data
docker system prune -a
```

## Service-Specific Commands

### MariaDB (Database)
```bash
# Access MariaDB shell as root
docker exec -it mariadb mysql -u root -p
# Enter root password from secrets/db_root_password.txt

# Access as WordPress user
docker exec -it mariadb mysql -u wp_user -p
# Enter password from secrets/db_password.txt

# Check database status
docker exec mariadb mysqladmin ping -u wp_user -p<password>

# Show databases
docker exec mariadb mysql -u wp_user -p<password> -e "SHOW DATABASES;"

# Backup database
docker exec mariadb mysqldump -u wp_user -p<password> wordpress_db > backup.sql

# Restore database
docker exec -i mariadb mysql -u wp_user -p<password> wordpress_db < backup.sql
```

### WordPress + PHP-FPM
```bash
# Get shell in WordPress container
docker exec -it wordpress bash

# Use WP-CLI commands
docker exec wordpress wp --info --allow-root --path=/var/www/html

# List WordPress users
docker exec wordpress wp user list --allow-root --path=/var/www/html

# Check WordPress version
docker exec wordpress wp core version --allow-root --path=/var/www/html

# Update WordPress
docker exec wordpress wp core update --allow-root --path=/var/www/html

# List plugins
docker exec wordpress wp plugin list --allow-root --path=/var/www/html

# Activate plugin
docker exec wordpress wp plugin activate <plugin-name> --allow-root --path=/var/www/html

# Check database connection
docker exec wordpress wp db check --allow-root --path=/var/www/html

# Flush cache
docker exec wordpress wp cache flush --allow-root --path=/var/www/html

# Check Redis status
docker exec wordpress wp redis status --allow-root --path=/var/www/html

# Enable Redis cache
docker exec wordpress wp redis enable --allow-root --path=/var/www/html
```

### NGINX
```bash
# Test NGINX configuration
docker exec nginx nginx -t

# Reload NGINX configuration
docker exec nginx nginx -s reload

# View NGINX access logs
docker exec nginx cat /var/log/nginx/access.log

# View NGINX error logs
docker exec nginx cat /var/log/nginx/error.log

# Check SSL certificate
docker exec nginx openssl x509 -in /etc/nginx/ssl/nginx.crt -text -noout
```

### Redis
```bash
# Access Redis CLI
docker exec -it redis redis-cli

# Ping Redis
docker exec redis redis-cli ping

# Get Redis info
docker exec redis redis-cli INFO

# View all keys
docker exec redis redis-cli KEYS '*'

# Monitor Redis commands
docker exec redis redis-cli MONITOR

# Flush all data
docker exec redis redis-cli FLUSHALL

# Get cache statistics
docker exec redis redis-cli INFO stats
```

### FTP Server
```bash
# Check FTP server status
docker exec ftp ps aux | grep vsftpd

# View FTP logs
docker exec ftp cat /var/log/vsftpd.log

# Check FTP user
docker exec ftp id ftpuser

# Check permissions
docker exec ftp ls -la /var/www/html/wp-content/

# Fix permissions manually
docker exec ftp chown -R www-data:www-data /var/www/html/wp-content/
docker exec ftp chmod -R 775 /var/www/html/wp-content/uploads
```

## Data Persistence

### Where Data is Stored

All persistent data is stored on the host machine:
```
/home/ssbaytri/data/
├── mariadb/              # Database files
│   ├── mysql/
│   ├── wordpress_db/
│   ├── ib_logfile0
│   └── ibdata1
└── wordpress/            # WordPress files
    ├── wp-admin/
    ├── wp-content/
    │   ├── themes/
    │   ├── plugins/
    │   └── uploads/
    ├── wp-includes/
    └── wp-config.php
```

### How Data Persists

Data persists through:

1. **Docker Named Volumes** with bind mounts
2. **Configured in docker-compose.yml:**
```yaml
volumes:
  mariadb-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/ssbaytri/data/mariadb

  wordpress-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/ssbaytri/data/wordpress
```

3. **Containers mount these volumes:**
```yaml
services:
  mariadb:
    volumes:
      - mariadb-data:/var/lib/mysql
  
  wordpress:
    volumes:
      - wordpress-data:/var/www/html
```

### Data Lifecycle

**Container Lifecycle:**
- `docker-compose up`: Containers created, mount existing data
- `docker-compose down`: Containers removed, **data persists**
- `docker-compose down -v`: Containers AND volumes removed, **data deleted**

**Manual Cleanup:**
```bash
# Remove containers but keep data
docker-compose down

# Remove data manually
sudo rm -rf /home/$USER/data/mariadb/*
sudo rm -rf /home/$USER/data/wordpress/*
```

## Development Workflow

### Making Changes to Services

#### Example: Modifying NGINX Configuration

1. **Edit configuration file:**
```bash
nano srcs/requirements/nginx/conf/nginx.conf
```

2. **Rebuild and restart:**
```bash
docker-compose up -d --build nginx
```

3. **Test changes:**
```bash
curl -k https://ssbaytri.42.fr
```

4. **Check logs:**
```bash
docker logs nginx
```

#### Example: Modifying WordPress Setup

1. **Edit setup script:**
```bash
nano srcs/requirements/wordpress/tools/setup_wp.sh
```

2. **Rebuild (warning: may reset WordPress):**
```bash
docker-compose stop wordpress
docker-compose rm -f wordpress
docker-compose up -d --build wordpress
```

3. **Verify:**
```bash
docker logs wordpress
```

### Adding a New Bonus Service

**Example: Adding Grafana**

1. **Create directory structure:**
```bash
mkdir -p srcs/requirements/bonus/grafana
```

2. **Create Dockerfile:**
```bash
nano srcs/requirements/bonus/grafana/Dockerfile
```
```dockerfile
FROM debian:13

RUN apt-get update && apt-get install -y grafana

EXPOSE 3000

CMD ["grafana-server"]
```

3. **Add to docker-compose.yml:**
```yaml
  grafana:
    build:
      context: ./requirements/bonus/grafana
      dockerfile: Dockerfile
    container_name: grafana
    ports:
      - "3000:3000"
    networks:
      - inception-net
    restart: always
```

4. **Build and start:**
```bash
docker-compose up -d --build grafana
```

### Debugging Tips

**Enable verbose logging:**
```bash
# In Dockerfile, add debug flags
CMD ["nginx", "-g", "daemon off; error_log /dev/stdout debug;"]
```

**Interactive debugging:**
```bash
# Get shell in container
docker exec -it <container> bash

# Install debugging tools
apt update
apt install -y curl netcat procps

# Test network connectivity
ping mariadb
curl wordpress:9000
netstat -tulpn
```

**Check environment variables:**
```bash
docker exec <container> env
```

**Check file permissions:**
```bash
docker exec <container> ls -la /path/to/directory
```

## Docker Compose Configuration

### Service Dependencies

Services start in order based on `depends_on`:
```yaml
wordpress:
  depends_on:
    - mariadb    # WordPress waits for MariaDB
    - redis      # WordPress waits for Redis

nginx:
  depends_on:
    - wordpress  # NGINX waits for WordPress
```

**Note:** `depends_on` only waits for container start, not for service readiness. Scripts handle waiting for actual service availability.

### Restart Policies

All services use `restart: always`:
```yaml
services:
  mariadb:
    restart: always  # Auto-restart on crash
```

Options:
- `no`: Never restart
- `always`: Always restart
- `on-failure`: Restart only on error
- `unless-stopped`: Restart unless manually stopped

### Environment Variables

**From .env file:**
```yaml
services:
  wordpress:
    env_file:
      - .env
```

**Inline:**
```yaml
services:
  example:
    environment:
      - KEY=value
      - ANOTHER_KEY=another_value
```

### Secrets

**Define secrets:**
```yaml
secrets:
  db_password:
    file: ../secrets/db_password.txt
```

**Use in services:**
```yaml
services:
  mariadb:
    secrets:
      - db_password
```

**Access in containers:**
```bash
# Secrets mounted at /run/secrets/
cat /run/secrets/db_password
```

### Networks

**Custom bridge network:**
```yaml
networks:
  inception-net:
    driver: bridge
```

**Containers on same network communicate by service name:**
```bash
# From wordpress container
ping mariadb        # Resolves to mariadb container IP
mysql -h mariadb    # Connects to mariadb container
```

## Troubleshooting Common Issues

### Port Already in Use

**Error:** `Bind for 0.0.0.0:443 failed: port is already allocated`

**Solution:**
```bash
# Find what's using the port
sudo netstat -tulpn | grep 443

# Kill the process
sudo kill <PID>

# Or change port in docker-compose.yml
ports:
  - "8443:443"  # Use different host port
```

### Permission Denied Errors

**Error:** Permission denied when accessing volumes

**Solution:**
```bash
# Fix ownership
sudo chown -R $USER:$USER /home/$USER/data

# Fix permissions
chmod -R 755 /home/$USER/data
```

### Container Exits Immediately

**Error:** Container starts then exits

**Diagnosis:**
```bash
# Check logs
docker logs <container-name>

# Check exit code
docker inspect <container-name> | grep ExitCode
```

**Common causes:**
- Missing environment variables
- Configuration syntax error
- Service not running in foreground
- Missing dependencies

### Network Issues

**Error:** Containers can't communicate

**Diagnosis:**
```bash
# Check if on same network
docker network inspect srcs_inception-net

# Test connectivity
docker exec wordpress ping mariadb
docker exec nginx ping wordpress
```

**Solution:**
```bash
# Recreate network
docker-compose down
docker network rm srcs_inception-net
docker-compose up -d
```

### Build Cache Issues

**Error:** Old code running after changes

**Solution:**
```bash
# Build without cache
docker-compose build --no-cache

# Or remove everything
docker-compose down
docker system prune -a
docker-compose up -d --build
```

## Performance Optimization

### Reducing Build Time

**Use .dockerignore:**
```
# .dockerignore in each service directory
.git
*.md
*.log
node_modules
```

**Layer caching:**
```dockerfile
# Install dependencies first (cached if unchanged)
RUN apt-get update && apt-get install -y package1 package2

# Copy code last (changes frequently)
COPY . /app
```

### Resource Limits

Add resource constraints:
```yaml
services:
  mariadb:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### Monitoring
```bash
# Real-time resource usage
docker stats

# Specific container
docker stats wordpress

# Save stats to file
docker stats --no-stream > stats.txt
```

## Security Best Practices

### Implemented Security Measures

1. **No root processes** (where possible)
2. **Secrets for credentials** (not in code)
3. **Isolated network** (only port 443 exposed)
4. **TLS encryption** (HTTPS only)
5. **Chrooted FTP** (users can't escape home directory)
6. **No latest tags** (specific versions used)
7. **Minimal base images** (Debian slim)
8. **Read-only volumes** (NGINX mounts WordPress as read-only)

### Additional Recommendations

**For Production:**
- Use real SSL certificates (Let's Encrypt)
- Enable Docker secrets encryption
- Implement firewall rules
- Regular security updates
- Monitor logs for suspicious activity
- Use Docker Bench Security
- Enable SELinux/AppArmor

## CI/CD Integration

### Example GitHub Actions Workflow
```yaml
name: Build and Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Build images
      run: |
        cd srcs
        docker-compose build
    
    - name: Start services
      run: |
        cd srcs
        docker-compose up -d
    
    - name: Wait for services
      run: sleep 30
    
    - name: Test NGINX
      run: curl -k https://localhost:443
    
    - name: Test WordPress
      run: docker exec wordpress wp --info --allow-root
    
    - name: Check logs
      if: failure()
      run: docker-compose logs
    
    - name: Cleanup
      if: always()
      run: docker-compose down
```

## Useful Development Commands

### Quick Reference
```bash
# Start everything
make

# Stop everything
make down

# Rebuild everything
make re

# View all logs
make logs

# Check status
docker-compose ps

# Get shell in container
docker exec -it <container> bash

# Run WP-CLI command
docker exec wordpress wp <command> --allow-root --path=/var/www/html

# Check Redis
docker exec redis redis-cli ping

# Test database connection
docker exec mariadb mysqladmin ping -u wp_user -p<password>

# View resource usage
docker stats

# Clean everything
docker system prune -a -f --volumes
```

## Contributing

When contributing to this project:

1. **Test changes locally** before committing
2. **Document new features** in appropriate .md files
3. **Follow naming conventions** (lowercase, hyphens)
4. **Never commit secrets** (.gitignore protects this)
5. **Write clear commit messages**
6. **Update documentation** when changing functionality

## Additional Resources

- **Docker Documentation:** https://docs.docker.com/
- **Docker Compose File Reference:** https://docs.docker.com/compose/compose-file/
- **Dockerfile Best Practices:** https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- **WordPress Developer Resources:** https://developer.wordpress.org/
- **NGINX Documentation:** https://nginx.org/en/docs/
- **MariaDB Documentation:** https://mariadb.com/kb/en/

---

*For user information, see USER_DOC.md*
*For project overview, see README.md*
