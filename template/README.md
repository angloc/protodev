# Dev Container Template

A ready-to-use development container with Python (uv), Node.js 22, Bun, Docker-in-Docker, and comprehensive development tools.

## Quick Start

### Option 1: VS Code Dev Containers (Recommended)

1. Extract this template to your project root
2. Open the folder in VS Code
3. Install the "Dev Containers" extension if not already installed
4. Press `F1` → **"Dev Containers: Reopen in Container"**
5. Wait for the container to start (first run downloads the image)

That's it! The container image is downloaded once and cached locally.

### Option 2: Docker Compose + Makefile

**Requirements:**
- `make` utility
- Docker Compose (via Docker Desktop, Podman, or Rancher Desktop)
- **Windows**: WSL (Windows Subsystem for Linux)

```bash
# Start the environment
make up

# Open a shell in the container
make shell

# Stop the environment
make down
```

### Option 3: Direct Docker Compose

If you don't have `make` installed:

```bash
# Start the container
docker compose -f .devcontainer/docker-compose.yml up -d

# Open a shell
docker compose -f .devcontainer/docker-compose.yml exec dev bash

# Stop the container
docker compose -f .devcontainer/docker-compose.yml down
```

## What's Included

### Languages & Runtimes
- **Python 3.12** with uv package manager
- **Node.js 22** LTS with npm/pnpm
- **Bun** - fast JavaScript runtime

### Pre-installed Python Packages
- numpy, scipy, pandas, matplotlib
- jupyter, jupyterlab, jupyter-ai
- ruff, pytest, pytest-cov

### CLI Tools
- **Docker-in-Docker** - Build and run containers inside the dev container
- **GitHub CLI** (`gh`) - Repository management
- **act** - Run GitHub Actions locally
- **ripgrep** (`rg`) - Fast recursive search
- **fzf** - Fuzzy finder
- **yq** / **jq** - YAML/JSON processors
- **ffmpeg** - Video processing
- **GraphicsMagick** - Image processing

### GUI Support (via VNC)
- **Google Chrome** - Browser automation/testing
- **Fluxbox** - Window manager
- **noVNC** - Browser-based VNC access at http://localhost:6080

### VS Code Extensions
Python, Jupyter, ESLint, Prettier, Docker, GitLens, GitHub Copilot, and more.

## Available Ports

| Port | Service |
|------|---------|
| 8080 | Application server |
| 6080 | noVNC web interface (password: `vscode`) |
| 5901 | VNC server |
| 8888 | JupyterLab |

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start the development containers |
| `make down` | Stop the containers |
| `make shell` | Open a shell in the dev container |
| `make jupyter` | Open a shell in the jupyter container |
| `make logs` | View container logs |
| `make ps` | Show container status |
| `make restart` | Restart containers |
| `make clean` | Remove containers and volumes |
| `make pull` | Pull the latest container image |
| `make exec CMD="..."` | Run a command in the dev container |
| `make help` | Show all available commands |

## Customization

### Add Project Dependencies

Create a `requirements.txt` or `package.json` in your project root. The `postCreateCommand.sh` script will automatically install them on container start.

```txt
# requirements.txt
scikit-learn
torch
transformers
```

```json
// package.json
{
  "devDependencies": {
    "vitest": "^1.0.0"
  }
}
```

### Pin a Specific Container Version

Edit `.devcontainer/devcontainer.json`:

```json
{
  "image": "ghcr.io/angloc/protodev:sha-abc1234"
}
```

### Git Authentication

VS Code Dev Containers **automatically forwards your Git credentials** to the container. No manual configuration is needed for most users.

#### HTTPS (Recommended)
If you use HTTPS URLs for Git remotes (e.g., `https://github.com/user/repo.git`):
- VS Code automatically forwards credentials from Git Credential Manager
- Works on Windows, macOS, and Linux
- No additional setup required

#### SSH
If you prefer SSH URLs for Git remotes (e.g., `git@github.com:user/repo.git`):
- VS Code forwards your local SSH agent automatically
- Ensure your SSH agent is running and keys are loaded:
  ```bash
  # Check if agent is running
  ssh-add -l
  
  # Add your key if needed
  ssh-add ~/.ssh/id_ed25519
  ```
- **Windows**: Enable the OpenSSH Authentication Agent service
- **macOS/Linux**: The agent typically runs automatically

#### Verify Authentication
Inside the container, test your Git access:
```bash
# For HTTPS
git ls-remote https://github.com/your-username/your-repo.git

# For SSH
ssh -T git@github.com
```

### AI Coding Assistants

The `postCreateCommand.sh` includes commented-out installation scripts for various AI coding assistants:

- **Cline CLI**
- **Claude Code** (Anthropic)
- **OpenAI Codex CLI**
- **Open Code**
- **Google Antigravity**

Uncomment the ones you want to use and ensure you have the required API keys.

### MCP Servers (Model Context Protocol)

This template includes an `.mcp-servers/` directory with:
- An example MCP server that demonstrates how to create tools and resources
- Configuration for Cline (`cline-config.json`)

MCP servers are automatically built during container startup and can be used with Cline and other MCP-compatible AI coding assistants. See `.mcp-servers/README.md` for:
- How to create new MCP servers
- Registering servers with Cline
- Troubleshooting tips

## Running Multiple Projects

Container names are automatically generated from your project directory name:
- `myproject-dev-1`, `myproject-jupyter-1`

This allows you to run multiple projects simultaneously without port conflicts (adjust port mappings in `docker-compose.yml` if needed).

## Container Registry

Images are published to GitHub Container Registry:

```
ghcr.io/angloc/protodev:latest      # Latest main branch
ghcr.io/angloc/protodev:1.0.0       # Semantic version
ghcr.io/angloc/protodev:sha-abc1234 # Specific commit
```

## Troubleshooting

### Docker Daemon Not Starting

Check container logs:
```bash
make logs-dev
```

If the daemon fails, rebuild:
```bash
make clean
make up
```

### VNC Not Working

Access via browser: http://localhost:6080/vnc.html (password: `vscode`)

Check VNC server status inside the container:
```bash
vncserver -list
```

### Chrome Crashes

Run with additional flags:
```bash
google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage
```

## License

MIT
