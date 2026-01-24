# Docker Development Environment ("Toolbox")

This repository provides a standardized, containerized development environment (the "Toolbox") for managing both this root project and any child projects or modules contained within it.

The environment is built on **Docker** and **Docker Compose**, with **Docker-in-Docker (DinD)** enabled. This architecture allows the main container to act as a "mothership" or toolbox, capable of spinning up and managing its own nested docker containers for individual sub-projects.

**IMPORTANT: Configuration Synchronization**
All Docker configuration files are co-located in `.devcontainer`. When making changes to the development environment, ensure synchronization across:
- `.devcontainer/Dockerfile` ↔ `.devcontainer/devcontainer.json`
- `.devcontainer/docker-compose.yml` ↔ `.devcontainer/devcontainer.json`
- `.devcontainer/postCreateCommand.sh` (shared by both setups)

## Directory Structure

- **`Makefile`**: Convenience wrapper for Docker Compose commands (e.g., `make up`, `make shell`).
- **`README.md`**: This guide.
- **`.devcontainer/`**:
  - **`Dockerfile`**: Builds the development image with Docker CE, Python (uv), Node.js, VNC support, and comprehensive CLI tools.
  - **`devcontainer.json`**: VS Code Dev Container configuration.
  - **`docker-compose.yml`**: Orchestrates the container with Docker-in-Docker enabled.
  - **`requirements.txt`**: Python dependencies (installed at runtime).
  - **`package.json`**: Shared Node.js/NPM tools (e.g., `esbuild`, `prettier`, `typescript`).
  - **`postCreateCommand.sh`**: Setup script that installs dependencies and configures the environment on startup.
- **`projects/`**: Directory where individual child projects should be located.

## Multi-Project Development

This environment is designed to support developing multiple distinct projects simultaneously.

### Project Structure

- Individual projects should be placed as strict children of the `projects` directory.
- Each project should be its own independent Git repository.
- All projects share the running dev container for development tools.

### Workflow

1. **Start the Toolbox**: Run `docker compose up` (or `make up`) in this root directory.
2. **Enter the Container**: Run `make shell` to enter the dev container.
3. **Navigate to Project**: Inside the shell, switch to your project context:
   ```bash
   cd projects/your_specific_project
   ```

### Building and Running Projects

While you rely on the dev container for common development tools (git, python, editors, etc.), you should build and run your applications in their own specific contexts. This ensures isolation and avoids modifying the main toolbox environment.

Common approaches include:

- **JupyterLab**: Open a notebook for data science or interactive coding.
- **Docker**: Build and run a container from the project's `Dockerfile` using the `docker` command available inside the toolbox (via Docker-in-Docker).
- **Docker Compose**: Orchestrate the project's services using its own `docker-compose.yml`.

## Quick Start

You can run this environment in two ways:

### Option 1: VS Code Dev Containers

1. Open this folder in VS Code
2. Install the "Dev Containers" extension
3. Press `F1` → "Dev Containers: Reopen in Container"
4. Wait for the container to build and start

### Option 2: Docker Compose (Makefile)

The easiest way to interact with the environment is via the `make` commands defined in the root directory.

#### 1. Start the Environment

```bash
make up
```

This will:
- Build the development image (if needed)
- Start the container with Docker-in-Docker enabled
- Mount your project directory to `/workspace`
- Run the setup scripts to install Python and Node.js dependencies
- Start VNC server for GUI applications
- Start Docker daemon as the main process

#### 2. Enter the Toolbox

To get a shell inside the running container:

```bash
make shell
```

From here, you can run `python`, `npm`, `docker`, and other tools as if they were installed locally.

#### 3. Check Status

Manage and view the container status:

```bash
# Check running containers
make ps

# View logs
make logs
```

#### 4. Stop the Environment

```bash
make down
```

#### 5. Use VS Code

You can continue using VS Code on your host machine to edit files. The project directory is mounted, so changes are immediately reflected in both the host and container.

