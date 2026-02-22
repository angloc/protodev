# Protodev - Docker Development Environment

This repository builds and publishes a standardized Docker development environment container. The container image provides Python, Node.js, and comprehensive development tools that can be used across many projects.

## Repository Purpose

This is a **build and publish repository**, not a consumer of its own product. It maintains:

1. **Dockerfile** - The build recipe for the `ghcr.io/angloc/protodev` container image
2. **template/** - The distributable devcontainer configuration that users download

## Architecture

```
/workspace
├── Dockerfile                    # Build recipe (source of truth for the image)
├── .devcontainer/                # Minimal environment for maintaining THIS repo
│   ├── devcontainer.json         # Uses base image + GitHub CLI
│   └── postCreateCommand.sh      # Minimal setup
├── template/                     # What users download as devcontainer.zip
│   ├── .devcontainer/            # References the published image
│   │   ├── devcontainer.json     # Uses ghcr.io/angloc/protodev:latest
│   │   ├── docker-compose.yml    # Alternative Docker Compose setup
│   │   ├── postCreateCommand.sh  # User environment setup
│   │   └── postStartCommand.sh   # Background services startup
│   ├── Makefile                  # Convenience commands
│   └── .protodev/                # User documentation
│       └── README.md
├── .github/workflows/
│   └── docker-publish.yml        # Builds image, creates devcontainer.zip
└── README.md                     # This file (maintainer documentation)
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
3. Creates `devcontainer.zip` from the `template/` folder
4. Attaches the zip to GitHub Releases (for version tags)

### Local Build

To build the image locally for testing:

```bash
docker build -t protodev-test .
```

To test the template:

```bash
cd template
docker compose -f .devcontainer/docker-compose.yml up -d
docker compose -f .devcontainer/docker-compose.yml exec dev bash
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
2. Test locally: `docker build -t protodev-test .`
3. Commit and push to main (or create PR)
4. GitHub Actions will build and push the new image

### Updating the Template

1. Edit files in `template/.devcontainer/`
2. Ensure `devcontainer.json` references the correct image version
3. Test with a sample project
4. Commit and push

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

## Development Environment for This Repo

This repository has a minimal `.devcontainer` for maintainers. It provides:
- GitHub CLI (`gh`) for release management
- Git for version control
- Docker CLI for local testing

To use it:
1. Open in VS Code
2. When prompted, reopen in container

No special tools are needed - the build happens in GitHub Actions.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE.md](LICENSE.md)
