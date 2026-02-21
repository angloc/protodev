# Docker Development Environment

This is the repository for building the standard rich development environment.

The rich development environment is a pre-built, standardized Docker container with Python, Node.js, and comprehensive development tools. Add it to a project directory and get a consistent development environment instantly.

The container image is downloaded once and cached locally, then can be used across many projects.

 The environment is built by a github workflow in
`.github/workflows/docker-publish.yml`. The deliverables are:
- a Docker image providing the environment
- a zip of a .devcontainer folder that is added to the project repo to facilitate using the environment

The purpose of this project is to maintain the environment and publish the deliverables. So this README file is describing
how to maintain the project. User documentation for the environment itself is part of the deliverable package and is stored in the `template` folder. The files there are relevant only to environment users, not to yourself as an environment maintainer.

## Quick Start

### Step 1: Download the Template

Download `devcontainer.zip` from the [latest release](https://github.com/angloc/protodev/releases/latest) and extract it to your project root.

**Linux/Mac/Git Bash:**

```bash
# Download and extract to current directory
curl -L https://github.com/angloc/protodev/releases/latest/download/devcontainer.zip -o devcontainer.zip
unzip devcontainer.zip
rm devcontainer.zip
```

**Windows (PowerShell):**

```powershell
# Download and extract to current directory
Invoke-WebRequest -Uri https://github.com/angloc/protodev/releases/latest/download/devcontainer.zip -OutFile devcontainer.zip
Expand-Archive -Path devcontainer.zip -DestinationPath .
Remove-Item devcontainer.zip
```

> **Tip:** On Windows, if you use [Git Bash](https://git-scm.com/downloads) or run VS Code in [WSL](https://learn.microsoft.com/en-us/windows/wsl/), you can use the Linux/bash commands above. Opening VS Code in WSL gives you the same experience as running on a native Linux distribution.

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
- xstra web-based window manager and virtual display

### VS Code Extensions
Python, Jupyter, ESLint, Prettier, Docker, GitLens, GitHub Copilot, and more - all pre-configured.

## Available Ports

| Port | Service |
|------|---------|
| 8080 | Application server |
| 14500 | Xpra HTML5 virtual desktop |
| 8888 | JupyterLab |

## Customization

### Project Dependencies

The container automatically installs dependencies from:
- `requirements.txt` - Python packages (pip)
- `package.json` - Node.js packages (npm)

Just add these files to your project root.

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

#### Agent Mandates

This template includes a `.protodev/AGENTS.md` file that defines the mandate for AI agents working in this environment. **Projects using this devcontainer should reference `.protodev/AGENTS.md` in their own agent mandates** to ensure agents take maximum advantage of the tools and conventions provided.

Add this to your project's agent configuration (e.g., `CLAUDE.md`, `.clinerules`, or similar):

```markdown
# Mandate
**You must rigorously follow the provisions and instructions defined in `.protodev/AGENTS.md`.**

Always refer to `.protodev/AGENTS.md` for information about the development environment and take full advantage of the tools provided. Do not install or use alternatives.
```

This ensures AI assistants understand the full capabilities of the development environment and follow consistent patterns across all projects using this container.

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

## GUI Access (Xpra)

Access the virtual desktop at http://localhost:14500

Run Chrome:
```bash
DISPLAY=:1 google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage --no-first-run --disable-sync &
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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for information on building the container image and contributing to this project.

## License

MIT