Alternatively, use VS Code's "Attach to Running Container" feature:
1. Install the "Dev Containers" extension in VS Code
2. Click the remote indicator in the bottom-left corner
3. Select "Attach to Running Container"
4. Choose `protodev`

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start the development containers |
| `make down` | Stop the containers |
| `make build` | Rebuild the images |
| `make rebuild` | Force rebuild without cache |
| `make shell` | Open a shell in the dev container |
| `make jupyter` | Open a shell in the jupyter container |
| `make logs` | View all container logs |
| `make logs-dev` | View dev container logs only |
| `make logs-jupyter` | View jupyter container logs only |
| `make ps` | Show container status |
| `make restart` | Restart containers |
| `make clean` | Remove containers, images, and volumes |
| `make dev` | Start only the dev container |
| `make jupyter-up` | Start only the jupyter container |
| `make exec CMD="..."` | Run a command in the dev container |
| `make help` | Show all available commands |

## Configuration Options

### SSH Keys

**For Windows users**: The default configuration mounts SSH keys from `%USERPROFILE%\.ssh`

**For Linux/Mac users**: Edit both files:

`.devcontainer/devcontainer.json`:
```json
"mounts": [
    // Comment out the Windows line:
    // "type=bind,source=${localEnv:USERPROFILE}\\.ssh,target=/home/vscode/.ssh-readonly,consistency=cached"
    // Uncomment the Linux/Mac line:
    "type=bind,source=${localEnv:HOME}/.ssh,target=/home/vscode/.ssh-readonly,consistency=cached"
]
```

`.devcontainer/docker-compose.yml`:
```yaml
# Comment out the Windows line:
# - ${USERPROFILE}/.ssh:/home/vscode/.ssh-readonly:ro

# Uncomment the Linux/Mac line:
- ${HOME}/.ssh:/home/vscode/.ssh-readonly:ro
```

### Docker-in-Docker

The environment runs Docker daemon inside the container using Docker-in-Docker. This provides:
- Complete isolation from the host Docker
- Ability to run nested containers
- Persistent Docker data in a named volume (`docker-dind-data`)

**Service-Based Architecture**: The Docker daemon runs as the main container process (foreground), making the container a proper service rather than an interactive shell. The container remains running as long as the Docker daemon is healthy.

The startup sequence:
1. Runs `postCreateCommand.sh` to install dependencies and configure the environment
2. Starts VNC server and noVNC proxy
3. Starts Docker daemon as the main process

**Note**: This requires privileged mode, which is already configured in both `docker-compose.yml` and `devcontainer.json`.

### VNC/noVNC (Virtual Display)

The container includes VNC support for GUI applications like Google Chrome. When running with docker-compose, VNC starts automatically.

Access via:
- **Web browser**: http://localhost:6080/vnc.html (password: `vscode`)
- **VNC client**: `localhost:5901` (password: `vscode`)

From the VNC desktop:
- Right-click to open the Fluxbox menu
- Launch Google Chrome, xterm, or other GUI applications

### Running Chrome in the Container

```bash
# Inside the container
google-chrome --no-sandbox --disable-gpu
```

Or from the VNC desktop, right-click and select "Google Chrome" from the menu.

## Available Ports

| Port | Service |
|------|---------|
| 8080 | Application server |
| 6080 | noVNC web interface |
| 5901 | VNC server |
| 8888 | JupyterLab |

## MCP Servers (Model Context Protocol)

The dev container supports MCP servers, allowing AI assistants like Cline to use custom tools that run inside the container with access to Docker-in-Docker, Python, Node.js, and other container tools.

### Directory Structure

```
.mcp-servers/
├── README.md           # Documentation
├── cline-config.json   # MCP server configuration for Cline
└── example-server/     # Example server template
    ├── package.json
    ├── tsconfig.json
    └── src/
        └── index.ts
```

### How It Works

