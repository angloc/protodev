# Contributing to protodev

This document covers how to build the container image from source and contribute to this project.

## Repository Structure

```
protodev/
├── .devcontainer/           # Full build setup (for maintainers)
│   ├── Dockerfile           # Container image definition
│   ├── docker-compose.yml   # Development orchestration
│   ├── devcontainer.json    # VS Code Dev Container config
│   ├── postCreateCommand.sh # Runtime setup script (runs once after create)
│   ├── postStartCommand.sh  # Runtime setup script (runs on every start)
│   ├── generate-template.sh # Template generation script
│   ├── requirements.txt     # Python dependencies
│   └── package.json         # Node.js dependencies
├── template/                # Distribution template for users
│   ├── .devcontainer/       # Pre-built image configuration
│   ├── .protodev/           # Documentation and agent mandates
│   │   ├── README.md        # User documentation
│   │   └── AGENTS.md        # AI agent documentation
│   └── Makefile             # Convenience commands
├── .github/workflows/       # CI/CD pipelines
│   └── docker-publish.yml   # Build and publish workflow
├── .mcp-servers/            # MCP server examples
├── README.md                # User documentation
├── CONTRIBUTING.md          # This file
└── Makefile                 # Development commands
```

## Building the Container Image

### Prerequisites

- Docker with Docker Compose
- Git
- (Optional) VS Code with Dev Containers extension

### Build Locally

```bash
# Clone the repository
git clone https://github.com/angloc/protodev.git
cd protodev

# Build the image
make build

# Or force rebuild without cache
make rebuild
```

### Run the Development Environment

```bash
# Start the containers
make up

# Enter the container
make shell

# View logs
make logs

# Stop
make down
```

### VS Code Development

1. Open the `protodev` folder in VS Code
2. Press `F1` → "Dev Containers: Reopen in Container"
3. VS Code will build and start the container

## Configuration Files

### Important: Configuration Synchronization

When making changes to the development environment, ensure synchronization across:

- `.devcontainer/Dockerfile` ↔ `.devcontainer/devcontainer.json`
- `.devcontainer/docker-compose.yml` ↔ `.devcontainer/devcontainer.json`
- `.devcontainer/postCreateCommand.sh` (shared by both setups)

### Dockerfile

Located at `.devcontainer/Dockerfile`. This defines the container image with:

- Base image (Debian-based)
- System packages and tools
- Language runtimes (Python, Node.js, Bun)
- GUI support (VNC, Chrome)
- Docker-in-Docker support

### docker-compose.yml

Located at `.devcontainer/docker-compose.yml`. Orchestrates:

- Dev container service (main development environment)
- Jupyter container service (JupyterLab)
- Volume mounts (project files, SSH keys, Docker data)
- Port mappings
- VNC/noVNC startup

### devcontainer.json

Located at `.devcontainer/devcontainer.json`. Configures VS Code Dev Container:

- Build configuration
- VS Code extensions
- Editor settings
- Port forwarding
- Environment variables

### postCreateCommand.sh

Located at `.devcontainer/postCreateCommand.sh`. Runs on container start:

- Git configuration
- SSH key setup
- Docker socket permissions
- Dependency installation (requirements.txt, package.json)
- MCP server builds
- AI assistant installation (optional)

## Adding New Tools

### System Packages

