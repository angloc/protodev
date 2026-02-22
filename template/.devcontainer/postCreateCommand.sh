#!/bin/bash
#
# postCreateCommand.sh - Runtime setup for development environment
#
# This script runs when the container is first created.
# It configures the environment for development work.

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
# Git Authentication
# ============================================
# VS Code automatically forwards Git credentials (HTTPS) and SSH agent.
# No manual SSH key setup required for most users.
# See README.md for more details on Git authentication options.
echo "✅ Git authentication: using VS Code's automatic credential forwarding"

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
# Environment Variables
# ============================================
export PYTHONDONTWRITEBYTECODE=1

# ============================================
# Useful Aliases
# ============================================
if [ -f ~/.bashrc ]; then
    if ! grep -q "^# protodev aliases" ~/.bashrc 2>/dev/null; then
        cat <<'EOF' >> ~/.bashrc

# protodev aliases
alias chrome-xpra='DISPLAY=:100 google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage --no-first-run --disable-sync --new-window'
alias g1='git log -1 --oneline'
alias g5='git log -5 --oneline'
alias g10='git log -10 --oneline'
alias g20='git log -20 --oneline'
EOF
        echo "✅ Added protodev aliases to ~/.bashrc"
    else
        echo "✅ protodev aliases already present in ~/.bashrc"
    fi
fi

# ============================================
# MCP Servers (Model Context Protocol)
# ============================================
# Build MCP servers for use with Cline and other MCP-compatible tools
if [ -d ./.mcp-servers ]; then
    echo "Building MCP servers..."
    for server_dir in ./.mcp-servers/*/; do
        if [ -f "${server_dir}package.json" ]; then
            server_name=$(basename "$server_dir")
            echo "  Building MCP server: $server_name"
            (cd "$server_dir" && npm install --silent && npm run build --silent 2>/dev/null || true)
        fi
    done
    echo "✅ MCP servers built"
fi

# ============================================
# Project Dependencies
# ============================================
# Install Python packages from requirements.txt if present
if [ -f ./requirements.txt ]; then
    echo "Installing Python dependencies from requirements.txt..."
    uv pip install --system -r ./requirements.txt
    echo "✅ Python dependencies installed"
fi

# Install Node.js packages from package.json if present
if [ -f ./package.json ]; then
    echo "Installing Node.js dependencies..."
    npm install --silent
    echo "✅ Node.js dependencies installed"
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
echo "  • 8080 - Application server"
echo "  • 14500 - Xpra HTML5 web interface"
echo "  • 8888 - JupyterLab"
echo ""
