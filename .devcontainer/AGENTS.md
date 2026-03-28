# Agent Instructions for Protodev Development Environment

This project uses the protodev Docker development environment.

**Read .devcontainer/README.md to understand the development environment and follow its directions.**

The .devcontainer/README.md contains essential information about:
- Quick start guide for using the dev container
- Available tools and languages (Python, Node.js, Docker)
- Workflow options (VS Code Dev Containers, Docker Compose, Makefile)
- Port forwarding and Docker-in-Docker configuration
- Customisation options for your project
- Troubleshooting common issues

## Testing Architecture

This development environment distinguishes between two testing contexts:

### Unit Tests (Application Context)
- Run **inside the application's virtual environment**
- Test internal implementation details
- Use application-specific test frameworks and fixtures
- Located in `tests/unit/` or similar

### Functional Tests (Development Context)
- Run **in the development environment**, outside the application context
- Test the application as a "black box" without knowledge of implementation
- Use Playwright for browser automation and API testing
- Use HTTPie for API exploration
- Located in `tests/functional/` or similar

**Key principle:** Functional tests should work against any deployment of the application (local container, staging, production) by configuring the target URL via `APP_BASE_URL` environment variable.

### Functional Test Tools

| Tool | Purpose |
|------|---------|
| Playwright | Browser automation and API testing (pre-installed) |
| HTTPie | Command-line HTTP client for API exploration (pre-installed) |
| pytest | Test runner (pre-installed) |

When writing or modifying functional tests:
1. Use `os.environ.get("APP_BASE_URL", "http://localhost:8080")` for configurable targets
2. Playwright is configured to use system Chrome (no browser download needed)
3. Tests should treat the application as opaque - test behavior, not implementation

## Incorporating These Instructions

To ensure AI assistants working on this project can optimally utilize the development facilities, add the following to your project's root `AGENTS.md` file:

```markdown
# Protodev Development Environment

This project uses the protodev Docker development environment.

**Read .devcontainer/README.md for complete development environment documentation.**
```

If you don't have an `AGENTS.md` file, copy this file to your project root as `AGENTS.md`.
