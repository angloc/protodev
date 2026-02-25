#!/bin/bash
#
# postCreateCommand.sh - Runtime setup for development environment
#
# This script runs when the container is first created.
# Git configuration, bash aliases and environment variables are baked into
# the image (see Dockerfile). This script handles only tasks that require
# a running container with host resources mounted.

set -e

echo "🚀 Running postCreateCommand.sh..."

# ============================================
# Docker Socket Permissions
# ============================================
# The Docker daemon socket is created at runtime and must be made accessible
# to the vscode user. This cannot be done at image-build time.
if [ -e /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock 2>/dev/null || true
    sudo chmod 660 /var/run/docker.sock 2>/dev/null || true
    echo "✅ Docker socket configured"
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
echo "Ports:"
echo "  • 8080  - Application server"
echo "  • 14500 - Xpra HTML5 web interface"
echo "  • 8888  - JupyterLab"
echo ""
