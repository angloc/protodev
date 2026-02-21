#!/bin/bash
#
# postStartCommand.sh - Runtime services startup for DevContainer mode
#
# This script runs after the container is created and VS Code connects.
# It starts background services that are needed in DevContainer mode
# (these are started automatically in Docker Compose mode via entrypoint).
#
# IMPORTANT: This script is used by devcontainer.json postStartCommand.
# It should be kept in sync with the docker-compose.yml entrypoint logic.

set -e

echo "🚀 Starting background services..."

# ============================================
# Start Docker daemon (Docker-in-Docker)
# ============================================
if ! pgrep -x "dockerd" > /dev/null; then
    echo "Starting Docker daemon..."
    sudo dockerd &
    # Wait for dockerd to be ready
    for i in {1..30}; do
        if docker info >/dev/null 2>&1; then
            echo "✅ Docker daemon ready"
            break
        fi
        sleep 1
    done
else
    echo "✅ Docker daemon already running"
fi

# ============================================
# Start Xpra (GUI application streaming)
# ============================================
if ! pgrep -x "xpra" > /dev/null; then
    echo "Starting Xpra HTML5 server..."
    mkdir -p /home/vscode/.xpra
    # Set XDG_RUNTIME_DIR to avoid "not defined" warning
    export XDG_RUNTIME_DIR=/home/vscode/.xpra/runtime
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
    # Start Xpra on display :100 (matches DISPLAY env var) in HTML5 mode
    # --keyboard-layout=us ensures keyboard input works in the HTML5 client
    xpra start :100 --bind-tcp=0.0.0.0:14500 --html=on --daemon=yes \
        --keyboard-layout=uk \
        --log-file=/home/vscode/.xpra/xpra.log
    sleep 2
    echo "✅ Xpra started on port 14500"
else
    echo "✅ Xpra already running"
fi

# ============================================
# Start JupyterLab (optional - can be started manually)
# ============================================
# Jupyter is available via the separate jupyter service in docker-compose,
# but in DevContainer mode users can start it manually if needed.
# Uncomment below to auto-start Jupyter:
#
# if ! pgrep -f "jupyter-lab" > /dev/null; then
#     echo "Starting JupyterLab..."
#     mkdir -p /workspace/projects
#     jupyter lab --notebook-dir=/workspace/projects --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &
#     echo "✅ JupyterLab started on port 8888"
# fi

echo ""
echo "✅ Background services started!"
echo ""
echo "Services available:"
echo "  • Docker daemon     - unix:///var/run/docker.sock"
echo "  • Xpra HTML5        - http://localhost:14500"
echo "  • JupyterLab        - http://localhost:8888 (start manually if needed)"
echo ""
echo "To start a GUI application with Xpra:"
echo "  xpra start :100 --start=antigravity"
echo "  Then connect via http://localhost:14500"
echo ""
