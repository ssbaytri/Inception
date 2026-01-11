# User Documentation - Inception

## Overview

This document explains how to use the Inception infrastructure as an end user or system administrator. It covers starting/stopping services, accessing the website, managing credentials, and basic troubleshooting.

## Services Provided

The Inception infrastructure provides the following services:

### Mandatory Services

1. **WordPress Website**
   - Full-featured content management system
   - Create and manage posts, pages, media
   - Accessible via HTTPS with TLS encryption
   - URL: https://ssbaytri.42.fr

2. **NGINX Web Server**
   - Secure HTTPS entry point (port 443)
   - TLS 1.2/1.3 encryption
   - Reverse proxy to WordPress

3. **MariaDB Database**
   - Relational database for WordPress data
   - Not directly accessible from outside
   - Internal service only

### Bonus Services

4. **Adminer**
   - Web-based database management
   - View and edit database tables
   - Run SQL queries
   - URL: http://localhost:8080

5. **Static Website**
   - Project showcase page
   - Information about the infrastructure
   - URL: http://localhost:8081

6. **Redis Cache**
   - Performance optimization for WordPress
   - Caches database queries in memory
   - Automatic, transparent operation

7. **Portainer**
   - Docker container management interface
   - Visual monitoring and control
   - URL: https://localhost:9443

8. **FTP Server**
   - File transfer for WordPress files
   - Upload themes, plugins, backups
   - FTP URL: ftp://localhost:21

## Starting and Stopping the Project

### Starting All Services

From the project root directory:
```bash
make
```

This will:
- Build all Docker images
- Create networks and volumes
- Start all containers in the correct order
- Take approximately 30-60 seconds

**Alternative method:**
```bash
cd srcs
docker-compose up -d
```

### Checking Status

To verify all services are running:
```bash
make status
```

Or:
```bash
docker-compose ps
```

You should see all containers with status "Up":
```
NAME        STATUS
mariadb     Up
wordpress   Up
nginx       Up
adminer     Up
static-site Up
redis       Up
portainer   Up
ftp         Up
```

### Stopping Services

To stop all services:
```bash
make down
```

Or:
```bash
cd srcs
docker-compose down
```

This stops and removes containers but preserves your data.

### Restarting Services

To restart everything:
```bash
make re
```

This performs a clean rebuild from scratch.

## Accessing the Website

### Main WordPress Website

1. Open your web browser
2. Navigate to: **https://ssbaytri.42.fr**
3. You'll see a security warning (self-signed certificate):
   - Click "Advanced"
   - Click "Accept the Risk and Continue" or "Proceed to ssbaytri.42.fr"
4. The WordPress website loads

**Note:** The security warning is normal for development with self-signed certificates.

### WordPress Administration Panel

To manage the WordPress site:

1. Navigate to: **https://ssbaytri.42.fr/wp-admin**
2. Log in with administrator credentials:
   - **Username:** subzero
   - **Password:** (see secrets/admin_pass.txt)
3. Access the WordPress dashboard

From here you can:
- Create and edit posts and pages
- Manage themes and plugins
- Upload media files
- Configure site settings
- Manage users

### Adminer (Database Management)

To access the database:

1. Navigate to: **http://localhost:8080**
2. Log in with:
   - **System:** MySQL
   - **Server:** mariadb
   - **Username:** wp_user
   - **Password:** (see secrets/db_password.txt)
   - **Database:** wordpress_db
3. Click "Login"

You can now:
- Browse database tables
- View WordPress data (posts, users, settings)
- Run SQL queries
- Export/import data

### Static Website

To view the project showcase:

1. Navigate to: **http://localhost:8081**
2. View information about the infrastructure

### Portainer (Container Management)

To manage Docker containers:

1. Navigate to: **https://localhost:9443**
2. First time: Create admin password
3. Select "Docker" → "Connect"
4. View and manage all containers

### FTP Access

To transfer files:

**Using Command Line:**
```bash
ftp localhost
# Username: ftpuser
# Password: (see secrets/ftp_password.txt)
```

**Using FileZilla or other FTP client:**
- **Host:** localhost or 127.0.0.1
- **Port:** 21
- **Username:** ftpuser
- **Password:** (see secrets/ftp_password.txt)
- **Protocol:** FTP

## Managing Credentials

### Credential Locations

All sensitive credentials are stored in the `secrets/` directory:
```
secrets/
├── db_password.txt       # Database user password
├── db_root_password.txt  # Database root password
├── admin_pass.txt        # WordPress admin password
├── user_pass.txt         # WordPress regular user password
└── ftp_password.txt      # FTP server password
```

### Viewing Credentials
```bash
# WordPress admin password
cat secrets/admin_pass.txt

# Database password
cat secrets/db_password.txt

# FTP password
cat secrets/ftp_password.txt
```

### Changing Credentials

**⚠️ WARNING:** Changing passwords requires rebuilding containers and may cause data loss. Always backup first!

1. Stop all services:
```bash
make down
```

2. Edit the secret files:
```bash
nano secrets/admin_pass.txt
# Update password
```

3. Clean and rebuild:
```bash
make clean
make
```

### Default Users

The system creates these WordPress users:

1. **Administrator:**
   - Username: subzero
   - Password: (see secrets/admin_pass.txt)
   - Role: Full administrative access

