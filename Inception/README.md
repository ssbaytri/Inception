*This project has been created as part of the 42 curriculum by ssbaytri.*

# Inception

## Description

Inception is a system administration project that demonstrates Docker containerization by setting up a complete web infrastructure. The project consists of multiple services running in isolated Docker containers, all orchestrated via Docker Compose.

### Architecture Overview

The infrastructure includes:
- **NGINX** - Web server with TLS 1.3 encryption (entry point)
- **WordPress** - Content Management System with PHP-FPM
- **MariaDB** - Relational database for WordPress data
- **Adminer** - Web-based database management interface
- **Redis** - In-memory cache for WordPress performance optimization
- **Static Website** - Custom HTML/CSS/JS showcase page
- **Portainer** - Docker container management interface
- **FTP Server** - File transfer service for WordPress file management

All services communicate through a custom Docker bridge network, with data persisting in Docker volumes mounted on the host machine.

## Instructions

### Prerequisites

- Debian-based Linux system (VM or physical)
- Docker Engine (20.10+)
- Docker Compose (2.0+)
- Minimum 4GB RAM
- Minimum 20GB disk space
- Sudo/root access

### Installation

1. **Clone the repository:**
```bash
git clone <your-repo-url>
cd inception
```

2. **Configure domain name:**
```bash
sudo nano /etc/hosts
# Add: 127.0.0.1 ssbaytri.42.fr
```

3. **Create data directories:**
```bash
sudo mkdir -p /home/$USER/data/{mariadb,wordpress}
sudo chown -R $USER:$USER /home/$USER/data
```

4. **Configure environment variables:**
```bash
nano srcs/.env
```

5. **Set up secrets:**
```bash
# Secrets are in secrets/ directory
# Ensure they are NOT committed to git
```

### Building and Running
```bash
# Build and start all services
make

# Or manually:
cd srcs
docker-compose up -d --build
```

### Accessing Services

Once running, access the services at:

- **WordPress:** https://ssbaytri.42.fr
- **WordPress Admin:** https://ssbaytri.42.fr/wp-admin
- **Adminer:** http://localhost:8080
- **Static Website:** http://localhost:8081
- **Portainer:** https://localhost:9443
- **FTP Server:** ftp://localhost:21

### Credentials

- **WordPress Admin:** subzero / (see secrets/admin_pass.txt)
- **WordPress User:** regular_user / (see secrets/user_pass.txt)
- **FTP:** ftpuser / (see secrets/ftp_password.txt)
- **Database:** wp_user / (see secrets/db_password.txt)

### Stopping Services
```bash
make down
```

### Cleaning Up
```bash
# Remove containers and data
make clean

# Full cleanup (including Docker images)
make fclean
```

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Redis Documentation](https://redis.io/documentation)

### AI Usage

AI (Claude by Anthropic) was used in this project for:
- Learning Docker concepts and best practices
- Dockerfile optimization and review
- Configuration file templates
- Debugging assistance
- Documentation structure

All AI-generated content was reviewed, tested, and understood before implementation.

## Project Design Choices

### Virtual Machines vs Docker

**Docker Containers:**
- Lightweight (share host kernel)
- Fast startup (seconds)
- Efficient resource usage
- Easy to replicate and scale
- Portable across environments

**Virtual Machines:**
- Full OS with separate kernel
- Slower startup (minutes)
- Higher resource overhead
- Complete isolation
- Better for running different OS types

**Choice:** Docker is ideal for microservices architecture where each service runs independently but shares the host kernel for efficiency.

### Secrets vs Environment Variables

**Environment Variables (.env file):**
- Plain text configuration
- Easy to use and modify
- Good for non-sensitive data (domain names, usernames)
- Used in this project for general configuration

**Docker Secrets:**
- Encrypted storage
- Mounted as files in /run/secrets/
- Better security for production
- Used in this project for passwords

**Choice:** Hybrid approach - environment variables for configuration, Docker secrets for credentials.

### Docker Network vs Host Network

**Docker Bridge Network:**
- Containers get isolated network namespace
- Communicate by service name (DNS)
- More secure (isolated from host)
- Used in this project

**Host Network:**
- Container uses host's network directly
- Better performance
- Less secure (no isolation)
- Not recommended for most cases

**Choice:** Custom bridge network (inception-net) for security and proper service isolation.

### Docker Volumes vs Bind Mounts

**Docker Volumes:**
- Managed by Docker
- Stored in Docker's directory
- Better portability
- Recommended for production

**Bind Mounts:**
- Direct mapping to host filesystem
- You control exact location
- Easier to inspect and backup
- Used in this project

**Choice:** Bind mounts to /home/ssbaytri/data/ as required by the subject, providing easy access to persisted data.

## Project Structure
```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── admin_pass.txt
│   ├── user_pass.txt
│   └── ftp_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            ├── adminer/
            ├── redis/
            ├── static-site/
            ├── portainer/
            └── ftp/
```

## Technical Stack

- **Base OS:** Debian 13
- **Web Server:** NGINX 1.24+
- **Application:** WordPress 6.9
- **Database:** MariaDB 11.8
- **PHP:** PHP-FPM 8.4
- **Cache:** Redis 8.0
- **Container Runtime:** Docker 20.10+
- **Orchestration:** Docker Compose 2.0+

## Security Features

- TLS 1.2/1.3 encryption for HTTPS
- Docker secrets for credential management
- Isolated network (only port 443 exposed)
- Non-root users in containers where possible
- Chrooted FTP environment
- No hardcoded passwords in code

## Author

**ssbaytri** - 42 Network Student

---

*Last updated: January 2026*
