#!/bin/bash
# start-shell.sh - Start the protodev dev container and open a bash shell.
#
# Runs postStartCommand.sh (Docker socket, DBus, Xpra) then drops into bash.
# Works from any directory — the workspace root is derived from this script's location.
#
# Usage:
#   bash .devcontainer/start-shell.sh
#
# Override the image:
#   IMAGE_NAME=ghcr.io/angloc/protodev:1.0.0 bash .devcontainer/start-shell.sh

WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${IMAGE_NAME:-ghcr.io/angloc/protodev:latest}"

echo "Starting protodev container..."
echo "Workspace: $WORKSPACE"
echo "Image:     $IMAGE"
echo ""

docker run -it --rm \
    --privileged \
    --shm-size=2gb \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$WORKSPACE":/workspace \
    -p 8080:8080 \
    -p 14500:14500 \
    -p 8888:8888 \
    -e DISPLAY=:100 \
    -e PYTHONDONTWRITEBYTECODE=1 \
    -e PYTHONUNBUFFERED=1 \
    --workdir /workspace \
    --user vscode \
    "$IMAGE" \
    bash -c 'bash /workspace/.devcontainer/postStartCommand.sh && exec bash'
