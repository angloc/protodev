# Makefile - Development convenience commands
#
# This Makefile provides shortcuts for building and testing the protodev container.
# It is intended for maintainers of this repository.
#
# Usage:
#   make build      - Build the container image locally
#   make test       - Test the container interactively
#   make template   - Test the template configuration

.PHONY: build test template clean help

# Image name for local testing
IMAGE_NAME := protodev-test

# Build the container image
build:
	docker build -t $(IMAGE_NAME) .

# Force rebuild without cache
rebuild:
	docker build --no-cache -t $(IMAGE_NAME) .

# Test the container interactively
test:
	docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock $(IMAGE_NAME) bash

# Test the template configuration
template:
	cd template && docker compose -f .devcontainer/docker-compose.yml up -d

# Stop template test container
template-down:
	cd template && docker compose -f .devcontainer/docker-compose.yml down

# Open shell in template container
template-shell:
	cd template && docker compose -f .devcontainer/docker-compose.yml exec dev bash

# Clean up local images
clean:
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

# Show help
help:
	@echo "Available targets:"
	@echo "  build         - Build the container image locally"
	@echo "  rebuild       - Force rebuild without cache"
	@echo "  test          - Test the container interactively"
	@echo "  template      - Test the template configuration (start)"
	@echo "  template-down - Stop template test container"
	@echo "  template-shell- Open shell in template container"
	@echo "  clean         - Remove local test image"
