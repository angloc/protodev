# Dev Container Dockerfile
# Reusable development environment with Python (uv), JavaScript (Bun/pnpm), Xpra, and Docker-in-Docker
#
# IMPORTANT: This file is mirrored by the Docker Compose setup
# Any changes to features, ports, mounts, or configuration should be synchronized with:
# - .devcontainer/devcontainer.json
# - .devcontainer/docker-compose.yml
# - .devcontainer/postCreateCommand.sh

FROM python:3.12-bookworm

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set Python to not buffer output (useful for logging)
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set display for Xpra
ENV DISPLAY=:100

# ============================================
# Create vscode user (not present in official Python image)
# ============================================
RUN useradd -m -s /bin/bash vscode \
    && mkdir -p /workspace \
    && chown -R vscode:vscode /workspace

# ============================================
# System packages and CLI tools
# ============================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    gcc \
    g++ \
    make \
    # Common tools
    curl \
    wget \
    git \
    unzip \
    jq \
    supervisor \
    xmlstarlet \
    # Database CLIs
    sqlite3 \
    # Python build dependencies (for compiled packages)
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    liblzma-dev \
    # For matplotlib
    libfreetype6-dev \
    libpng-dev \
    pkg-config \
    # Media processing
    ffmpeg \
    graphicsmagick \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Xpra for GUI application streaming
# ============================================
# Add Xpra repository (not available in standard Debian repos)
RUN wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc \
    && echo "deb [signed-by=/usr/share/keyrings/xpra.asc] https://xpra.org/ bookworm main" > /etc/apt/sources.list.d/xpra.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    xpra \
    x11-utils \
    xdg-utils \
    xterm \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Google Chrome (for browser automation/testing)
# ============================================
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb \
    && apt-get update \
    && apt-get install -y /tmp/chrome.deb || apt-get -y -f install \
    && rm /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Docker CE (for Docker-in-Docker support)
# ============================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Ensure 'docker' group exists and add vscode to it
RUN groupadd -f docker && usermod -aG docker vscode

# ============================================
# yq - YAML processor
# ============================================
RUN curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# ============================================
# ripgrep (rg) - Fast recursive search
# ============================================
RUN curl -fsSL https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb -o /tmp/ripgrep.deb \
    && dpkg -i /tmp/ripgrep.deb \
    && rm /tmp/ripgrep.deb

# ============================================
# fzf - Fuzzy finder
# ============================================
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /opt/fzf \
    && /opt/fzf/install --all --no-zsh --no-fish

# ============================================
# GitHub CLI (gh)
# ============================================
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# act - Run GitHub Actions locally
# ============================================
RUN curl -fsSL https://raw.githubusercontent.com/nektos/act/master/install.sh | bash -s -- -b /usr/local/bin

# ============================================
# DuckDB CLI - Analytical SQL database
# ============================================
RUN curl -fsSL https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip -o /tmp/duckdb.zip \
    && unzip /tmp/duckdb.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/duckdb \
    && rm /tmp/duckdb.zip

# ============================================
# uv - Fast Python package installer
# ============================================
RUN curl -LsSf https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz \
    | tar xz -C /usr/local/bin --strip-components=1 \
    && chmod +x /usr/local/bin/uv /usr/local/bin/uvx

# Add Python local bin to PATH for vscode user
ENV PATH="/home/vscode/.local/bin:$PATH"

# ============================================
# Node.js 22 LTS
# ============================================
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ============================================
# Bun - Fast JavaScript runtime & package manager
# ============================================
ENV BUN_INSTALL="/usr/local/bun"
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="$BUN_INSTALL/bin:$PATH"

# ============================================
# pnpm - Fallback package manager
# ============================================
RUN npm install -g pnpm

# ============================================
# Python packages via uv (system-wide)
# ============================================
RUN uv pip install --python 3.12 --system \
    numpy \
    scipy \
    matplotlib \
    pandas \
    jupyter \
    jupyterlab \
    jupyter-ai \
    ipykernel \
    ruff \
    pytest \
    pytest-cov \
    pytest-playwright \
    playwright \
    openai \
    PyYAML \
    Jinja2 \
    requests

# ============================================
# Playwright browser setup (use existing Chrome)
# ============================================
# Set Playwright to use the system Chrome instead of downloading browsers
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

# ============================================
# Configure fzf for bash
# ============================================
RUN echo '[ -f /opt/fzf/shell/key-bindings.bash ] && source /opt/fzf/shell/key-bindings.bash' >> /etc/bash.bashrc \
    && echo '[ -f /opt/fzf/shell/completion.bash ] && source /opt/fzf/shell/completion.bash' >> /etc/bash.bashrc

# ============================================
# Xpra configuration for vscode user
# ============================================
RUN mkdir -p /home/vscode/.xpra \
    && chown -R vscode:vscode /home/vscode/.xpra

# ============================================
# Expose ports
# ============================================
# 8080: Application server
# 14500: Xpra HTML5 web interface
# 8888: JupyterLab
EXPOSE 8080 14500 8888

# ============================================
# Set working directory
# ============================================
WORKDIR /workspace

# Switch to vscode user
USER vscode

# Default command
CMD ["bash"]