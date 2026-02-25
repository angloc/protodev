#!/bin/bash
#
# postStartCommand.sh - Runtime services startup for DevContainer mode
#
# This script runs after the container is created and VS Code connects.
# It starts background services that are needed in DevContainer mode.
#
# Note: Docker-in-Docker daemon is handled automatically by the devcontainer
# infrastructure or docker-compose entrypoint - no manual startup needed.

set -e

echo "🚀 Starting background services..."

# ============================================
# Start Xpra (GUI application streaming)
# ============================================
if ! command -v xpra &>/dev/null; then
    echo "⚠️  xpra is not installed — skipping GUI streaming startup"
    echo "   To use GUI apps, rebuild the container image so xpra can be installed."
elif pgrep -x "xpra" > /dev/null; then
    echo "✅ Xpra already running"
else
    echo "Starting Xpra HTML5 server..."
    mkdir -p /home/vscode/.xpra
    # Set XDG_RUNTIME_DIR to avoid "not defined" warning
    export XDG_RUNTIME_DIR=/home/vscode/.xpra/runtime
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
    # Start Xpra on display :100 (matches DISPLAY env var) in HTML5 mode
    # --keyboard-layout=us ensures keyboard input works in the HTML5 client
    xpra start :100 --bind-tcp=0.0.0.0:14500 --html=on --daemon=yes \
        --keyboard-layout=us \
        --log-file=/home/vscode/.xpra/xpra.log
    sleep 2
    echo "✅ Xpra started on port 14500"
fi

echo ""
echo "✅ Background services started!"
echo ""
echo "Services available:"
echo "  • Docker daemon     - unix:///var/run/docker.sock"
echo "  • Xpra HTML5        - http://localhost:14500"
echo ""
echo "To start a GUI application with Xpra:"
echo "  chrome-xpra &"
echo "  Then connect via http://localhost:14500"
echo ""
