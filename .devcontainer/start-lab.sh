#!/bin/bash
# start-lab.sh - Start a standalone JupyterLab container in the background.
#
# Access at http://localhost:8888
# Stop with: bash .devcontainer/stop-lab.sh
#
# Note: if you are already inside the dev container, use the `lab` alias instead.
#
# Usage:
#   bash .devcontainer/start-lab.sh
#
# Override the image:
#   IMAGE_NAME=ghcr.io/angloc/protodev:1.0.0 bash .devcontainer/start-lab.sh

WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${IMAGE_NAME:-ghcr.io/angloc/protodev:latest}"
CONTAINER="protodev-lab"

# Stop any existing instance
if docker ps -q --filter "name=^${CONTAINER}$" | grep -q .; then
    echo "Stopping existing JupyterLab container..."
    docker stop "$CONTAINER" > /dev/null
fi

echo "Starting JupyterLab..."
echo "Workspace: $WORKSPACE"
echo "Image:     $IMAGE"

docker run -d --rm \
    --name "$CONTAINER" \
    -v "$WORKSPACE":/workspace \
    -p 8888:8888 \
    --workdir /workspace \
    -e PYTHONDONTWRITEBYTECODE=1 \
    -e PYTHONUNBUFFERED=1 \
    --user vscode \
    "$IMAGE" \
    jupyter lab \
        --notebook-dir=/workspace \
        --ip=0.0.0.0 \
        --port=8888 \
        --no-browser \
        --IdentityProvider.token='' \
        --IdentityProvider.password_required=False > /dev/null

echo ""
echo "✅ JupyterLab running at http://localhost:8888"
echo "   Stop with: bash .devcontainer/stop-lab.sh"