Edit `.devcontainer/Dockerfile`:

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package \
    && rm -rf /var/lib/apt/lists/*
```

### Python Packages

Add to `.devcontainer/requirements.txt`:

```txt
your-package>=1.0.0
```

### Node.js Packages

Add to `.devcontainer/package.json`:

```json
{
  "devDependencies": {
    "your-package": "^1.0.0"
  }
}
```

### VS Code Extensions

Add to `.devcontainer/devcontainer.json`:

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "publisher.extension-id"
      ]
    }
  }
}
```

## Template Updates

The `template/` directory contains files distributed to users in `devcontainer.zip`. Some files are auto-generated, others are maintained manually:

### Auto-generated Files (via `make template`)

These files are generated from the root `.devcontainer/` configuration:

- **template/.devcontainer/devcontainer.json**: Generated from root `.devcontainer/devcontainer.json` with `build` replaced by `image`
- **template/.devcontainer/docker-compose.yml**: Generated from root `.devcontainer/docker-compose.yml` with `build` replaced by `image`
- **template/.devcontainer/postCreateCommand.sh**: Copied from root `.devcontainer/postCreateCommand.sh`
- **template/.devcontainer/postStartCommand.sh**: Copied from root `.devcontainer/postStartCommand.sh`

Run `make template` to regenerate these files after changing the root `.devcontainer/` configuration.

### Manually Maintained Files

These files are maintained directly in `template/` and are not auto-generated:

- **template/Makefile**: Convenience commands for users (mirrors user-facing commands)
- **template/.protodev/README.md**: User documentation for the devcontainer
- **template/.protodev/AGENTS.md**: AI agent documentation and usage guidance

**Note:** The `.mcp-servers/` directory is included directly from the repository root in the release zip (not duplicated in templates/). Updates to MCP servers only need to be made once in the root `.mcp-servers/` directory.

### Generating the Template

To regenerate the auto-generated files from the root `.devcontainer/` configuration:

```bash
make template
```

This runs `.devcontainer/generate-template.sh` which:
- Copies shell scripts from `.devcontainer/` to `template/.devcontainer/`
- Transforms `devcontainer.json` to use pre-built images (removes `build`, adds `image`)
- Transforms `docker-compose.yml` to use pre-built images (removes `build`, adds `image`)

## CI/CD Pipeline

### GitHub Actions Workflow

The `.github/workflows/docker-publish.yml` workflow:

1. **On push to main**: Builds and pushes image tagged `latest`
2. **On tag (v*)**: Builds and pushes semantic version tags
3. **Creates devcontainer.zip**: Packages the template for users
4. **Uploads to Release**: Attaches zip to GitHub Releases

### Triggering a Release

```bash
# Tag a new version
git tag v1.0.0
git push origin v1.0.0
```

This triggers the workflow to:
- Build and push `ghcr.io/angloc/protodev:1.0.0`
- Create GitHub Release with `devcontainer.zip` attached

## Makefile Commands (Development)

| Command | Description |
|---------|-------------|
| `make up` | Start containers |
| `make down` | Stop containers |
| `make build` | Build images |
| `make rebuild` | Force rebuild without cache |
| `make shell` | Open shell in dev container |
| `make jupyter` | Open shell in jupyter container |
| `make logs` | View all logs |
| `make logs-dev` | View dev container logs |
| `make logs-jupyter` | View jupyter logs |
| `make ps` | Show container status |
| `make restart` | Restart containers |
| `make clean` | Remove containers, images, volumes |
| `make dev` | Start only dev container |
| `make jupyter-up` | Start only jupyter container |
| `make exec CMD="..."` | Run command in container |
| `make template` | Generate template from root .devcontainer/ |
| `make help` | Show all commands |

**Note:** The root Makefile is for maintainers building the container image. The template Makefile (distributed to users) includes a `make pull` command for updating the pre-built image.

## MCP Servers

The repository includes MCP (Model Context Protocol) server examples for AI coding assistants.

### Directory Structure

```
.mcp-servers/
├── README.md           # MCP documentation
├── cline-config.json   # Cline MCP configuration
└── example-server/     # Example server template
    ├── package.json
    ├── tsconfig.json
    └── src/index.ts
```

### Building MCP Servers

MCP servers are built automatically during container startup. To build manually:

```bash
cd .mcp-servers/example-server
npm install
npm run build
```

### Creating New MCP Servers

```bash
cd .mcp-servers
npx @modelcontextprotocol/create-server my-server
cd my-server && npm install && npm run build
```

Add to `.mcp-servers/cline-config.json`:

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

## Testing Changes

### Local Testing

1. Make changes to Dockerfile or configuration
2. Rebuild: `make rebuild`
3. Test: `make shell` and verify tools work
4. Test VS Code: "Reopen in Container"

### Template Testing

1. Create a test directory
2. Copy template files: `cp -r template/* /tmp/test-project/`
3. Open in VS Code and test "Reopen in Container"

## Code Style

- **Shell scripts**: Use `shellcheck` for linting
- **YAML**: Use consistent 2-space indentation
- **JSON**: Use consistent 2-space indentation
- **Dockerfile**: Follow Docker best practices (layer caching, multi-stage builds)

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Update documentation if needed
5. Submit a pull request

### PR Checklist

- [ ] Dockerfile changes tested locally
- [ ] Configuration files synchronized
- [ ] Template updated (if applicable)
- [ ] README/docs updated
- [ ] No hardcoded paths or secrets

## License

MIT - See [LICENSE](LICENSE) for details.
