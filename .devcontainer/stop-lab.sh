#!/bin/bash
# stop-lab.sh - Stop the standalone JupyterLab container started by start-lab.sh
#
# Usage:
#   bash .devcontainer/stop-lab.sh
#
# Note: if you used the `lab` alias inside the dev container, use `labstop` instead.

CONTAINER="protodev-lab"

if docker ps -q --filter "name=^${CONTAINER}$" | grep -q .; then
    echo "Stopping JupyterLab..."
    docker stop "$CONTAINER" > /dev/null
    echo "✅ JupyterLab stopped."
else
    echo "JupyterLab is not running (no container named '$CONTAINER' found)."
fi
