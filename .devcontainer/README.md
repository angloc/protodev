# Protodev Development Environment

This directory configures a fully-featured Linux development container using the [protodev](https://github.com/angloc/protodev) image. It provides Python, Node.js, Docker, GUI application support, and comprehensive CLI tools.

## Table of Contents

- [Quick Start](#quick-start)
- [Updating Your Devcontainer](#updating-your-devcontainer)
- [Container Runtime: Docker](#container-runtime-docker)
- [Languages & Runtimes](#languages--runtimes)
- [CLI Tools](#cli-tools)
- [Functional Testing](#functional-testing)
- [GUI Applications](#gui-applications)
- [VS Code Extensions](#vs-code-extensions)
- [Port Reference](#port-reference)
- [Bash Aliases](#bash-aliases)
- [Git Authentication](#git-authentication)
- [Running Multiple Projects](#running-multiple-projects)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Option A: VS Code Dev Containers (Recommended)

1. Open your project folder in VS Code
2. Install the "Dev Containers" extension if not already installed
3. Press `F1` → **"Dev Containers: Reopen in Container"**
4. VS Code downloads/builds the container (~2GB on first run) and connects

The container image is cached locally and reused across all your projects.

### Option B: Shell Scripts

Three scripts are provided for working without VS Code:

```bash
# Start a dev container shell
bash .devcontainer/start-shell.sh

# Start a standalone JupyterLab in the background (http://localhost:8888)
bash .devcontainer/start-lab.sh

# Stop the standalone JupyterLab
bash .devcontainer/stop-lab.sh
```

You can alias these in your host `~/.bashrc` or `~/.zshrc` for convenience:

```bash
alias protodev-shell="bash /path/to/project/.devcontainer/start-shell.sh"
alias protodev-lab="bash /path/to/project/.devcontainer/start-lab.sh"
alias protodev-lab-stop="bash /path/to/project/.devcontainer/stop-lab.sh"
```

Override the image version via environment variable:

```bash
IMAGE_NAME=ghcr.io/angloc/protodev:1.0.0 bash .devcontainer/start-shell.sh
```

---

## Updating Your Devcontainer

> **⚠️ Important: Do NOT just update the image version tag!**

The development environment consists of multiple files that work together:

| File | Purpose | May Change Between Versions |
|------|---------|----------------------------|
| `devcontainer.json` | VS Code configuration, extensions, settings | ✅ Yes |
| `postStartCommand.sh` | Runtime services startup (Docker socket, DBus, Xpra) | ✅ Yes |
| `start-shell.sh` | Standalone shell script | ✅ Yes |
| `start-lab.sh` | Standalone JupyterLab script | ✅ Yes |

### How to Update Properly

1. **Download the latest template:**
   ```bash
   # Linux / Mac / Git Bash
   curl -L https://github.com/angloc/protodev/releases/latest/download/devcontainer.zip -o devcontainer.zip
   unzip devcontainer.zip
   rm devcontainer.zip
   ```

   ```powershell
   # Windows PowerShell
   Invoke-WebRequest -Uri https://github.com/angloc/protodev/releases/latest/download/devcontainer.zip -OutFile devcontainer.zip
   Expand-Archive -Path devcontainer.zip -DestinationPath .
   Remove-Item devcontainer.zip
   ```

2. **Review and merge changes:**
   - If you've customised `devcontainer.json`, compare with the new version
   - Merge your customisations with the new baseline

3. **Rebuild the container:**
   - VS Code: `F1` → "Dev Containers: Rebuild Container"
   - Shell scripts: just re-run `start-shell.sh` — it always pulls fresh from the image name

### Pinning to a Specific Version

For reproducible builds, pin to a specific version in `devcontainer.json`:

```json
{
  "image": "ghcr.io/angloc/protodev:1.0.0"
}
```

Or use the `IMAGE_NAME` environment variable with the shell scripts:

```bash
IMAGE_NAME=ghcr.io/angloc/protodev:1.0.0 bash .devcontainer/start-shell.sh
```

Available tags: `latest`, semantic versions (e.g., `1.0.0`), or commit SHAs.

---

## Container Runtime: Docker

This environment uses **Docker** for container management. The container uses the host's Docker daemon via socket mounting.

### How It Works

The development container mounts the host's Docker socket:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

This allows the container to run `docker` commands that execute on the host's Docker daemon.

### Why Privileged Mode is Required

The container runs with `--privileged`:

```json
"runArgs": ["--privileged", "--shm-size=2g"]
```

This is required because:

1. **Docker-in-Docker support:** Running containers inside the dev container requires access to the host's kernel features
2. **Build operations:** Required for building Docker images inside the container
3. **Shared memory:** The 2GB shared memory prevents Chrome crashes

### Running Nested Containers

Build and run containers inside the dev container:

```bash
# Build an image
docker build -t myapp .

# Run a container
docker run -d -p 3000:3000 myapp

# The port is automatically forwarded to your host in DevContainer mode
```

### Docker Compose

Docker Compose is available as both a plugin and standalone command:

```bash
# Plugin syntax (recommended)
docker compose up -d
docker compose down
```

### Port Forwarding from Nested Containers

When you run a container inside the dev container, ports traverse three levels:

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
│  │  • Port 3000 available in dev container                       │  │
│  │  • DevContainer auto-forwards to host                        │  │
│  └───────────────────────────────────────────────────────────────┘  │
│  • Access via localhost:3000 on your host                           │
└─────────────────────────────────────────────────────────────────────┘
```

**DevContainer mode:** Ports are automatically forwarded to your host.

**Shell script mode:** Ports 8080, 14500, and 8888 are mapped by `start-shell.sh`. Add further `-p` flags to the script for additional ports.

---

## Languages & Runtimes

### Python 3.12

- **Package manager:** `uv` (fast, modern replacement for pip)
- **Pre-installed tools:** `ruff` (linter/formatter), `pytest`

```bash
# Install packages
uv pip install numpy pandas

# Run a package directly (like npx)
uvx ruff check .

# Create virtual environment
uv venv
```

### Node.js 22 LTS

- **Package manager:** npm
- **Pre-installed tools:** `esbuild`

```bash
# Install packages
npm install express

# Run commands
npx playwright install
```

### Pre-installed Python Packages

| Package | Purpose |
|---------|---------|
| `jupyter`, `jupyterlab`, `jupyter-ai` | Interactive notebooks |
| `ipykernel` | Jupyter kernel support |
| `ruff` | Fast Python linter & formatter |
| `pytest` | Testing framework |
| `playwright` | Browser automation and API testing |
| `httpie` | Command-line HTTP client |

---

## CLI Tools

### Search & Processing

| Tool | Description | Example |
|------|-------------|---------|
| `rg` (ripgrep) | Fast recursive search | `rg "pattern" .` |
| `jq` | JSON processor | `cat data.json \| jq '.items[]'` |
| `yq` | YAML processor | `yq '.version' config.yaml` |
| `xmlstarlet` | XML processor | `xmlstarlet sel -t -v "//item" file.xml` |
| `fzf` | Fuzzy finder | `find . -type f \| fzf` |

### Development

| Tool | Description | Example |
|------|-------------|---------|
| `gh` | GitHub CLI | `gh pr create`, `gh issue list` |
| `act` | Run GitHub Actions locally | `act push` |
| `docker` | Container runtime | `docker build -t app .` |

### Data & Databases

| Tool | Description | Example |
|------|-------------|---------|
| `duckdb` | Analytical SQL database | `duckdb -c "SELECT * FROM 'data.csv'"` |
| `sqlite3` | SQLite database CLI | `sqlite3 mydb.db` |

### Media Processing

| Tool | Description | Example |
|------|-------------|---------|
| `ffmpeg` | Video/audio processing | `ffmpeg -i input.mp4 output.webm` |
| `gm` (GraphicsMagick) | Image processing | `gm convert input.png output.jpg` |

### Package Managers

| Tool | Description | Example |
|------|-------------|---------|
| `uv` / `uvx` | Python package installer | `uv pip install numpy` |
| `npm` | Node.js package manager | `npm install express` |

---

## Functional Testing

The development environment includes tools for **functional/black-box testing** - tests that exercise the application from the outside, treating it as a "black box" without knowledge of internal implementation.

### Testing Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│  DEVELOPMENT CONTAINER (protodev)                                        │
│                                                                          │
│  ┌────────────────────────┐    ┌────────────────────────────────────┐   │
│  │  Application           │    │  Functional Tests                  │   │
│  │  (in virtual env)      │    │  (run in dev environment)          │   │
│  │                        │    │                                    │   │
│  │  • Source code         │    │  • Playwright (browser + API)      │   │
│  │  • Unit tests          │    │  • HTTPie (API exploration)        │   │
│  │  • Application deps    │    │  • pytest (test runner)            │   │
│  └────────────────────────┘    └────────────────────────────────────┘   │
│           │                              │                               │
│           ▼                              ▼                               │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │  Application Deliverable (container, server, deployment)           │ │
│  └────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

**Key principle:** Functional tests run in the development environment, NOT in the application's virtual environment.

### Test Targets: Local vs Deployed

Configure the target via environment variable:

```bash
# Test against local build
export APP_BASE_URL=http://localhost:8080
pytest tests/functional/

# Test against staging deployment
export APP_BASE_URL=https://staging.example.com
pytest tests/functional/
```

### Playwright for Browser Automation

```python
from playwright.sync_api import sync_playwright
import os

def test_login_flow():
    base_url = os.environ.get("APP_BASE_URL", "http://localhost:8080")

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            executable_path="/usr/bin/google-chrome-stable"
        )
        page = browser.new_page()
        page.goto(f"{base_url}/login")
        # ... test assertions ...
        browser.close()
```

### HTTPie for API Exploration

```bash
# Simple GET request
http GET http://localhost:8080/api/users

# POST with JSON body
http POST http://localhost:8080/api/users name="John" email="john@example.com"
```

---

## GUI Applications

### Xpra HTML5 Virtual Desktop

Access GUI applications through a web browser at **http://localhost:14500**

### Running Chrome

```bash
chrome-xpra &
```

Then open http://localhost:14500 in your browser to interact with Chrome.

### Headless Chrome (for Automation)

```bash
google-chrome --headless --no-sandbox --disable-gpu --dump-dom https://example.com
```

---

## VS Code Extensions

The following extensions are pre-configured in `devcontainer.json`:

- **Python:** `ms-python.python`, `vscode-pylance`, `charliermarsh.ruff`
- **Jupyter:** `ms-toolsai.jupyter` and related
- **JavaScript/TypeScript:** `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`
- **Docker & DevOps:** `ms-azuretools.vscode-docker`, `github.vscode-github-actions`
- **Git:** `eamodio.gitlens`, `mhutchie.git-graph`
- **AI Assistance:** `github.copilot`, `github.copilot-chat`
- **Productivity:** `usernamehw.errorlens`, `streetsidesoftware.code-spell-checker`, and more

---

## Port Reference

| Port | Service | Access |
|------|---------|--------|
| 8080 | Application server | Forwarded automatically |
| 14500 | Xpra HTML5 virtual desktop | http://localhost:14500 |
| 8888 | JupyterLab | Forwarded automatically |

### Starting JupyterLab

**Inside the dev container** (VS Code or `start-shell.sh`):

```bash
lab
```

Access at http://localhost:8888. Use `labstop` to stop it.

**Standalone** (from the host, without entering the container first):

```bash
bash .devcontainer/start-lab.sh   # starts in background
bash .devcontainer/stop-lab.sh    # stops it
```

Access at http://localhost:8888.

---

## Bash Aliases

| Alias | Description |
|-------|-------------|
| `chrome-xpra` | Launch Chrome on Xpra display |
| `lab` | Start JupyterLab in the background |
| `labstop` | Stop JupyterLab |
| `g1` / `g5` / `g10` / `g20` | Git log shortcuts |

---

## Git Authentication

### VS Code Dev Containers (Automatic)

VS Code automatically forwards your Git credentials (HTTPS via Git Credential Manager, and SSH agent). No additional configuration is needed.

### Shell Script Mode (Manual)

Mount your SSH keys by adding a volume to `start-shell.sh`:

```bash
-v "$HOME/.ssh":/home/vscode/.ssh:ro    # Linux/Mac
```

---

## Running Multiple Projects

Multiple protodev containers can run simultaneously because `start-shell.sh` uses `--rm` (containers are ephemeral). If you have port conflicts between projects, edit `start-shell.sh` to use different host ports (e.g., `-p 8081:8080`).

---

## Troubleshooting

### Container Won't Start

Check Docker is running:
```bash
docker info
```

### Docker Commands Fail Inside Container

```bash
ls -la /var/run/docker.sock
```

### Chrome Has Keystroke Lag

```bash
source ~/.xpra/dbus-env
```

### Xpra Not Accessible

```bash
pgrep -x xpra          # Check if running
cat ~/.xpra/xpra.log   # Check logs
```

---

## AI Assistant Configuration

This directory includes agent instruction files:

- **`AGENTS.md`** — Instructions for AI agents about the protodev environment
- **`.clinerules`** — Rules for Cline-specific AI assistants

After extracting the template to your project, incorporate these into your project's own `AGENTS.md` and `.clinerules` files (or copy them to your project root if you don't have these files yet).

---

## Files in This Directory

| File | Purpose |
|------|---------|
| `devcontainer.json` | VS Code Dev Container configuration |
| `postStartCommand.sh` | Runtime setup (Docker socket, DBus, Xpra) |
| `start-shell.sh` | Start a dev container shell (standalone, no VS Code needed) |
| `start-lab.sh` | Start a standalone JupyterLab container (background) |
| `stop-lab.sh` | Stop the standalone JupyterLab container |
| `README.md` | This file |
| `AGENTS.md` | AI agent instructions |
| `.clinerules` | Cline AI assistant rules |

---

## More Information

- **Repository:** https://github.com/angloc/protodev
- **Container registry:** `ghcr.io/angloc/protodev`
- **Releases:** https://github.com/angloc/protodev/releases
