# Contributing to Protodev

This document covers how to contribute to the protodev Docker development environment project.

## Repository Architecture

This is a **build and publish repository** that maintains:
1. **Dockerfile** (root) - The build recipe for the `ghcr.io/angloc/protodev` container image
2. **template/** - The distributable devcontainer configuration for users

```
protodev/
├── Dockerfile                    # Build recipe (source of truth for the image)
├── .devcontainer/                # Minimal environment for maintaining THIS repo
│   ├── devcontainer.json         # Uses base image + GitHub CLI
│   └── postCreateCommand.sh      # Minimal setup
├── template/                     # Distributed to users as devcontainer.zip
│   ├── .devcontainer/            # References the published image
│   ├── Makefile                  # User convenience commands
│   └── .protodev.clinerules.md   # Cline rules for users
├── .github/workflows/
│   └── docker-publish.yml        # Builds image, creates devcontainer.zip
├── README.md                     # Maintainer documentation
└── CONTRIBUTING.md               # This file
```

## Development Setup

### Prerequisites

| Tool | Purpose |
|------|---------|
| **Docker** | Building and testing container images |
| **GitHub CLI (`gh`)** | Release management and repository operations |
| **Git** | Version control |

### Using the Dev Container (Recommended)

1. Open the repository in VS Code
2. When prompted, reopen in container
3. Docker and GitHub CLI will be automatically available

### Working Without the Dev Container

Ensure Docker, GitHub CLI, and Git are installed on your host machine.

## Building the Container Image

### Local Build

```bash
# Build the image locally for testing
docker build -t protodev-test .

# Test the image interactively
docker run -it protodev-test bash
```

### Testing the Template

```bash
# Test the template configuration
cd template
docker compose -f .devcontainer/docker-compose.yml up -d
docker compose -f .devcontainer/docker-compose.yml exec dev bash
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

## CI/CD Pipeline

### GitHub Actions Workflow

The `.github/workflows/docker-publish.yml` workflow:

1. **On push to main**: Builds and pushes image tagged `latest`
2. **On version tags (v*)**: Builds and pushes semantic version tags
3. **Creates devcontainer.zip**: Packages template files for distribution
4. **Attaches to Release**: Adds zip to GitHub Releases (for version tags)

### Creating a Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers:
- Build and push of `ghcr.io/angloc/protodev:1.0.0`
- Creation of GitHub Release with `devcontainer.zip` attached

## Versioning

The image uses semantic versioning:

| Tag | Description |
|-----|-------------|
| `latest` | Most recent main branch build |
| `1.0.0` | Semantic version release |
| `1.0` | Major.minor version |
| `1` | Major version |
| `sha-abc1234` | Specific commit |

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Update documentation if needed
5. Submit a pull request

### PR Checklist

- [ ] Dockerfile changes tested locally (`docker build -t protodev-test .`)
- [ ] Template changes tested with sample project
- [ ] README.md updated if architecture/workflow changes
- [ ] No hardcoded paths or secrets

## Code Style

- **Dockerfile**: Follow Docker best practices (layer caching, minimal base images)
- **Shell scripts**: Use `shellcheck` for linting
- **YAML/JSON**: Use consistent 2-space indentation

## License

MIT License - see [LICENSE.md](LICENSE.md)
