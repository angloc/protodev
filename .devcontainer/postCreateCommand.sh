#!/bin/bash
#
# postCreateCommand.sh - Runtime setup for development environment
#
# IMPORTANT: This script is used by both .devcontainer and docker-compose setups
# Any changes should be compatible with both environments and synchronized with:
# - .devcontainer/devcontainer.json
# - .devcontainer/Dockerfile
# - .devcontainer/docker-compose.yml

set -e

echo "🚀 Running postCreateCommand.sh..."

# ============================================
# Git Configuration
# ============================================
# Avoid problems with ownership by container versus host user
git config --global --add safe.directory '*'

# Avoid problems with line endings (especially on Windows)
git config --global core.autocrlf input

echo "✅ Git configured"

# ============================================
# SSH Key Setup
# ============================================
# Copy ssh credentials from read-only mount to mutable location
if [ -d /home/vscode/.ssh-readonly ]; then
    echo "Setting up SSH keys..."
    sudo mkdir -p ~/.ssh
    sudo cp -r ~/.ssh-readonly/* ~/.ssh/ 2>/dev/null || true
    sudo chmod 700 ~/.ssh
    sudo find ~/.ssh -type f ! -name "*.pub" \
                ! -name "config" \
                ! -name "known_hosts*" \
                -exec chmod 600 {} \; 2>/dev/null || true
    sudo find ~/.ssh -type f \( -name "*.pub" \
                        -o -name "config" \
                        -o -name "known_hosts*" \) \
                -exec chmod 644 {} \; 2>/dev/null || true
    sudo chown -R vscode ~/.ssh
    echo "✅ SSH keys configured"
else
    echo "⚠️  No SSH keys found at /home/vscode/.ssh-readonly"
fi

# ============================================
# Docker Socket Permissions
# ============================================
# Ensure the Docker daemon socket is available to the vscode user
if [ -e /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock 2>/dev/null || true
    sudo chmod 660 /var/run/docker.sock 2>/dev/null || true
    echo "✅ Docker socket configured"
fi
sudo usermod -aG docker vscode 2>/dev/null || true

# ============================================
# Python Dependencies (from requirements.txt)
# ============================================
if [ -f ./.devcontainer/requirements.txt ]; then
    echo "Installing Python dependencies..."
    pip install --upgrade pip --quiet
    pip install --no-cache-dir -r ./.devcontainer/requirements.txt --quiet
    echo "✅ Python dependencies installed"
else
    echo "⚠️  No .devcontainer/requirements.txt found"
fi

# ============================================
# Node.js Dependencies (from package.json)
# ============================================
if [ -f ./.devcontainer/package.json ]; then
    echo "Installing NPM tools..."
    (cd .devcontainer && npm install --silent)

    # Add node_modules/.bin to PATH if not already present
    DEVCONTAINER_BIN="$(pwd)/.devcontainer/node_modules/.bin"
    if ! grep -q "export PATH=\$PATH:${DEVCONTAINER_BIN}" ~/.bashrc 2>/dev/null; then
        echo "export PATH=\$PATH:${DEVCONTAINER_BIN}" >> ~/.bashrc
    fi
    echo "✅ NPM tools installed"
else
    echo "⚠️  No .devcontainer/package.json found"
fi

# ============================================
# Environment Variables
# ============================================
export PYTHONDONTWRITEBYTECODE=1

echo ""
echo "✅ Development environment ready!"
echo ""
echo "Available tools:"
echo "  • Python 3.12 (uv)    • Node.js 22 (npm/pnpm)"
echo "  • Bun                 • Docker"
echo "  • GitHub CLI (gh)     • act (GitHub Actions)"
echo "  • ripgrep (rg)        • fzf"
echo "  • yq                  • jq"
echo "  • Google Chrome       • VNC (port 5901)"
echo ""
echo "Ports:"
echo "  • 8080 - Application server"
echo "  • 6080 - noVNC web interface (password: vscode)"
echo "  • 5901 - VNC server"
echo "  • 8888 - JupyterLab"
echo ""
