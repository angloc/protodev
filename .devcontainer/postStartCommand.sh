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
    sudo dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 &
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
# Start VNC server
# ============================================
if ! pgrep -x "Xtigervnc" > /dev/null; then
    echo "Starting VNC server..."
    # Cleanup pre-existing locks to ensure clean start
    vncserver -kill :1 2>/dev/null || true
    rm -rf /tmp/.X11-unix/X1 /tmp/.X1-lock 2>/dev/null || true

    sudo chown -R vscode:vscode /home/vscode/.vnc 2>/dev/null || true
    mkdir -p /home/vscode/.vnc
    mkdir -p /home/vscode/.config/tigervnc
    sudo chown -R vscode:vscode /home/vscode/.config 2>/dev/null || true

    # Set VNC password
    echo "vscode" | vncpasswd -f > /home/vscode/.vnc/passwd
    chmod 600 /home/vscode/.vnc/passwd

    # Copy config files to new location to satisfy TigerVNC
    cp /home/vscode/.vnc/passwd /home/vscode/.config/tigervnc/passwd 2>/dev/null || true
    cp /home/vscode/.vnc/xstartup /home/vscode/.config/tigervnc/xstartup 2>/dev/null || true
    chmod 600 /home/vscode/.config/tigervnc/passwd 2>/dev/null || true
    chmod 755 /home/vscode/.config/tigervnc/xstartup 2>/dev/null || true

    # Start VNC with localhost no to allow external connections
    vncserver :1 -geometry 1920x1080 -depth 24 -localhost no -rfbauth /home/vscode/.vnc/passwd
    echo "✅ VNC server started on port 5901"
else
    echo "✅ VNC server already running"
fi

# ============================================
# Start noVNC (web-based VNC client)
# ============================================
if ! pgrep -f "novnc_proxy\|launch.sh" > /dev/null; then
    echo "Starting noVNC..."
    # Set up default index page for nicer experience
    if [ -d /usr/local/novnc ] && [ ! -f /usr/local/novnc/index.html ]; then
        sudo ln -s vnc.html /usr/local/novnc/index.html 2>/dev/null || true
    fi

    if [ -f /usr/local/novnc/utils/novnc_proxy ]; then
        /usr/local/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080 &
    elif [ -f /usr/local/novnc/utils/launch.sh ]; then
        /usr/local/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080 &
    else
        echo "⚠️  noVNC proxy script not found"
    fi
    echo "✅ noVNC started on port 6080"
else
    echo "✅ noVNC already running"
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
echo "  • VNC server        - localhost:5901 (password: vscode)"
echo "  • noVNC web client  - http://localhost:6080"
echo ""
