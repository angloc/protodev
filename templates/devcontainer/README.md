# Dev Container Template

A ready-to-use development container with Python (uv), Node.js 22, Bun, and common development tools.

## Quick Start

Copy the `.devcontainer` folder to your project:

```bash
# From your project root
mkdir -p .devcontainer
curl -o .devcontainer/devcontainer.json \
  https://raw.githubusercontent.com/angloc/protodev/main/templates/devcontainer/.devcontainer/devcontainer.json
```

Or manually copy `templates/devcontainer/.devcontainer/` to your project.

Then open in VS Code and select **"Reopen in Container"**.

## What's Included

### Languages & Runtimes
- **Python 3.12** with uv package manager
- **Node.js 22** LTS
- **Bun** - fast JavaScript runtime
- **pnpm** - efficient package manager

### Pre-installed Python Packages
- numpy, scipy, pandas, matplotlib
- jupyter, jupyterlab, jupyter-ai
- ruff, pytest, pytest-cov

### CLI Tools
- Docker-in-Docker (build containers inside the dev container)
- GitHub CLI (`gh`)
- `act` - run GitHub Actions locally
- `yq` - YAML processor
- `ripgrep` (`rg`) - fast search
- `fzf` - fuzzy finder

### VS Code Extensions
Python, Jupyter, ESLint, Prettier, Docker, GitLens, GitHub Copilot, and more.

## Customization

### Pin a specific version

```json
{
  "image": "ghcr.io/angloc/protodev:sha-abc1234"
}
```

### Add project-specific tools

```json
{
  "image": "ghcr.io/angloc/protodev:latest",
  "postCreateCommand": "pip install -r requirements.txt && npm install"
}
```

### Extend with additional features

```json
{
  "image": "ghcr.io/angloc/protodev:latest",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/aws-cli:1": {},
    "ghcr.io/devcontainers/features/terraform:1": {}
  }
}
```

## Container Registry

Images are published to GitHub Container Registry:

```
ghcr.io/angloc/protodev:latest      # Latest main branch
ghcr.io/angloc/protodev:1.0.0       # Semantic version
ghcr.io/angloc/protodev:sha-abc1234 # Specific commit
```

Pull directly:

```bash
docker pull ghcr.io/angloc/protodev:latest
```
