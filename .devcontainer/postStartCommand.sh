#!/bin/bash
#
# postStartCommand.sh - Runtime setup for development container
#
# This script runs when the container starts. It handles all runtime tasks
# that cannot be baked into the image:
# - Docker socket permissions (if mounted from host)
# - DBus session bus (required for Chrome input handling)
# - Xpra HTML5 server (for GUI applications)
#
# Git configuration is already baked into the image (see Dockerfile).
#
# This script is used by both:
# - VS Code DevContainer mode (via devcontainer.json postStartCommand)
# - Docker Compose mode (via docker-compose.yml entrypoint)

set -e

echo "🚀 Starting development container services..."

# ============================================
# Docker Socket Permissions
# ============================================
# The Docker daemon socket is created at runtime on the host and must be
# made accessible to the vscode user. This cannot be done at image-build time.
if [ -e /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock 2>/dev/null || true
    sudo chmod 660 /var/run/docker.sock 2>/dev/null || true
    echo "✅ Docker socket configured"
fi

# ============================================
# DBus Session Bus
# ============================================
# Chrome makes synchronous calls to the session bus; without it each call
# times out (~2s), causing severe keystroke lag. The system bus
# (/run/dbus/system_bus_socket) requires systemd and cannot be started
# here — its absence produces harmless cosmetic errors in Chrome's log.
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    echo "Starting DBus session bus..."
    eval $(dbus-launch --sh-syntax)
    # Persist address so interactive terminals and chrome-xpra can source it
    mkdir -p /home/vscode/.xpra
    echo "export DBUS_SESSION_BUS_ADDRESS='$DBUS_SESSION_BUS_ADDRESS'" \
        > /home/vscode/.xpra/dbus-env
    echo "✅ DBus session bus started"
else
    echo "✅ DBus session bus already running"
fi

# ============================================
# Xpra (GUI Application Streaming)
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
    # --resize-display=yes makes the virtual framebuffer resize to match the
    #   HTML5 browser window, preventing the Chrome viewport from being larger
    #   than the browser and eliminating the need for scrollbars
    xpra start :100 --bind-tcp=0.0.0.0:14500 --html=on --daemon=yes \
        --keyboard-layout=us \
        --resize-display=yes \
        --log-file=/home/vscode/.xpra/xpra.log
    sleep 2
    echo "✅ Xpra started on port 14500"
fi

echo ""
echo "✅ Development environment ready!"
echo ""
echo "Available tools:"
echo "  • Python 3.12 (uv)    • Node.js 22 (npm)"
echo "  • Docker              • GitHub CLI (gh)"
echo "  • act (GitHub Actions) • ripgrep (rg)"
echo "  • fzf                 • yq / jq"
echo "  • Google Chrome       • Xpra (GUI apps)"
echo "  • JupyterLab          • DuckDB"
echo ""
echo "Functional Testing:"
echo "  • Playwright (browser automation, API testing)"
echo "  • HTTPie (API exploration)"
echo "  • pytest (test runner)"
echo ""
echo "Ports:"
echo "  • 8080  - Application server"
echo "  • 14500 - Xpra HTML5 web interface"
echo "  • 8888  - JupyterLab"
echo ""
