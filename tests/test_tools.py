"""
Tool availability tests (TOOL-*).

These tests verify that all advertised tools are installed and accessible.
"""

from conftest import run_command


class TestLanguages:
    """Tests for language runtimes."""

    def test_tool_01_python_version(self, container):
        """Python 3.12 is available."""
        result = run_command("python3 --version", check=False)
        assert result.returncode == 0
        assert "3.12" in result.stdout, f"Expected Python 3.12, got: {result.stdout}"

    def test_tool_02_node_version(self, container):
        """Node.js 22 is available."""
        result = run_command("node --version", check=False)
        assert result.returncode == 0
        assert "v22" in result.stdout, f"Expected Node.js v22, got: {result.stdout}"

    def test_tool_03_npm_available(self, container):
        """npm is available."""
        result = run_command("npm --version", check=False)
        assert result.returncode == 0, "npm not available"

    def test_tool_04_uv_available(self, container):
        """uv package manager is available."""
        result = run_command("uv --version", check=False)
        assert result.returncode == 0, "uv not available"

    def test_tool_05_uvx_available(self, container):
        """uvx (uv tool runner) is available."""
        result = run_command("uvx --version", check=False)
        assert result.returncode == 0, "uvx not available"


class TestPythonPackages:
    """Tests for pre-installed Python packages."""

    def test_tool_06_ruff_installed(self, container):
        """ruff is installed."""
        result = run_command("ruff --version", check=False)
        assert result.returncode == 0, "ruff not installed"

    def test_tool_07_pytest_installed(self, container):
        """pytest is installed."""
        result = run_command("pytest --version", check=False)
        assert result.returncode == 0, "pytest not installed"

    def test_tool_08_jupyter_installed(self, container):
        """jupyter is installed."""
        result = run_command("jupyter --version", check=False)
        assert result.returncode == 0, "jupyter not installed"

    def test_tool_09_playwright_installed(self, container):
        """playwright Python package is installed."""
        result = run_command(
            "python3 -c 'import playwright'",
            check=False,
        )
        assert result.returncode == 0, "playwright not installed"

    def test_tool_10_httpie_installed(self, container):
        """httpie is installed."""
        result = run_command("http --version", check=False)
        assert result.returncode == 0, "httpie not installed"


class TestCLITools:
    """Tests for CLI tools."""

    def test_tool_11_git_available(self, container):
        """Git is available."""
        result = run_command("git --version", check=False)
        assert result.returncode == 0, "git not available"

    def test_tool_12_gh_available(self, container):
        """GitHub CLI is available."""
        result = run_command("gh --version", check=False)
        assert result.returncode == 0, "GitHub CLI not available"

    def test_tool_13_ripgrep_available(self, container):
        """ripgrep (rg) is available."""
        result = run_command("rg --version", check=False)
        assert result.returncode == 0, "ripgrep not available"

    def test_tool_14_fzf_available(self, container):
        """fzf is available."""
        result = run_command("fzf --version", check=False)
        assert result.returncode == 0, "fzf not available"

    def test_tool_15_jq_available(self, container):
        """jq is available."""
        result = run_command("jq --version", check=False)
        assert result.returncode == 0, "jq not available"

    def test_tool_16_yq_available(self, container):
        """yq is available."""
        result = run_command("yq --version", check=False)
        assert result.returncode == 0, "yq not available"

    def test_tool_17_duckdb_available(self, container):
        """DuckDB is available."""
        result = run_command("duckdb --version", check=False)
        assert result.returncode == 0, "DuckDB not available"

    def test_tool_18_sqlite_available(self, container):
        """SQLite is available."""
        result = run_command("sqlite3 --version", check=False)
        assert result.returncode == 0, "SQLite not available"

    def test_tool_19_act_available(self, container):
        """act (GitHub Actions local runner) is available."""
        result = run_command("act --version", check=False)
        assert result.returncode == 0, "act not available"

    def test_tool_20_xmlstarlet_available(self, container):
        """xmlstarlet is available."""
        result = run_command("xmlstarlet --version", check=False)
        assert result.returncode == 0, "xmlstarlet not available"


class TestGUIApps:
    """Tests for GUI application support."""

    def test_tool_21_chrome_installed(self, container):
        """Google Chrome is installed."""
        result = run_command("google-chrome --version", check=False)
        assert result.returncode == 0, "Google Chrome not installed"

    def test_tool_22_chrome_headless_works(self, container):
        """Chrome can run in headless mode."""
        result = run_command(
            "google-chrome --headless --no-sandbox --disable-gpu --dump-dom https://example.com 2>/dev/null | head -5",
            check=False,
            timeout=30,
        )
        assert result.returncode == 0, "Chrome headless mode failed"
        # Should contain HTML content
        assert (
            "<html" in result.stdout.lower() or "<!doctype" in result.stdout.lower()
        ), f"Chrome didn't return HTML content: {result.stdout[:200]}"

    def test_tool_23_ffmpeg_available(self, container):
        """ffmpeg is available."""
        result = run_command("ffmpeg -version", check=False)
        assert result.returncode == 0, "ffmpeg not available"

    def test_tool_24_graphicsmagick_available(self, container):
        """GraphicsMagick is available."""
        result = run_command("gm version", check=False)
        assert result.returncode == 0, "GraphicsMagick not available"