1. **MCP servers are built automatically** during container startup (`postCreateCommand.sh`)
2. **Servers run inside the container** - they have access to all container tools
3. **Cline connects via stdio** - standard MCP communication protocol

### Using MCP Servers with Cline

When VS Code is connected to the dev container (via "Reopen in Container" or "Attach to Running Container"), you can configure Cline to use the container-based MCP servers.

**Option A: Symlink the config (Recommended)**

Create a symlink from your Cline settings to the workspace config:

**Windows (PowerShell as Admin):**
```powershell
$clineDir = "$env:APPDATA\Code\User\globalStorage\saoudrizwan.claude-dev\settings"
$workspaceConfig = "C:\path\to\protodev\.mcp-servers\cline-config.json"
New-Item -ItemType SymbolicLink -Path "$clineDir\cline_mcp_settings.json" -Target $workspaceConfig -Force
```

**Linux/Mac:**
```bash
ln -sf /path/to/protodev/.mcp-servers/cline-config.json \
    ~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
```

**Option B: Copy the config**

Manually copy `.mcp-servers/cline-config.json` to your Cline settings directory.

### Creating New MCP Servers

Inside the container:

```bash
# Option 1: Use the MCP template generator
cd /workspace/.mcp-servers
npx @modelcontextprotocol/create-server my-server
cd my-server && npm install && npm run build

# Option 2: Copy the example server
cp -r example-server my-server
cd my-server && npm install && npm run build
```

Then add your server to `.mcp-servers/cline-config.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "disabled": false,
      "autoApprove": [],
      "command": "node",
      "args": ["/workspace/.mcp-servers/my-server/build/index.js"],
      "env": {}
    }
  }
}
```

### Example Server Tools

The included example server provides these tools:

| Tool | Description |
|------|-------------|
| `docker_ps` | List running Docker containers (Docker-in-Docker) |
| `run_python` | Execute Python code in the container |
| `list_projects` | List projects in /workspace/projects |
| `check_tool` | Check if a tool is available in the container |

And these resources:

| Resource | Description |
|----------|-------------|
| `container://info` | Container environment information |
| `workspace://structure` | Workspace directory structure |

## Installed Tools

When starting a terminal in our development container you will have a Linux bash shell
enhanced by all the tools here. Note Python should be run using uv.

### Languages & Runtimes
- **Python 3.12** via uv (with numpy, scipy, pandas, matplotlib, jupyter, pytest, playwright)
- **Node.js 22** via NodeSource
- **Bun** (latest)
- **DuckDB** command line
- **SQLite** command line

### Package Managers
- **uv / uvx** - Fast Python package manager
- **pip** - Standard Python package manager
- **pnpm** - Fast, disk space efficient Node.js package manager
- **npm** - Standard Node.js package manager
- **Bun** - All-in-one JavaScript runtime & package manager

### CLI Tools
- **gh** - GitHub CLI for repository management
- **act** - Run GitHub Actions locally
- **fzf** - Fuzzy finder for command line
- **rg** (ripgrep) - Fast recursive grep
- **yq** - YAML processor
- **jq** - JSON processor
- **XMLStarlet** - XML/XSLT/XPath processor
- **FFMPEG** - Video processing
- **GraphicsMagick** - Image processing

This is a very powerful toolset and always consider applying one of these before generating
a custom script.

### Container Tools
- **Docker CE** with Docker Compose
- **docker buildx** - Extended build capabilities

### Development Tools
- **JupyterLab** - Interactive notebooks
- **Ruff** - Fast Python linter/formatter
- **Prettier** - Code formatter (JS/TS)
- **ESBuild** - Fast bundler
- **TypeScript** - Type checking

### GUI Applications
- **Google Chrome** - Web browser for automation/testing
- **Fluxbox** - Lightweight window manager
- **xterm** - Terminal emulator

All Python packages from `.devcontainer/requirements.txt` and Node.js tools from `.devcontainer/package.json` are also installed at runtime.

## Adding Dependencies

### Python Dependencies