2. **Regular User:**
   - Username: regular_user
   - Password: (see secrets/user_pass.txt)
   - Role: Author (can create and publish posts)

## Checking Service Status

### Method 1: Docker Commands
```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# Check specific container
docker ps | grep nginx
```

### Method 2: Check Container Logs
```bash
# View all logs
make logs

# View specific service logs
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs redis
docker logs adminer
docker logs ftp
docker logs portainer
docker logs static-site

# Follow logs in real-time
docker logs -f wordpress
```

### Method 3: Health Checks

**Check NGINX:**
```bash
curl -k https://ssbaytri.42.fr
# Should return HTML
```

**Check MariaDB:**
```bash
docker exec mariadb mysqladmin ping -u wp_user -p1337
# Should return "mysqld is alive"
```

**Check WordPress:**
```bash
docker exec wordpress wp --info --allow-root --path=/var/www/html
# Should show WordPress and PHP info
```

**Check Redis:**
```bash
docker exec redis redis-cli ping
# Should return "PONG"
```

**Check FTP:**
```bash
ftp localhost
# Should connect successfully
```

## Data Management

### Backup

Your data is stored in:
```
/home/ssbaytri/data/
├── mariadb/      # Database files
└── wordpress/    # WordPress files
```

To backup:
```bash
# Create backup directory
mkdir -p ~/backups/inception-$(date +%Y%m%d)

# Backup database
sudo tar -czf ~/backups/inception-$(date +%Y%m%d)/mariadb.tar.gz /home/ssbaytri/data/mariadb/

# Backup WordPress files
sudo tar -czf ~/backups/inception-$(date +%Y%m%d)/wordpress.tar.gz /home/ssbaytri/data/wordpress/
```

### Restore

To restore from backup:

1. Stop services:
```bash
make down
```

2. Restore data:
```bash
sudo rm -rf /home/ssbaytri/data/mariadb/*
sudo rm -rf /home/ssbaytri/data/wordpress/*

sudo tar -xzf ~/backups/inception-YYYYMMDD/mariadb.tar.gz -C /
sudo tar -xzf ~/backups/inception-YYYYMMDD/wordpress.tar.gz -C /
```

3. Restart services:
```bash
make
```

## Troubleshooting

### Website Not Loading

**Problem:** Cannot access https://ssbaytri.42.fr

**Solutions:**

1. Check containers are running:
```bash
docker ps
```

2. Check NGINX logs:
```bash
docker logs nginx
```

3. Verify domain configuration:
```bash
cat /etc/hosts | grep ssbaytri.42.fr
# Should show: 127.0.0.1 ssbaytri.42.fr
```

4. Check if port 443 is accessible:
```bash
curl -k https://localhost:443
```

### Database Connection Error

**Problem:** WordPress shows "Error establishing database connection"

**Solutions:**

1. Check MariaDB is running:
```bash
docker ps | grep mariadb
```

2. Check MariaDB logs:
```bash
docker logs mariadb
```

3. Verify database credentials in WordPress:
```bash
docker exec wordpress cat /var/www/html/wp-config.php | grep DB_
```

4. Test database connection:
```bash
docker exec wordpress wp db check --allow-root --path=/var/www/html
```

### FTP Upload Fails

**Problem:** Cannot upload files via FTP

**Solutions:**

1. Check FTP server is running:
```bash
docker ps | grep ftp
```

2. Check FTP logs:
```bash
docker logs ftp
```

3. Verify permissions:
```bash
docker exec ftp ls -la /var/www/html/wp-content/
```

4. Fix permissions if needed:
```bash
docker exec ftp chmod -R 775 /var/www/html/wp-content/uploads
```

### Container Won't Start

**Problem:** Container exits immediately after starting

**Solutions:**

1. Check container logs:
```bash
docker logs <container-name>
```

2. Check for port conflicts:
```bash
sudo netstat -tulpn | grep -E '443|8080|8081|9443|21'
```

3. Rebuild container:
```bash
docker-compose up -d --build <service-name>
```

### Redis Cache Not Working

**Problem:** WordPress not using Redis cache

**Solutions:**

1. Check Redis is running:
```bash
docker exec redis redis-cli ping
# Should return PONG
```

2. Check Redis plugin in WordPress:
   - Go to WordPress Admin → Settings → Redis
   - Should show "Connected"

3. Enable Redis cache:
```bash
docker exec wordpress wp redis enable --allow-root --path=/var/www/html
```

### SSL Certificate Warning

**Problem:** Browser shows security warning

**Solution:** This is normal for self-signed certificates in development. Click "Advanced" and proceed. For production, use a proper certificate from Let's Encrypt or a certificate authority.

## Performance Tips

1. **Monitor Resource Usage:**
```bash
docker stats
```

2. **Clear WordPress Cache:**
```bash
docker exec wordpress wp cache flush --allow-root --path=/var/www/html
```

3. **Clear Redis Cache:**
```bash
docker exec redis redis-cli FLUSHALL
```

4. **Restart Services:**
```bash
docker-compose restart
```

## Support

For issues or questions:

1. Check container logs: `docker logs <container-name>`
2. Review this documentation
3. Check the DEV_DOC.md for technical details
4. Contact the system administrator

---

*For developer information, see DEV_DOC.md*
