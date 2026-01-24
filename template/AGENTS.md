# AGENTS.md - AI Agent Development Environment Guide

This document explains how the development environment works for AI coding agents (Cline, Claude Code, Codex, etc.).

## Critical: Shell Environment

**All shell commands run inside a Linux (Debian) development container, not on the host machine.**

When you open a terminal or execute commands:
- You are in a **Linux bash shell** inside the container
- The working directory is `/workspace` (your project root)
- You have `sudo` access (user: `vscode`)
- The host filesystem is **not directly accessible** except through mounted volumes

This applies whether using VS Code Dev Containers or Docker Compose (`make shell`).

## Use Pre-installed Tools First

The container includes a comprehensive toolset. **Always prefer these tools over writing custom scripts.**

### Languages & Package Managers
| Tool | Usage |
|------|-------|
| `python` / `python3` | Python 3.12 |
| `uv` | Fast Python package manager - use `uv pip install` |
| `node` / `npm` | Node.js 22 LTS |
| `pnpm` | Alternative Node.js package manager |
| `bun` | Fast JavaScript runtime and package manager |

### Search & Text Processing
| Tool | Usage |
|------|-------|
| `rg` (ripgrep) | **Fast recursive search** - prefer over `grep -r` |
| `fzf` | Fuzzy finder for interactive selection |
| `jq` | JSON processor - parse and transform JSON |
| `yq` | YAML processor - parse and transform YAML |
| `xmlstarlet` | XML processor |

### Database CLIs
| Tool | Usage |
|------|-------|
| `duckdb` | Analytical SQL database - great for CSV/Parquet analysis |
| `sqlite3` | SQLite database CLI |

### Media Processing
| Tool | Usage |
|------|-------|
| `ffmpeg` | Video/audio processing and conversion |
| `gm` (GraphicsMagick) | Image processing and conversion |

### Development & CI
| Tool | Usage |
|------|-------|
| `docker` | Docker-in-Docker - build and run containers |
| `gh` | GitHub CLI - repo management, PRs, issues |
| `act` | Run GitHub Actions locally for testing |
| `make` | Build automation |

### Python Packages (Pre-installed)
```
numpy, scipy, pandas, matplotlib
jupyter, jupyterlab, jupyter-ai
pytest, pytest-cov, pytest-playwright
playwright, ruff, requests, PyYAML, Jinja2, openai
```

## Browser Automation with Chrome

**Google Chrome is installed and configured for headless automation.**

### Playwright (Recommended)
Playwright is pre-installed and configured to use the system Chrome:

```python
# pytest-playwright example
def test_page_title(page):
    page.goto("https://example.com")
    assert page.title() == "Example Domain"
```

```bash
# Run Playwright tests
pytest tests/ -v

# Run specific test file
pytest tests/test_browser.py -v
```

### Headless Chrome Direct
```bash
# Headless mode (no GUI needed)
google-chrome --headless --no-sandbox --disable-gpu --dump-dom https://example.com

# Screenshot
google-chrome --headless --no-sandbox --screenshot=/tmp/screenshot.png https://example.com

# PDF export
google-chrome --headless --no-sandbox --print-to-pdf=/tmp/page.pdf https://example.com
```

### GUI Mode (via VNC)
If you need to see the browser:
1. Access noVNC at http://localhost:6080/vnc.html (password: `vscode`)
2. Run: `google-chrome --no-sandbox --disable-gpu`

## Testing with pytest

pytest is the standard test runner with these plugins pre-installed:

```bash
# Run all tests
pytest

# Verbose output
pytest -v

# Run specific test file
pytest tests/test_api.py

# Run tests matching pattern
pytest -k "test_login"

# With coverage
pytest --cov=src --cov-report=html

# Playwright browser tests
pytest --browser chromium
```

## MCP Server Support

This environment supports Model Context Protocol (MCP) servers for extending AI agent capabilities.

### What MCP Provides
- **Tools**: Custom functions that agents can call
- **Resources**: Data sources agents can access
- **Prompts**: Pre-defined prompt templates

### Configuration
- MCP server configs are in `.mcp-servers/`
- Cline configuration: `.mcp-servers/cline-config.json`
- Example server: `.mcp-servers/example-server/`

### Creating MCP Servers
See `.mcp-servers/README.md` for:
- Server creation templates
- Registration with AI assistants
- Debugging tips

MCP servers are automatically built during container startup via `postCreateCommand.sh`.

## Common Patterns

### File Search
```bash
# Find files by name
rg --files | rg "pattern"

# Search file contents (fast!)
rg "search term" --type py

# Search and replace preview
rg "old_pattern" --replace "new_pattern"
```

### Data Analysis
```bash
# Analyze CSV with DuckDB
duckdb -c "SELECT * FROM 'data.csv' LIMIT 10"

# Query Parquet files
duckdb -c "SELECT count(*) FROM 'data.parquet'"

# JSON processing
cat data.json | jq '.items[] | select(.status == "active")'
```

### Quick Testing
```bash
# Python one-liner
python -c "import json; print(json.dumps({'test': True}))"

# Node.js one-liner  
node -e "console.log(JSON.stringify({test: true}))"

# HTTP request
curl -s https://api.example.com/data | jq .
```

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `DISPLAY` | `:1` | VNC display for GUI apps |
| `PYTHONUNBUFFERED` | `1` | Immediate Python output |
| `PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH` | `/usr/bin/google-chrome-stable` | Chrome for Playwright |

## Tips for Agents

1. **Check tool availability first**: Run `which <tool>` before assuming a tool isn't available
2. **Use ripgrep over grep**: `rg` is faster and has better defaults
3. **Prefer uv for Python**: `uv pip install` is significantly faster than pip
4. **Test incrementally**: Use pytest with `-x` flag to stop on first failure
5. **Use headless Chrome**: Most browser tasks don't need GUI - use `--headless`
6. **Leverage DuckDB**: For any CSV/data analysis, DuckDB is faster than pandas for exploration
