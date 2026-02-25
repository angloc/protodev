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
# Start DBus session bus (required by Chrome for input handling)
# ============================================
# Chrome makes synchronous calls to the session bus; without it each call
# times out (~2s), causing severe keystroke lag.  The system bus
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
