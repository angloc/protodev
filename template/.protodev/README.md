# Dev Container Template

A fully-featured Linux development environment in a container, ready for Python, Node.js, and Docker-based projects. Use it with VS Code Dev Containers or standalone with Docker Compose.

## What You Get

This template provides a **Linux development container** that runs on any host (Windows, macOS, or Linux). Your code lives on your host machine but executes in a standardized environment with all tools pre-installed.

**Key features:**
- **Python 3.12** with uv package manager
- **Node.js 22 LTS** with npm/pnpm
- **Bun** JavaScript runtime
- **Docker-in-Docker** — build and run containers inside the dev container
- **VNC/noVNC** — graphical applications and browser automation
- **Comprehensive CLI tools** — search, data processing, GitHub integration
- **MCP server support** — extend AI coding assistants with custom tools

---

## Quick Start: Applying This Template to a New Project

### Step 1: Download the Template

Download `devcontainer.zip` from the [latest release](https://github.com/angloc/protodev/releases/latest) and extract it to your project root.

**Linux / Mac / Git Bash:**
```bash
curl -L https://github.com/angloc/protodev/releases/latest/download/devcontainer.zip -o devcontainer.zip
unzip devcontainer.zip
rm devcontainer.zip
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri https://github.com/angloc/protodev/releases/latest/download/devcontainer.zip -OutFile devcontainer.zip
Expand-Archive -Path devcontainer.zip -DestinationPath .
Remove-Item devcontainer.zip
```

> **Tip:** On Windows, if you use [Git Bash](https://git-scm.com/downloads) or run VS Code in [WSL](https://learn.microsoft.com/en-us/windows/wsl/), you can use the Linux/bash commands above. Running VS Code in WSL gives you the same experience as native Linux.

### Step 2: Customise for Your Project

After extracting the template, you may choose to pin it for your project:

1. **Add dependencies:**
   - Create `requirements.txt` in your project root for Python packages
   - Create `package.json` in your project root for Node.js packages
   - the postCreateCommand.sh will install these when the container is (re)built
1. **Pin a specific container version:**
   Edit `.devcontainer/devcontainer.json` to use a specific tag instead of `latest`:
   ```json
   {
     "image": "ghcr.io/angloc/protodev:1.0.0"
   }
   ```

1. **Configure VS Code extensions:**
   Add/remove extensions in `.devcontainer/devcontainer.json` → `customizations.vscode.extensions`

1. **Set up MCP servers:**
   The `.mcp-servers/` directory is included with an example server. Create your own MCP servers here and register them in `.mcp-servers/cline-config.json`. MCP servers are installed when you startup your container.


### Step 2: Choose Your Workflow

#### Option A: VS Code Dev Containers (Recommended)

1. Open your project folder in VS Code
2. Install the "Dev Containers" extension if not already installed
3. Press `F1` → **"Dev Containers: Reopen in Container"**
4. VS Code builds/downloads the container (~2GB on first run) and connects to it

The container image is cached locally and reused across all your projects.

#### Option B: Docker Compose + Makefile

For command-line workflows or when not using VS Code:

**Requirements:**
- `make` utility
- Docker Compose (via Docker Desktop, Podman, or Rancher Desktop)
- **Windows:** WSL (Windows Subsystem for Linux)

```bash
# Start the environment
make up

# Open a shell in the container
make shell

# Your project code is available at /workspace

# Stop when done
make down
```

#### Option C: Direct Docker Compose

If you don't have `make`:

```bash
# Start the container
docker compose -f .devcontainer/docker-compose.yml up -d

# Open a shell
docker compose -f .devcontainer/docker-compose.yml exec dev bash

# Stop the container
docker compose -f .devcontainer/docker-compose.yml down
```

---

## Installed Tools Catalog

### Languages & Runtimes

| Tool | Version | Description |
|------|---------|-------------|
| Python | 3.12 | Primary language with uv package manager |
| Node.js | 22 LTS | JavaScript runtime with npm, pnpm |
| Bun | Latest | Fast JavaScript runtime & package manager |

### Pre-installed Python Packages

These are baked into the `ghcr.io/angloc/protodev` image:

| Package | Purpose |
|---------|---------|
| numpy, scipy, pandas, matplotlib | Scientific computing & visualization |
| jupyter, jupyterlab, jupyter-ai | Interactive notebooks |
| ipykernel | Jupyter kernel support |
| ruff | Fast Python linter & formatter |
| pytest, pytest-cov, pytest-playwright | Testing framework |
| playwright | Browser automation |
| openai | OpenAI API client |
| PyYAML | YAML processing |
| Jinja2 | Template engine |
| requests | legacy HTTP client |
| httpx | modern HTTP client |

### Pre-installed Node.js Tools

| Tool | Purpose |
|------|---------|
| esbuild | Fast JavaScript bundler |
| prettier | Code formatter |
| TypeScript | Type-safe JavaScript |

### CLI Tools

| Tool | Description |
|------|-------------|
| `docker` | **Docker-in-Docker** — build and run containers inside the container |
| `gh` | GitHub CLI — repository management, PRs, issues |
| `act` | Run GitHub Actions locally |
| `rg` (ripgrep) | Fast recursive search (prefer over `grep -r`) |
| `fzf` | Fuzzy finder for interactive selection |
| `jq` | JSON processor |
| `yq` | YAML processor |
| `xmlstarlet` | XML processor |
| `duckdb` | Analytical SQL database CLI (great for CSV/Parquet) |
| `sqlite3` | SQLite database CLI |
| `ffmpeg` | Video/audio processing |
| `gm` (GraphicsMagick) | Image processing and conversion |

### GUI Applications (via VNC)

| Tool | Purpose |
|------|---------|
| Google Chrome | Browser automation and testing (use `--no-sandbox --disable-gpu`) |
| Fluxbox | Lightweight window manager |
| noVNC | Browser-based VNC access at http://localhost:6080 |

### VS Code Extensions

| Extension | Purpose |
|-----------|---------|
| ms-python.python, vscode-pylance, ruff | Python development |
| ms-toolsai.jupyter | Jupyter notebooks |
| dbaeumer.vscode-eslint, prettier-vscode | JavaScript/TypeScript |
| oven.bun-vscode | Bun support |
| ms-azuretools.vscode-docker | Docker integration |
| github.vscode-github-actions | GitHub Actions |
| eamodio.gitlens, mhutchie.git-graph | Git tooling |
| github.copilot, github.copilot-chat | AI assistance |
| And more... | See `devcontainer.json` for full list |

### MCP Servers (Model Context Protocol)

The `.mcp-servers/` directory contains:

| Component | Description |
|-----------|-------------|
| `cline-config.json` | MCP server configuration for Cline |
| `example-server/` | Template MCP server with tools and resources |
| `README.md` | Documentation for creating MCP servers |

MCP servers extend AI coding assistants (like Cline) with custom capabilities. They are automatically built during container startup.

---

## Available Ports

| Port | Service | Access |
|------|---------|--------|
| 8080 | Application server | Forwarded to host automatically |
| 6080 | noVNC web interface | http://localhost:6080 (password: `vscode`) |
| 5901 | VNC server | VNC client to localhost:5901 |
| 8888 | JupyterLab | Forwarded but not auto-started in DevContainer mode |

---

## Exposing Ports from Docker-in-Docker

A key feature of this environment is **Docker-in-Docker** — you can build and run containers inside the dev container. Understanding how ports flow through nested containers is essential.

### Port Forwarding Chain

When you run an application in a container inside the dev container, ports must traverse three levels:

```
┌─────────────────────────────────────────────────────────────────────┐
│  YOUR HOST (Windows/macOS/Linux)                                    │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  DEV CONTAINER (protodev)                                     │  │
│  │  ┌─────────────────────────────────────────────────────────┐  │  │
│  │  │  INNER CONTAINER (your app)                             │  │  │
│  │  │  • App listens on :3000                                 │  │  │
│  │  │  • docker run -p 3000:3000 exposes to dev container     │  │  │
│  │  └─────────────────────────────────────────────────────────┘  │  │
│  │  • Port 3000 is now available in dev container                │  │
│  │  • DevContainer forwards ports to host automatically        │  │
│  └───────────────────────────────────────────────────────────────┘  │
│  • Host can access via localhost:3000                               │
│  • External access requires binding to 0.0.0.0                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Example: Inner Container Port Mapping

**In the dev container, run:**
```bash
# Start a container that exposes port 3000
docker run -d -p 3000:3000 --name myapp myimage
```

**Access from host:**
- DevContainer mode: Port 3000 is automatically forwarded to `localhost:3000` on your host
- Docker Compose mode: Add port mapping to `docker-compose.yml` or use `docker run -p`

### Example: Multiple Ports

```bash
# Inner container exposing multiple ports
docker run -d \
  -p 3000:3000 \
  -p 8080:8080 \
  -p 5432:5432 \
  --name myapp \
  myimage
```

### Exposing to External Networks (Beyond Localhost)

To make your application accessible from other machines on your network:

#### Step 1: Bind to 0.0.0.0 in the inner container

```bash
# Ensure your application listens on all interfaces, not just localhost
# This is typically the default, but some frameworks default to 127.0.0.1

# Example: Node.js
node server.js --host 0.0.0.0

# Example: Python Flask
flask run --host=0.0.0.0

# Example: Docker container
docker run -p 0.0.0.0:3000:3000 myimage
```

#### Step 2: Configure host firewall

**Windows:**
```powershell
# Allow inbound connections on port 3000
New-NetFirewallRule -DisplayName "DevContainer Port 3000" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow
```

**macOS:**
System Preferences → Security & Privacy → Firewall → Firewall Options → Add rule

**Linux:**
```bash
sudo ufw allow 3000/tcp
# or
sudo iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
```

#### Step 3: Access from external machines

Find your host's IP address:
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig  # or ip addr
```

Other machines can now access: `http://YOUR_HOST_IP:3000`

### Docker Compose vs DevContainer Differences

| Feature | DevContainer Mode | Docker Compose Mode |
|---------|-------------------|---------------------|
| Port forwarding | Automatic via VS Code | Explicit in `docker-compose.yml` |
| Docker-in-Docker | Works via postStartCommand | Works via entrypoint |
| VNC/noVNC | Started via postStartCommand | Started via entrypoint |
| Jupyter | Manual start | Auto-started via jupyter service |

---

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Start the development containers |
| `make down` | Stop the containers |
| `make shell` | Open a bash shell in the dev container |
| `make jupyter` | Open a shell in the jupyter container |
| `make logs` | View container logs (follow mode) |
| `make logs-dev` | View dev container logs |
| `make logs-jupyter` | View jupyter logs |
| `make ps` | Show container status |
| `make restart` | Restart containers |
| `make clean` | Remove containers and volumes |
| `make pull` | Pull the latest container image |
| `make dev` | Start only the dev container |
| `make jupyter-up` | Start only the jupyter container |
| `make exec CMD="..."` | Run a command in the dev container |
| `make help` | Show all available commands |

---

## Customisation

### Project Dependencies

Add a `requirements.txt` to your project root for Python packages:

```txt
# requirements.txt
scikit-learn
torch
transformers
```

Add a `package.json` for Node.js packages:

```json
{
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "vitest": "^1.0.0"
  }
}
```

These are installed automatically when the container starts via `postCreateCommand.sh`.

### Pin Container Version

For reproducible builds, pin to a specific version in `.devcontainer/devcontainer.json`:

```json
{
  "image": "ghcr.io/angloc/protodev:1.0.0"
}
```

Available tags:
- `latest` — Latest main branch build
- `v1.0.0` — Semantic version (see repo for current details)
- `sha-abc1234` — Specific commit

### Git Authentication

VS Code Dev Containers **automatically forwards your Git credentials** to the container. No manual configuration is needed for most users.

#### HTTPS (Recommended)

If you use HTTPS URLs for Git remotes:
- VS Code automatically forwards credentials from Git Credential Manager
- Works on Windows, macOS, and Linux
- No additional setup required

#### SSH

If you prefer SSH URLs for Git remotes:
- VS Code forwards your local SSH agent automatically
- Ensure your SSH agent is running and keys are loaded:
  ```bash
  # Check if agent is running
  ssh-add -l

  # Add your key if needed
  ssh-add ~/.ssh/id_ed25519
  ```

#### Verify Authentication

Inside the container, test your Git access:
```bash
# For HTTPS
git ls-remote https://github.com/your-username/your-repo.git

# For SSH
ssh -T git@github.com
```

### AI Coding Assistants

The `postCreateCommand.sh` includes commented-out installation scripts for:

| Tool | Provider | Requirement |
|------|----------|-------------|
| Cline CLI | — | Terminal AI assistant |
| Claude Code | Anthropic | `ANTHROPIC_API_KEY` env var |
| OpenAI Codex | OpenAI | `OPENAI_API_KEY` env var |
| Open Code | Open-source | Provider API key |
| Google Antigravity | Google | Google account auth |
| Google Conductor | Google | Google Cloud auth |

Uncomment the ones you want to use in `.devcontainer/postCreateCommand.sh` and ensure you have the required API keys.

### MCP Servers

The `.mcp-servers/` directory is included with this template. It contains:

1. **Example server** (`example-server/`) — A template MCP server
2. **Cline config** (`cline-config.json`) — Register your MCP servers here
3. **Documentation** (`README.md`) — How to create and register MCP servers

MCP servers are automatically built during container startup. To create a new one:

```bash
cd /workspace/.mcp-servers
npx @modelcontextprotocol/create-server my-server
cd my-server && npm install && npm run build
```

Then register it in `cline-config.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/workspace/.mcp-servers/my-server/build/index.js"]
    }
  }
}
```

---

## Running Multiple Projects

Container names are auto-generated from your project directory:
- `myproject-dev-1`, `myproject-jupyter-1`

This allows you to run multiple projects simultaneously. If you have port conflicts, edit `.devcontainer/docker-compose.yml` to adjust port mappings:

```yaml
ports:
  - "8081:8080"  # Map container 8080 to host 8081
  - "6081:6080"
  - "5902:5901"
```

---

## VNC / GUI Access

Access the virtual desktop at http://localhost:6080/vnc.html (password: `vscode`)

Run Chrome:
```bash
google-chrome --no-sandbox --disable-gpu
```

Or run Chrome headless for automation:
```bash
google-chrome --headless --no-sandbox --disable-gpu --dump-dom https://example.com
```

---

## Troubleshooting

### Container Won't Start

```bash
make logs-dev    # Check logs
make clean       # Remove and recreate
make up
```

### Docker Daemon Not Starting

Check if the daemon is running:
```bash
docker info
```

If not, the `postStartCommand.sh` (DevContainer) or entrypoint (Docker Compose) should have started it. Check the startup logs.

### VNC Not Working

Access via browser: http://localhost:6080/vnc.html (password: `vscode`)

Check VNC server status inside the container:
```bash
vncserver -list
cat ~/.vnc/*:1.log
```

### Chrome Crashes

Run with additional flags:
```bash
google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage
```

### Permission Issues

The container runs as `vscode` user with sudo access:
```bash
sudo <command>
```

---

## Container Registry

Images are published to GitHub Container Registry:

```
ghcr.io/angloc/protodev:latest       # Latest main branch
ghcr.io/angloc/protodev:1.0.0      # Semantic version
ghcr.io/angloc/protodev:sha-abc123 # Specific commit
```

Pull directly:
```bash
docker pull ghcr.io/angloc/protodev:latest
```

---

## More Information

- **Repository:** https://github.com/angloc/protodev
- **MCP Documentation:** `.mcp-servers/README.md`
- **Contributing:** See CONTRIBUTING.md in the main repository
