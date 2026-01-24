#!/bin/bash
#
# postCreateCommand.sh - Runtime setup for development environment
#
# This script runs when the container starts and configures the environment
# for development. It handles:
# - Git configuration
# - SSH key setup
# - Docker socket permissions
# - Project-specific dependencies (requirements.txt, package.json)
# - Optional AI coding assistant installation

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
# Install project-specific Python dependencies if requirements.txt exists
if [ -f ./requirements.txt ]; then
    echo "Installing Python dependencies from requirements.txt..."
    pip install --upgrade pip --quiet
    pip install --no-cache-dir -r ./requirements.txt --quiet
    echo "✅ Python dependencies installed"
elif [ -f ./.devcontainer/requirements.txt ]; then
    echo "Installing Python dependencies from .devcontainer/requirements.txt..."
    pip install --upgrade pip --quiet
    pip install --no-cache-dir -r ./.devcontainer/requirements.txt --quiet
    echo "✅ Python dependencies installed"
else
    echo "⚠️  No requirements.txt found"
fi

# ============================================
# Node.js Dependencies (from package.json)
# ============================================
# Install project-specific Node.js dependencies if package.json exists
if [ -f ./package.json ]; then
    echo "Installing NPM dependencies from package.json..."
    npm install --silent
    echo "✅ NPM dependencies installed"
elif [ -f ./.devcontainer/package.json ]; then
    echo "Installing NPM tools from .devcontainer/package.json..."
    (cd .devcontainer && npm install --silent)

    # Add node_modules/.bin to PATH if not already present
    DEVCONTAINER_BIN="$(pwd)/.devcontainer/node_modules/.bin"
    if ! grep -q "export PATH=\$PATH:${DEVCONTAINER_BIN}" ~/.bashrc 2>/dev/null; then
        echo "export PATH=\$PATH:${DEVCONTAINER_BIN}" >> ~/.bashrc
    fi
    echo "✅ NPM tools installed"
else
    echo "⚠️  No package.json found"
fi

# ============================================
# Environment Variables
# ============================================
export PYTHONDONTWRITEBYTECODE=1

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
# AI Coding Assistants (Optional)
# ============================================
# Uncomment the tool(s) you want to use. Each requires appropriate API keys.
# See documentation for each tool for setup instructions.

# --------------------------------------------
# Cline CLI
# Terminal-based AI coding assistant
# Docs: https://github.com/cline/cline
# Usage: cline
# --------------------------------------------
# echo "Installing Cline CLI..."
# npm install -g cline
# echo "✅ Cline CLI installed. Run: cline"

# --------------------------------------------
# Google Antigravity
# A browser-based AI coding assistant from Google
# Requires: Google account authentication
# Usage: antigravity --no-sandbox --disable-gpu
# --------------------------------------------
# echo "Installing Google Antigravity..."
# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg
# echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
# sudo apt-get update && sudo apt-get install -y antigravity
# echo "✅ Antigravity installed. Run via VNC: antigravity --no-sandbox --disable-gpu"

# --------------------------------------------
# Claude Code (Anthropic)
# Terminal-based AI coding assistant from Anthropic
# Requires: ANTHROPIC_API_KEY environment variable
# Docs: https://docs.anthropic.com/en/docs/claude-code
# Usage: claude
# --------------------------------------------
# echo "Installing Claude Code..."
# npm install -g @anthropic-ai/claude-code
# echo "✅ Claude Code installed. Set ANTHROPIC_API_KEY and run: claude"

# --------------------------------------------
# OpenAI Codex CLI (codex)
# Terminal-based AI coding assistant from OpenAI
# Requires: OPENAI_API_KEY environment variable
# Docs: https://github.com/openai/codex
# Usage: codex
# --------------------------------------------
# echo "Installing OpenAI Codex CLI..."
# npm install -g @openai/codex
# echo "✅ Codex installed. Set OPENAI_API_KEY and run: codex"

# --------------------------------------------
# Open Code
# Open-source AI coding assistant
# Requires: API key for your chosen provider (OpenAI, Anthropic, etc.)
# Docs: https://github.com/opencode-ai/opencode
# Usage: opencode
# --------------------------------------------
# echo "Installing Open Code..."
# uv pip install --system opencode-ai
# echo "✅ Open Code installed. Configure your API key and run: opencode"

# --------------------------------------------
# Google Conductor
# AI-powered build and development system from Google
# Requires: Google Cloud authentication
# Docs: https://cloud.google.com/conductor
# Usage: conductor
# --------------------------------------------
# echo "Installing Google Conductor..."
# curl -fsSL https://dl.google.com/conductor/install.sh | bash
# echo "✅ Conductor installed. Authenticate with gcloud and run: conductor"

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
