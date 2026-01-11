# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = /home/ssbaytri/data

# Colors for output
GREEN = \033[0;32m
RED = \033[0;31m
RESET = \033[0m

# Default target
all: up

# Build and start all containers
up:
	@echo "$(GREEN)Building and starting containers...$(RESET)"
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@docker-compose -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)All containers are up!$(RESET)"

# Start containers (without building)
start:
	@echo "$(GREEN)Starting containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) start
	@echo "$(GREEN)Containers started!$(RESET)"

# Stop containers
stop:
	@echo "$(RED)Stopping containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) stop
	@echo "$(RED)Containers stopped!$(RESET)"

# Stop and remove containers
down:
	@echo "$(RED)Stopping and removing containers...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) down
	@echo "$(RED)Containers removed!$(RESET)"

# Stop containers, remove volumes and clean data
clean: down
	@echo "$(RED)Cleaning up volumes and data...$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) down -v
	@sudo rm -rf $(DATA_PATH)/mariadb/*
	@sudo rm -rf $(DATA_PATH)/wordpress/*
	@echo "$(RED)Cleanup complete!$(RESET)"

# Full cleanup including images
fclean: clean
	@echo "$(RED)Removing all Docker images...$(RESET)"
	@docker system prune -af
	@docker volume prune -f
	@echo "$(RED)Full cleanup complete!$(RESET)"

# Rebuild everything from scratch
re: fclean all

# Show container status
status:
	@echo "$(GREEN)Container status:$(RESET)"
	@docker-compose -f $(COMPOSE_FILE) ps

# Show logs
logs:
	@docker-compose -f $(COMPOSE_FILE) logs -f

# Show logs for specific service
logs-mariadb:
	@docker-compose -f $(COMPOSE_FILE) logs -f mariadb

logs-wordpress:
	@docker-compose -f $(COMPOSE_FILE) logs -f wordpress

logs-nginx:
	@docker-compose -f $(COMPOSE_FILE) logs -f nginx

# Help
help:
	@echo "$(GREEN)Available commands:$(RESET)"
	@echo "  make          - Build and start all containers"
	@echo "  make up       - Build and start all containers"
	@echo "  make start    - Start existing containers"
	@echo "  make stop     - Stop containers"
	@echo "  make down     - Stop and remove containers"
	@echo "  make clean    - Stop, remove containers and clean data"
	@echo "  make fclean   - Full cleanup including images"
	@echo "  make re       - Rebuild everything from scratch"
	@echo "  make status   - Show container status"
	@echo "  make logs     - Show all logs"
	@echo "  make help     - Show this help message"

.PHONY: all up start stop down clean fclean re status logs logs-mariadb logs-wordpress logs-nginx help