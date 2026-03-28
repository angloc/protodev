# Protodev - Container Development Environment

This repository builds and publishes a standardized development environment container. The container image provides Python, Node.js, and comprehensive development tools that can be used across many projects.

## For Project Users

> **If you're looking to use protodev in your project, you're in the wrong place!**

This is the **build repository** for maintainers. To use protodev in your project:

1. **Download the template** from [releases](https://github.com/angloc/protodev/releases/latest)
2. **Extract to your project** root directory
3. **Read the documentation** at `.devcontainer/README.md` after extraction

For complete usage instructions, see the [devcontainer documentation](.devcontainer/README.md) that gets distributed with each release.

---

## For Repository Maintainers

The following documentation is for maintaining this build and publish repository.

This is a **build and publish repository** that also dogfoods its own output. It maintains:

1. **Dockerfile** - The build recipe for the `ghcr.io/angloc/protodev` container image
2. **.devcontainer/** - The definitive devcontainer configuration, used both by this repo and distributed to users

## Architecture

```
/workspace
├── Dockerfile                    # Build recipe (source of truth for the image)
├── .devcontainer/                # Definitive devcontainer config (also shipped in releases)
│   ├── devcontainer.json         # Uses ghcr.io/angloc/protodev:latest
│   ├── postStartCommand.sh       # Background services startup (Docker socket, DBus, Xpra)
│   ├── start-shell.sh            # Standalone: start a dev container shell
│   ├── start-lab.sh              # Standalone: start a JupyterLab container (background)
│   ├── stop-lab.sh               # Standalone: stop the JupyterLab container
│   ├── README.md                 # User-facing documentation
│   ├── AGENTS.md                 # AI agent instructions (user-facing)
│   └── .clinerules               # Cline AI rules (user-facing)
├── tests/                        # Container tests
│   ├── conftest.py               # Test fixtures (supports in-container and CI modes)
│   ├── test_startup.py
│   ├── test_tools.py
│   ├── test_services.py
│   └── test_docker_in_docker.py
├── .github/workflows/
│   ├── docker-publish.yml        # Builds image, creates devcontainer.zip
│   └── container-tests.yml      # Runs tests in CI
├── Makefile                      # Maintainer commands
└── README.md                     # This file
```

## Build Process

### Automatic Build (GitHub Actions)

The workflow triggers on:
- Push to `main` branch → builds and pushes `latest` tag
- Push of version tags (`v1.0.0`) → builds and pushes semantic version tags
- Pull requests → builds only (no push)

The workflow:
1. Builds the Docker image from `./Dockerfile`
2. Pushes to `ghcr.io/angloc/protodev` with appropriate tags
3. Creates `devcontainer.zip` from the `.devcontainer/` folder
4. Attaches the zip to GitHub Releases (for version tags)

### Local Build

```bash
# Build for local testing (test tag)
make build

# Build tagged as the published image (dogfood testing)
make dogfood
```

## Dogfood Workflow

This repo uses its own output — the `.devcontainer/` config points at `ghcr.io/angloc/protodev:latest`, which can be built and tagged locally with `make dogfood`.

### Testing the Container

```bash
# Step 1: Build and tag locally
make dogfood

# Step 2a: Rebuild devcontainer in VS Code
#   Ctrl+Shift+P → "Dev Containers: Rebuild Container"
#   Then inside the container:
make test

# Step 2b: Or run standalone and shell in
docker run -it --rm --privileged --shm-size=2gb \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  -p 8080:8080 -p 14500:14500 -p 8888:8888 \
  -e DISPLAY=:100 --workdir /workspace \
  ghcr.io/angloc/protodev:latest bash
# Then inside the container:
make test
```

`make test` runs pytest directly in the current context — no container orchestration needed, because you're already inside the container being tested.

### CI Workflow (outside container)

For CI or testing without being inside the container:

```bash
make build    # Build test-tagged image
make pytest   # Start fresh container, run tests, tear down
```

## Versioning

The image uses semantic versioning:

| Tag | Description |
|-----|-------------|
| `latest` | Most recent main branch build |
| `1.0.0` | Semantic version release |
| `1.0` | Major.minor version |
| `1` | Major version |
| `sha-abc1234` | Specific commit |

To create a release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Making Changes

### Updating the Container Image

1. Edit `Dockerfile` to add/remove tools
2. Test locally: `make dogfood` then `make test` (inside container)
3. Commit and push to main (or create PR)
4. GitHub Actions will build and push the new image

### Updating the Devcontainer Config

Edit files in `.devcontainer/`. These are both:
- Used by this repo when developing in the container
- Packaged into `devcontainer.zip` for users to download

### Adding New Tools

Tools should only be added to the Dockerfile if they are:
- **Project-agnostic** - Useful across many project types
- **Stable** - Well-maintained with consistent APIs
- **Lightweight** - Won't significantly bloat the image

Project-specific tools should be installed via:
- `requirements.txt` for Python packages
- `package.json` for Node.js packages
- User's own `postCreateCommand.sh` modifications

## Container Registry

Images are published to GitHub Container Registry:

```
ghcr.io/angloc/protodev:latest
ghcr.io/angloc/protodev:1.0.0
ghcr.io/angloc/protodev:sha-abc1234
```

Pull directly:

```bash
docker pull ghcr.io/angloc/protodev:latest
```

## Container Runtime

The development container uses **Docker** for container management:

- **Docker CE** - Industry-standard container runtime
- **Docker Compose** - Multi-container orchestration
- **Docker socket sharing** - Containers use the host's Docker daemon

## Available Make Targets

| Target | Description |
|--------|-------------|
| `make dogfood` | Build image as `ghcr.io/angloc/protodev:latest` for dogfood testing |
| `make test` | Run tests in current context (inside container) |
| `make build` | Build image as `protodev-test` (local test tag) |
| `make rebuild` | Force rebuild without cache |
| `make shell` | Open interactive shell in locally-built test image |
| `make pytest` | Run tests by starting a fresh container (CI workflow) |
| `make clean` | Remove local test image |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE.md](LICENSE.md)
