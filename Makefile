# Makefile - Development convenience commands
#
# This Makefile provides shortcuts for building and testing the protodev container.
# It is intended for maintainers of this repository.
#
# Usage:
#   make dogfood  - Build image locally and prepare for dogfood testing
#   make test     - Run tests in the current context (inside container)
#   make pytest   - Run tests by starting a fresh container (CI workflow)
#   make shell    - Open an interactive shell in the container
#   make build    - Build the container image locally (test tag)

.PHONY: build rebuild dogfood test shell pytest clean help

# Published image name (used by .devcontainer/devcontainer.json)
IMAGE := ghcr.io/angloc/protodev:latest

# Local test image name
IMAGE_NAME := protodev-test

# Build the container image (local test tag)
build:
	docker build -t $(IMAGE_NAME) .

# Force rebuild without cache (local test tag)
rebuild:
	docker build --no-cache -t $(IMAGE_NAME) .

# Dogfood: build image tagged as the published name so the .devcontainer picks it up.
# After running this, either:
#   Option A: Rebuild the devcontainer in VS Code / PyCharm, then run: make test
#   Option B: docker run (see instructions below), then run: make test
dogfood:
	@echo "Building protodev image locally tagged as $(IMAGE)..."
	docker build -t $(IMAGE) .
	@echo ""
	@echo "✅ Image built. Now test it by running inside the container:"
	@echo ""
	@echo "  Option A: Rebuild the devcontainer in VS Code (Ctrl+Shift+P → Rebuild Container)"
	@echo "            then run: make test"
	@echo ""
	@echo "  Option B: docker run -it --rm --privileged --shm-size=2gb \\"
	@echo "              -v /var/run/docker.sock:/var/run/docker.sock \\"
	@echo "              -v \$$(pwd):/workspace \\"
	@echo "              -p 8080:8080 -p 14500:14500 -p 8888:8888 \\"
	@echo "              -e DISPLAY=:100 --workdir /workspace \\"
	@echo "              $(IMAGE) bash"
	@echo "            then run: make test"
	@echo ""

# Run tests in the current context (inside the container).
# This is the primary test target for dogfood / devcontainer workflows.
test:
	pytest tests/ -v --tb=short

# Open an interactive shell in the locally-built test image
shell:
	docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock $(IMAGE_NAME) bash

# Run pytest tests by starting a fresh container (CI / outside-container workflow).
# Builds a fresh test-tagged image, starts a container, runs tests, then tears it down.
# Uses --network=host for Docker-in-Docker port accessibility.
pytest:
	docker rm -f protodev 2>/dev/null || true
	docker run -d --name protodev \
		--privileged \
		--shm-size=2gb \
		--network=host \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(CURDIR):/workspace \
		-e DISPLAY=:100 \
		-e PYTHONDONTWRITEBYTECODE=1 \
		-e PYTHONUNBUFFERED=1 \
		--workdir /workspace \
		$(IMAGE_NAME) \
		bash -c 'bash /workspace/.devcontainer/postStartCommand.sh && tail -f /dev/null'
	sleep 10
	docker exec protodev pytest /workspace/tests/ -v --tb=short
	docker rm -f protodev 2>/dev/null || true

# Clean up local images
clean:
	docker rmi $(IMAGE_NAME) 2>/dev/null || true

# Show help
help:
	@echo "Available targets:"
	@echo "  dogfood  - Build image as $(IMAGE) for dogfood testing"
	@echo "  test     - Run tests in current context (inside container)"
	@echo "  build    - Build image as $(IMAGE_NAME) (local test tag)"
	@echo "  rebuild  - Force rebuild without cache"
	@echo "  shell    - Interactive shell in locally-built test image"
	@echo "  pytest   - Run tests by starting a fresh container (CI workflow)"
	@echo "  clean    - Remove local test image"
	@echo ""
	@echo "Dogfood workflow:"
	@echo "  1. make dogfood        # builds image as $(IMAGE)"
	@echo "  2a. Rebuild devcontainer in VS Code, then: make test"
	@echo "  2b. OR: docker run ... $(IMAGE) bash, then: make test"
