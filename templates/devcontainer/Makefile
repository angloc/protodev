# Makefile - Docker Compose convenience wrapper
#
# This Makefile provides shortcuts for common Docker Compose operations.
# It allows you to run the development environment independently of VS Code.
#
# Requirements:
# - make utility
# - Docker Compose (via Docker Desktop, Podman, or Rancher Desktop)
# - Windows: WSL (Windows Subsystem for Linux)
#
# Usage:
#   make up       - Start the development containers
#   make down     - Stop the containers
#   make shell    - Open a shell in the dev container
#   make logs     - View container logs
#   make jupyter  - Open a shell in the jupyter container
#   make clean    - Remove containers and volumes

.PHONY: up down shell logs jupyter clean ps restart help

# Docker Compose file location
COMPOSE_FILE := .devcontainer/docker-compose.yml

# Start the development containers
up:
	docker compose -f $(COMPOSE_FILE) up -d

# Stop the containers
down:
	docker compose -f $(COMPOSE_FILE) down

# Open a shell in the dev container
shell:
	docker compose -f $(COMPOSE_FILE) exec dev bash

# Open a shell in the jupyter container
jupyter:
	docker compose -f $(COMPOSE_FILE) exec jupyter bash

# View container logs (follow mode)
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

# View logs for specific service
logs-dev:
	docker compose -f $(COMPOSE_FILE) logs -f dev

logs-jupyter:
	docker compose -f $(COMPOSE_FILE) logs -f jupyter

# Show container status
ps:
	docker compose -f $(COMPOSE_FILE) ps

# Restart containers
restart:
	docker compose -f $(COMPOSE_FILE) restart

# Remove containers and volumes
clean:
	docker compose -f $(COMPOSE_FILE) down -v

# Start only the dev container
dev:
	docker compose -f $(COMPOSE_FILE) up -d dev

# Start only the jupyter container
jupyter-up:
	docker compose -f $(COMPOSE_FILE) up -d jupyter

# Run a command in the dev container
# Usage: make exec CMD="python script.py"
exec:
	docker compose -f $(COMPOSE_FILE) exec dev $(CMD)

# Pull the latest container image
pull:
	docker compose -f $(COMPOSE_FILE) pull

# Show help
help:
	@echo "Available targets:"
	@echo "  up          - Start the development containers"
	@echo "  down        - Stop the containers"
	@echo "  shell       - Open a shell in the dev container"
	@echo "  jupyter     - Open a shell in the jupyter container"
	@echo "  logs        - View all container logs"
	@echo "  logs-dev    - View dev container logs"
	@echo "  logs-jupyter - View jupyter container logs"
	@echo "  ps          - Show container status"
	@echo "  restart     - Restart containers"
	@echo "  clean       - Remove containers and volumes"
	@echo "  dev         - Start only the dev container"
	@echo "  jupyter-up  - Start only the jupyter container"
	@echo "  pull        - Pull the latest container image"
	@echo "  exec        - Run a command in the dev container"
	@echo "              Example: make exec CMD=\"python script.py\""
	@echo ""
	@echo "Requirements:"
	@echo "  - make utility"
	@echo "  - Docker Compose (Docker Desktop, Podman, or Rancher Desktop)"
	@echo "  - Windows: WSL (Windows Subsystem for Linux)"
