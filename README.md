# Protodev - Development Environment

A containerized development environment with Python (uv), JavaScript (Bun/pnpm), VNC for GUI apps, and Docker-in-Docker support.

## Features

- **Python 3.12** via uv with scientific packages (numpy, scipy, pandas, matplotlib)
- **Node.js 22** with Bun and pnpm
- **Docker-in-Docker** for container operations
- **VNC/noVNC** for running GUI applications (e.g., Chrome)
- **Google Chrome** for browser automation and testing
- **Comprehensive CLI tools**: gh, act, fzf, ripgrep, yq, jq

## Quick Start

You can run this environment in two ways:

### Option 1: VS Code Dev Containers (Recommended)

1. Open this folder in VS Code
2. Install the "Dev Containers" extension
3. Press `F1` → "Dev Containers: Reopen in Container"
4. Wait for the container to build and start

### Option 2: Docker Compose (Standalone)

```bash
# Start the development containers
make up

# Open a shell in the container
make shell

# Stop the containers
make down
```

## Directory Structure

```
.
├── .devcontainer/
│   ├── Dockerfile              # Container image definition
│   ├── devcontainer.json       # VS Code Dev Container config
│   ├── docker-compose.yml      # Standalone Docker Compose config
│   ├── postCreateCommand.sh    # Setup script (SSH, git, deps)
│   ├── requirements.txt        # Python dependencies
│   └── package.json            # Node.js dependencies
├── Makefile                    # Docker Compose convenience commands
├── projects/                   # Child projects directory
└── README.md                   # This file
```

## Usage

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start the development containers |
| `make down` | Stop the containers |
| `make build` | Rebuild the images |
| `make rebuild` | Force rebuild without cache |
| `make shell` | Open a shell in the dev container |
| `make jupyter` | Open a shell in the jupyter container |
| `make logs` | View all container logs |
| `make ps` | Show container status |
| `make clean` | Remove containers, images, and volumes |
| `make help` | Show all available commands |

### Available Ports

| Port | Service |
|------|---------|
| 8080 | Application server |
| 6080 | noVNC web interface (password: `vscode`) |
| 5901 | VNC server |
| 8888 | JupyterLab |

### Accessing the Virtual Display

When running with docker-compose, a VNC server is started automatically:

1. **Web browser**: Open http://localhost:6080/vnc.html (password: `vscode`)
2. **VNC client**: Connect to `localhost:5901` (password: `vscode`)

From the VNC desktop, you can:
- Right-click to open the Fluxbox menu
- Launch Google Chrome or xterm
- Run any GUI application

### Running Chrome

```bash
# Inside the container
google-chrome --no-sandbox --disable-gpu
```

## Configuration

### SSH Keys

SSH keys are mounted read-only and copied to the container with proper permissions.

**Windows users** (default): Uses `%USERPROFILE%\.ssh`

**Linux/Mac users**: Edit these files:
- `.devcontainer/devcontainer.json`: Uncomment the Linux mount, comment the Windows mount
- `.devcontainer/docker-compose.yml`: Same as above

### Adding Python Dependencies

Add packages to `.devcontainer/requirements.txt`:

```txt
# Add your packages
pandas
scikit-learn
torch
```

### Adding Node.js Dependencies

Add packages to `.devcontainer/package.json`:

```json
{
  "devDependencies": {
    "your-package": "^1.0.0"
  }
}
```

## Installed Tools

### Languages & Runtimes
- Python 3.12 (via uv)
- Node.js 22 (via NodeSource)
- Bun (latest)

### Package Managers
- uv / uvx (Python)
- pnpm (Node.js)
- npm (Node.js)
- Bun (Node.js)

### CLI Tools
- **gh** - GitHub CLI
- **act** - Run GitHub Actions locally
- **fzf** - Fuzzy finder
- **rg** (ripgrep) - Fast recursive search
- **yq** - YAML processor
- **jq** - JSON processor
- **docker** - Container runtime
- **docker compose** - Container orchestration

### Development
- JupyterLab
- Ruff (Python linter/formatter)
- Prettier (JS/TS formatter)
- ESBuild (bundler)
- TypeScript

### GUI
- Google Chrome
- Fluxbox (window manager)
- xterm

## Docker-in-Docker

The environment supports running Docker commands inside the container:

```bash
# Inside the container
docker ps
docker build -t myimage .
docker compose up -d
```

When using docker-compose, the Docker daemon runs as the main container process. The Jupyter container connects to the dev container's Docker daemon.

## Multi-Project Development

This environment is designed as a "toolbox" for developing multiple projects:

1. Place projects in the `projects/` directory
2. Each project can have its own Dockerfile for production builds
3. Use the toolbox container for development, but build/run projects in their own containers

## Troubleshooting

### Container won't start

Check logs:
```bash
make logs
```

### Docker commands fail inside container

Ensure the Docker daemon is running:
```bash
docker info
```

If using VS Code, you may need to restart the container after the Docker daemon starts.

### VNC not working

Check VNC server status:
```bash
vncserver -list
```

Restart VNC:
```bash
vncserver -kill :1
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
```

### SSH keys not working

SSH keys are copied from the read-only mount during setup. Check permissions:
```bash
ls -la ~/.ssh
```

### Permission issues

The container runs as `vscode` user with sudo privileges:
```bash
sudo <command>
```

## Configuration Synchronization

**IMPORTANT**: When modifying the development environment, keep these files in sync:
- `.devcontainer/Dockerfile`
- `.devcontainer/devcontainer.json`
- `.devcontainer/docker-compose.yml`
- `.devcontainer/postCreateCommand.sh`

## License

MIT
