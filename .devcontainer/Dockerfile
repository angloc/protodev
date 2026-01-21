# Dev Container Dockerfile
# Reusable development environment with Python (uv) and JavaScript (Bun/pnpm)

FROM mcr.microsoft.com/devcontainers/base:debian

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set Python to not buffer output (useful for logging)
ENV PYTHONUNBUFFERED=1

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
    && rm -rf /var/lib/apt/lists/*

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
# Python 3.12 via deadsnakes (if not available) or use pyenv
# Using uv to manage Python
# ============================================

# Install uv - Fast Python package manager
ENV UV_INSTALL_DIR="/usr/local"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH
ENV PATH="/usr/local/bin:$PATH"

# Install Python 3.12 via uv
RUN uv python install 3.12

# Set Python 3.12 as default
ENV PATH="/root/.local/share/uv/python/cpython-3.12.*/bin:$PATH"

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
# Python packages via uv
# ============================================
RUN uv pip install --system \
    # Scientific computing
    numpy \
    scipy \
    matplotlib \
    pandas \
    # Jupyter
    jupyter \
    jupyterlab \
    jupyter-ai \
    ipykernel \
    # Development tools
    ruff \
    pytest \
    pytest-cov \
    # OpenAI Codex CLI
    openai

# ============================================
# Configure fzf for bash
# ============================================
RUN echo '[ -f /opt/fzf/shell/key-bindings.bash ] && source /opt/fzf/shell/key-bindings.bash' >> /etc/bash.bashrc \
    && echo '[ -f /opt/fzf/shell/completion.bash ] && source /opt/fzf/shell/completion.bash' >> /etc/bash.bashrc

# ============================================
# Set working directory
# ============================================
WORKDIR /workspace

# Default command
CMD ["bash"]
