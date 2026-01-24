# Docker Development Environment

A pre-built, standardized development container with Python, Node.js, and comprehensive development tools. Add it to any project directory and get a consistent development environment instantly.

The container image is downloaded once and cached locally, then can be used across all your projects.

## Quick Start

### Step 1: Download the Template

Download `devcontainer.zip` from the [latest release](https://github.com/angloc/protodev/releases/latest) and extract it to your project root.

Or use curl:

```bash
# Download and extract to current directory
curl -L https://github.com/angloc/protodev/releases/latest/download/devcontainer.zip -o devcontainer.zip
unzip devcontainer.zip
rm devcontainer.zip
```

### Step 2: Open in VS Code

1. Open your project folder in VS Code
2. Install the "Dev Containers" extension if needed
3. Press `F1` → **"Dev Containers: Reopen in Container"**

The container image downloads on first use (~2GB) and is cached for future projects.

## Alternative: Docker Compose + Makefile

If you prefer command-line workflow or don't use VS Code:

**Requirements:**
- `make` utility
- Docker Compose (via Docker Desktop, Podman, or Rancher Desktop)
- **Windows**: WSL (Windows Subsystem for Linux)

```bash
# Start the environment
make up

# Open a shell in the container
make shell

# Your project code is available at /workspace

# Stop when done
make down
```

## What's Included

### Languages & Runtimes
| Tool | Version |
|------|---------|
| Python | 3.12 (with uv package manager) |
| Node.js | 22 LTS (with npm, pnpm) |
| Bun | Latest |
| DuckDB | CLI |
| SQLite | CLI |

### Pre-installed Python Packages
numpy, scipy, pandas, matplotlib, jupyter, jupyterlab, pytest, ruff, playwright

### CLI Tools
| Tool | Description |
|------|-------------|
| `docker` | Docker-in-Docker (build containers inside the container) |
| `gh` | GitHub CLI |
| `act` | Run GitHub Actions locally |
| `rg` | ripgrep - fast recursive search |
| `fzf` | Fuzzy finder |
| `yq` / `jq` | YAML/JSON processors |
| `ffmpeg` | Video processing |
| `gm` | GraphicsMagick image processing |

### GUI Applications (via VNC)
- Google Chrome (for browser automation)
- Fluxbox window manager
- noVNC web-based access

### VS Code Extensions
Python, Jupyter, ESLint, Prettier, Docker, GitLens, GitHub Copilot, and more - all pre-configured.

## Available Ports

| Port | Service |
|------|---------|
| 8080 | Application server |
| 6080 | noVNC web interface (password: `vscode`) |
| 5901 | VNC server |
| 8888 | JupyterLab |

## Customization

### Project Dependencies

The container automatically installs dependencies from:
- `requirements.txt` - Python packages (pip)
- `package.json` - Node.js packages (npm)

Just add these files to your project root.

### SSH Keys

SSH keys are mounted read-only from your host machine for git operations.

**Windows** (default): Mounts from `%USERPROFILE%\.ssh`

**Linux/Mac**: Edit `.devcontainer/devcontainer.json` and `.devcontainer/docker-compose.yml` to use `${HOME}/.ssh` instead.

### Pin Container Version

For reproducible builds, pin to a specific version in `.devcontainer/devcontainer.json`:

```json
{
  "image": "ghcr.io/angloc/protodev:1.0.0"
}
```

Available tags:
- `latest` - Latest main branch build
- `1.0.0` - Semantic version
- `sha-abc1234` - Specific commit

### AI Coding Assistants

The `postCreateCommand.sh` includes commented-out installation scripts for:
- Cline CLI
- Claude Code (Anthropic)
- OpenAI Codex CLI
- Open Code

Uncomment the ones you want and provide the required API keys.

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start containers |
| `make down` | Stop containers |
| `make shell` | Open bash shell |
| `make jupyter` | Open jupyter shell |
| `make logs` | View logs |
| `make ps` | Container status |
| `make clean` | Remove containers & volumes |
| `make pull` | Update container image |
| `make exec CMD="..."` | Run command |
| `make help` | Show all commands |

## Multiple Projects

Container names are auto-generated from your project directory:
- `myproject-dev-1`, `myproject-jupyter-1`

Run multiple projects simultaneously (adjust port mappings if needed).

## VNC / GUI Access

Access the virtual desktop at http://localhost:6080/vnc.html (password: `vscode`)

Run Chrome:
```bash
google-chrome --no-sandbox --disable-gpu
```

## Container Registry

```
ghcr.io/angloc/protodev:latest
ghcr.io/angloc/protodev:1.0.0
ghcr.io/angloc/protodev:sha-abc1234
```

Pull directly:
```bash
docker pull ghcr.io/angloc/protodev:latest
```

## Troubleshooting

### Container Won't Start

```bash
make logs-dev    # Check logs
make clean       # Remove and recreate
make up
```

### VNC Not Working

Inside container:
```bash
vncserver -list
cat ~/.vnc/*:1.log
```

### Chrome Crashes

```bash
google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage
```

### Permission Issues

The container runs as `vscode` user with sudo access:
```bash
sudo <command>
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for information on building the container image and contributing to this project.

## License

MIT
