#!/bin/bash
#
# postCreateCommand.sh - Minimal setup for protodev maintainer environment
#
# This container is for maintaining the protodev repository itself.
# It only needs basic tools for editing files and interacting with GitHub.

set -e

echo "🚀 Setting up protodev maintainer environment..."

# ============================================
# Git Configuration
# ============================================
git config --global --add safe.directory '*'
git config --global core.autocrlf input

echo "✅ Git configured"

# ============================================
# Environment Info
# ============================================
echo ""
echo "✅ Protodev maintainer environment ready!"
echo ""
echo "Available tools:"
echo "  • GitHub CLI (gh)   • Git"
echo "  • Docker CLI (for local testing)"
echo ""
echo "To build the container image locally:"
echo "  docker build -t protodev-test ."
echo ""
echo "To test the workflow locally (requires act):"
echo "  act -j build-and-push --dry-run"
echo ""