Add packages to `.devcontainer/requirements.txt`:

```txt
# Your packages
scikit-learn
torch
transformers
```

Then rebuild or run:
```bash
pip install -r .devcontainer/requirements.txt
```

### Node.js Dependencies

Add packages to `.devcontainer/package.json`:

```json
{
  "devDependencies": {
    "your-package": "^1.0.0"
  }
}
```

Then rebuild or run:
```bash
cd .devcontainer && npm install
```

## Manual Docker Compose (Alternative to Make)

If you prefer not to use `make` (e.g., on Windows without Make installed), you can run standard Docker Compose commands pointing to the configuration file.

### Start the container
```bash
docker compose -f .devcontainer/docker-compose.yml up -d
```

### Stop the container
```bash
docker compose -f .devcontainer/docker-compose.yml down
```

### Rebuild after Dockerfile changes
```bash
docker compose -f .devcontainer/docker-compose.yml up -d --build
```

### View logs
```bash
docker compose -f .devcontainer/docker-compose.yml logs -f dev
```

### Open a shell
```bash
docker compose -f .devcontainer/docker-compose.yml exec dev bash
```

### Remove everything (including volumes)
```bash
docker compose -f .devcontainer/docker-compose.yml down -v
```

## Troubleshooting

### Docker Daemon Not Starting

The Docker daemon runs as the main container process. If the container is running but Docker commands fail, check the container logs:

```bash
# View container logs (includes Docker daemon output)
make logs-dev
# or
docker compose -f .devcontainer/docker-compose.yml logs -f dev

# Manually verify Docker is running inside the container
docker compose -f .devcontainer/docker-compose.yml exec dev docker info
```

If the daemon failed to start, the container will exit. Check why with:
```bash
make ps
make logs-dev
```

If needed, rebuild the container:
```bash
make clean
make up
```

### Permission Issues

The container runs as the `vscode` user with sudo privileges. If you need to run commands as root:

```bash
# Execute commands with sudo inside the container
sudo <command>
```

### SSH Key Permissions

The `postCreateCommand.sh` script automatically copies SSH keys from `/home/vscode/.ssh-readonly` to `/home/vscode/.ssh` with correct permissions. If you have issues:

```bash
# Check SSH key permissions
ls -la ~/.ssh

# Manually fix permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

### VNC Not Working

Check VNC server status:
```bash
vncserver -list
```

View VNC logs:
```bash
cat ~/.vnc/*:1.log
```

Restart VNC manually:
```bash
vncserver -kill :1
rm -rf /tmp/.X11-unix/X1 /tmp/.X1-lock
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
```

### Python Package Installation Issues

If Python packages fail to install:

```bash
make shell
pip install --upgrade pip
pip install -r ./.devcontainer/requirements.txt
```

### Chrome Crashes

Chrome requires sufficient shared memory. The docker-compose configuration includes `shm_size: '2gb'` to prevent crashes. If Chrome still crashes:

```bash
# Run Chrome with additional flags
google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage
```

## Differences: VS Code vs Docker Compose

| Feature | VS Code Dev Container | Docker Compose |
|---------|----------------------|----------------|
| Docker daemon | Started by VS Code | Runs as main process |
| VNC server | Not started by default | Started automatically |
| Container mode | Interactive | Service (background) |
| Access | VS Code attached | `docker exec` or `make shell` |
| File editing | VS Code in container | Any editor on host |

Both setups use the same Dockerfile and `postCreateCommand.sh`, ensuring consistency.

## Example Workflow

```bash
# Start the environment (from project root)
make up

# Open a shell in the container
make shell

# Inside the container, run your development commands
python script.py
npm run dev
docker build -t myapp .

# Edit files on your host with VS Code or any editor
# Changes are immediately available in the container

# Access GUI via browser
# Open http://localhost:6080/vnc.html

# Access JupyterLab
# Open http://localhost:8888

# When done, stop the container
make down
```

## License

MIT
