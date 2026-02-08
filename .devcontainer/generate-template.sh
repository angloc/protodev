#!/bin/bash
set -e

# Generate template/.devcontainer/ from root .devcontainer/
# This script transforms the build configuration into the distributable template

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/template"

mkdir -p "$TEMPLATE_DIR/.devcontainer"

echo "Generating template from root .devcontainer/..."

# Copy shell scripts (identical between build and template)
cp "$ROOT_DIR/.devcontainer/postCreateCommand.sh" "$TEMPLATE_DIR/.devcontainer/"
cp "$ROOT_DIR/.devcontainer/postStartCommand.sh" "$TEMPLATE_DIR/.devcontainer/"

# Transform devcontainer.json: replace "build" with "image"
jq '
  del(.build) |
  del(.containerEnv.DISPLAY) |
  .image = "ghcr.io/angloc/protodev:latest"
' "$ROOT_DIR/.devcontainer/devcontainer.json" > "$TEMPLATE_DIR/.devcontainer/devcontainer.json"

# Transform docker-compose.yml: replace build with image
# Extract services and add image field, removing build fields
yq '
  .services.dev.image = "ghcr.io/angloc/protodev:latest" |
  del(.services.dev.build) |
  del(.services.dev.volumes[] | select(. == "../.mcp-servers:/workspace/.mcp-servers:cached"))
' "$ROOT_DIR/.devcontainer/docker-compose.yml" > "$TEMPLATE_DIR/.devcontainer/docker-compose.yml"

echo "Template generated in $TEMPLATE_DIR/"
