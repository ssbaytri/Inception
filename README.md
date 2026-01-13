<div align="center">

# 🐳 Inception

### A Multi-Container Docker Infrastructure Project

![Inception Banner](https://drive.google.com/uc?export=view&id=1Q1EuZujTV-CFrNA57d4-q9V3Xn2edKL6)

[![42 School](https://img.shields.io/badge/42-School-000000?style=for-the-badge&logo=42&logoColor=white)](https://42.fr)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)
[![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)](https://wordpress.org/)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)](https://mariadb.org/)

*System Administration Exercise - Infrastructure Virtualization*

[Overview](#-overview) •
[Architecture](#-architecture) •
[Quick Start](#-quick-start) •
[Services](#-services) •
[Documentation](#-documentation)

---

</div>

## 📋 Overview

**Inception** is a comprehensive Docker infrastructure project that demonstrates modern containerization practices and microservices architecture. The project sets up a complete WordPress hosting environment with multiple interconnected services, all orchestrated through Docker Compose.

### 🎯 Project Goals

- Deploy a multi-container application infrastructure
- Implement security best practices with TLS/SSL
- Use Docker volumes for persistent data storage
- Configure custom Docker networks for service isolation
- Manage secrets securely without exposing credentials
- Implement bonus services for extended functionality

### ✨ Key Features

- 🔒 **Secure HTTPS** with self-signed SSL certificates (TLSv1.2/1.3)
- 🗄️ **Persistent Data** using Docker volumes
- 🔐 **Secret Management** via Docker secrets
- 🌐 **Custom Domain** configuration (`ssbaytri.42.fr`)
- 📦 **Isolated Services** on a custom Docker network
- 🚀 **Easy Deployment** with automated Makefile commands

---

## 🏗️ Architecture

### Infrastructure Diagram

```
                                    ┌─────────────────┐
                                    │   Host Machine  │
                                    │  ssbaytri. 42.fr│
                                    └────────┬────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                Docker Bridge Network            │
                    │              (inception-net)                    │
                    └────────────────────────┬────────────────────────┘
                                             │
          ┌──────────────────────────────────┼──────────────────────────────────┐
          │                                  │                                  │
    ┌─────▼─────┐                     ┌─────▼─────┐                     ┌─────▼─────┐
    │   NGINX   │                     │ WordPress │                     │  MariaDB  │
    │  (443)    │◄────────────────────┤  (9000)   │◄────────────────────┤  (3306)   │
    │   TLS     │     FastCGI         │  PHP-FPM  │      MySQL          │  Database │
    └───────────┘                     └─────┬─────┘                     └───────────┘
          │                                 │
          │                                 │
          │                           ┌─────▼─────┐
          │                           │   Redis   │
          │                           │  (6379)   │
          │                           │   Cache   │
          │                           └───────────┘
          │
    ┌─────▼─────────────────────────────────────────────────┐
    │                   Bonus Services                      │
    ├───────────────┬──────────────┬──────────────┬─────────┤
    │   Adminer     │     FTP      │ Static Site  │Portainer│
    │   (8080)      │   (21)       │   (8081)     │ (9443)  │
    │  DB Manager   │  File Upload │   HTML/CSS   │ Monitor │
    └───────────────┴──────────────┴──────────────┴─────────┘
```

### Service Communication

- **NGINX** ↔ **WordPress**:  FastCGI protocol on port 9000
- **WordPress** ↔ **MariaDB**: MySQL protocol on port 3306
- **WordPress** ↔ **Redis**:  Redis protocol on port 6379
- **FTP** ↔ **WordPress Volume**: Direct file system access
- **Adminer** ↔ **MariaDB**: MySQL connection

---

## 🚀 Quick Start

### Prerequisites

- **Docker** (20.10+)
- **Docker Compose** (2.0+)
- **Make** utility
- **sudo** access for volume management

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ssbaytri/Inception.git
   cd Inception/Inception
   ```

2. **Configure your environment**
   ```bash
   # The . env file is already configured, but you can modify: 
   # - Domain name
   # - Database settings
   # - User information
   ```

3. **Set up secrets** (already configured in `secrets/` directory)
   ```bash
   # Secrets are managed via Docker secrets
   # Files:  db_password.txt, db_root_password.txt, admin_pass.txt, etc.
   ```

4. **Add domain to /etc/hosts**
   ```bash
   echo "127.0.0.1 ssbaytri.42.fr" | sudo tee -a /etc/hosts
   ```

5. **Build and launch**
   ```bash
   make
   # or
   make up
   ```

### Accessing Services

Once deployed, access your services at: 

| Service | URL | Description |
|---------|-----|-------------|
| **WordPress** | https://ssbaytri.42.fr | Main WordPress site |
| **Adminer** | http://localhost:8080 | Database management |
| **Static Site** | http://localhost:8081 | Custom HTML/CSS/JS site |
| **Portainer** | https://localhost:9443 | Docker container manager |
| **FTP** | ftp://localhost:21 | File transfer service |

---

## 📦 Services

### Core Services (Mandatory)

#### 🌐 NGINX
- **Base Image**:  Debian 13 (Bookworm)
- **Purpose**: Web server and reverse proxy
- **Features**:
  - TLSv1.2 and TLSv1.3 support
  - Self-signed SSL certificate
  - FastCGI integration with PHP-FPM
  - Optimized for WordPress

#### 🐘 WordPress + PHP-FPM
- **Base Image**: Debian 13
- **Purpose**: Content Management System
- **Features**: 
  - PHP 8.4 with FPM (FastCGI Process Manager)
  - WP-CLI for command-line management
  - Automated WordPress installation
  - Two pre-configured users (admin + regular)
  - Redis object caching integration

#### 🗄️ MariaDB
- **Base Image**: Debian 13
- **Purpose**:  Relational database
- **Features**:
  - MySQL-compatible database engine
  - Pre-configured database and users
  - Persistent data storage via volumes
  - Network isolation for security

### Bonus Services

#### 🔍 Adminer
- **Purpose**:  Lightweight database management tool
- **Port**: 8080
- **Features**:  Web-based SQL client alternative to phpMyAdmin

#### 📁 FTP Server
- **Purpose**: File transfer protocol server
- **Ports**: 21 (control), 21000-21010 (passive)
- **Features**:
  - Direct access to WordPress volume
  - Secure user authentication
  - Passive mode support

#### 📄 Static Site
- **Purpose**: Custom HTML/CSS/JS website
- **Port**: 8081
- **Features**:  Simple NGINX-served static content

#### 🔧 Portainer
- **Purpose**: Docker container management UI
- **Port**: 9443 (HTTPS)
- **Features**: Web-based Docker management interface

#### ⚡ Redis
- **Purpose**: In-memory caching layer
- **Port**: 6379
- **Features**:
  - WordPress object cache
  - LRU eviction policy
  - Persistent storage option

---

## 🛠️ Makefile Commands

| Command | Description |
|---------|-------------|
| `make` or `make up` | Build and start all containers |
| `make start` | Start existing containers |
| `make stop` | Stop running containers |
| `make down` | Stop and remove containers |
| `make clean` | Remove containers, volumes, and data |
| `make fclean` | Full cleanup including Docker images |
| `make re` | Rebuild everything from scratch |
| `make status` | Show container status |
| `make logs` | View all container logs |
| `make logs-nginx` | View NGINX logs only |
| `make logs-wordpress` | View WordPress logs only |
| `make logs-mariadb` | View MariaDB logs only |
| `make help` | Display help message |

---

## 📚 Documentation

Detailed documentation is available in the project: 

- 📖 **[USER_DOC.md](Inception/USER_DOC.md)** - User guide and usage instructions
- 🔧 **[DEV_DOC.md](Inception/DEV_DOC.md)** - Developer documentation and troubleshooting

---

## 🗂️ Project Structure

```
Inception/
├── Makefile                          # Build automation
├── srcs/
│   ├── . env                          # Environment variables
│   ├── docker-compose.yml            # Service orchestration
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   └── tools/
│       │       └── setup_mariadb.sh
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── nginx.conf
│       │   └── tools/
│       │       └── generate-cert.sh
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   │   └── www.conf
│       │   └── tools/
│       │       └── setup_wp.sh
│       └── bonus/
│           ├── adminer/
│           ├── ftp/
│           ├── redis/
│           ├── static-site/
│           └── portainer/
├── secrets/                          # Docker secrets (passwords)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── admin_pass.txt
│   ├── user_pass.txt
│   └── ftp_password.txt
└── README.md
```

---

## 🔐 Security Features

- ✅ **TLS/SSL Encryption** - All web traffic encrypted with TLSv1.2/1.3
- ✅ **Docker Secrets** - Passwords never stored in code or environment variables
- ✅ **Network Isolation** - Services on dedicated Docker bridge network
- ✅ **No Latest Tags** - Specific base image versions used
- ✅ **Read-Only Volumes** - NGINX has read-only access to WordPress files
- ✅ **Environment Separation** - Configuration via .env file

---

## 🐛 Troubleshooting

### Common Issues

**Container won't start? **
```bash
make logs          # Check all logs
make status        # Check container status
docker ps -a       # List all containers
```

**Permission denied on volumes?**
```bash
sudo chown -R $USER:$USER /home/ssbaytri/data
```

**Port already in use?**
```bash
sudo lsof -i :443  # Check what's using the port
sudo lsof -i :3306
```

**Reset everything?**
```bash
make fclean        # Full cleanup
make              # Rebuild from scratch
```

---

## 🎓 Learning Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Codex](https://wordpress.org/documentation/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Docker Networks](https://youtu.be/bKFMS5C4CG0?si=8MWPpE2FNI4pmfQN)
- [Docker Tutorial](https://youtu.be/3c-iBn73dDE?si=qFMGgn1JfKPDfXjS)
- [Inception Guide](https://github.com/Forstman1/inception-42)
- [Inception Guide2](https://github.com/Xperaz/inception-42)
- [Medium](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)

---

## 📝 Project Requirements

This project fulfills the **Inception** subject requirements from 42 School:

- ✅ All services run in dedicated Docker containers
- ✅ Dockerfiles built from Debian (penultimate stable version)
- ✅ NGINX with TLSv1.2/1.3 only
- ✅ WordPress with php-fpm configured
- ✅ MariaDB without nginx in the container
- ✅ Volumes for WordPress database and files
- ✅ Docker network connecting all containers
- ✅ Containers restart on crash
- ✅ No passwords in Dockerfiles
- ✅ Environment variables via .env file
- ✅ Domain name configured (ssbaytri.42.fr)
- ✅ **Bonus**:  Redis cache, FTP, Adminer, Static site, Portainer

---

## 👤 Author

**ssbaytri** - [GitHub Profile](https://github.com/ssbaytri)

---

## 📜 License

This project is part of the 42 School curriculum.  Feel free to use it for educational purposes.

---

<div align="center">

### ⭐ If you found this project helpful, consider giving it a star! 

**Made with ❤️ and 🐳 Docker**

</div>
