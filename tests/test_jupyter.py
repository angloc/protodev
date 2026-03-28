"""
JupyterLab tests (JUP-*).

These tests verify JupyterLab functionality in the development container.
JupyterLab is a key development tool for interactive computing.
"""

import time

import pytest
from conftest import run_command, wait_for

# Mark all tests in this file as slow (they start/stop JupyterLab server)
pytestmark = pytest.mark.slow


@pytest.fixture(scope="module", autouse=True)
def cleanup_jupyter_after_tests():
    """Ensure JupyterLab is stopped after all tests in this module complete."""
    yield
    # Cleanup: use the labstop alias to gracefully stop JupyterLab
    run_command("bash -i -c 'labstop' 2>/dev/null || true", check=False)
    time.sleep(1)
    # Fallback: ensure any remaining jupyter processes are stopped
    run_command("pkill -f jupyter 2>/dev/null || true", check=False)


class TestJupyterLab:
    """Tests for JupyterLab functionality."""

    def test_jup_01_jupyter_installed(self, container):
        """Jupyter is installed."""
        result = run_command("jupyter --version", check=False)
        assert result.returncode == 0, "jupyter not installed"

    def test_jup_02_jupyterlab_installed(self, container):
        """JupyterLab is installed."""
        result = run_command("jupyter lab --version", check=False)
        assert result.returncode == 0, "jupyterlab not installed"

    def test_jup_03_lab_alias_starts_server(self, container):
        """The 'lab' bash alias starts a JupyterLab server."""
        # Kill any existing Jupyter processes and clean up
        run_command("pkill -f jupyter 2>/dev/null || true", check=False)
        run_command("rm -f /tmp/jupyter.pid /tmp/jupyter.log", check=False)
        time.sleep(1)

        # Start JupyterLab using the lab alias via interactive bash
        run_command("cd /workspace && bash -i -c 'lab'", check=False)

        # Wait for Jupyter to respond with HTTP 200 (no-auth server ready)
        def jupyter_ready():
            result = run_command(
                "curl -s -o /dev/null -w '%{http_code}' http://localhost:8888/api/status 2>/dev/null || echo '000'",
                check=False,
                timeout=10,
            )
            return "200" in result.stdout

        try:
            wait_for(jupyter_ready, timeout=40, message="JupyterLab did not start")
        except TimeoutError:
            log_result = run_command(
                "cat /tmp/jupyter.log 2>/dev/null | tail -20 || echo 'no log'",
                check=False,
            )
            pytest.fail(
                f"JupyterLab did not start within 40 seconds. Log: {log_result.stdout}"
            )

    def test_jup_04_lab_no_authentication(self, container):
        """JupyterLab is accessible without authentication."""
        result = run_command(
            "curl -s -o /dev/null -w '%{http_code}' http://localhost:8888/api/status 2>/dev/null || echo '000'",
            check=False,
            timeout=10,
        )
        assert "200" in result.stdout, (
            f"JupyterLab requires authentication or is not running (status: {result.stdout.strip()})"
        )

    def test_jup_05_lab_accessible_via_playwright(self, container):
        """JupyterLab UI is accessible via Playwright in headless Chrome."""
        # Skip if JupyterLab is not running
        result = run_command(
            "curl -s -o /dev/null -w '%{http_code}' http://localhost:8888/api/status 2>/dev/null || echo '000'",
            check=False,
            timeout=10,
        )
        if "200" not in result.stdout:
            pytest.skip(f"JupyterLab not running (status: {result.stdout.strip()})")

        playwright_script = """
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(
            headless=True,
            executable_path="/usr/bin/google-chrome-stable",
            args=["--no-sandbox", "--disable-dev-shm-usage"]
        )
        page = await browser.new_page()

        # Navigate directly to /lab (the JupyterLab workspace UI)
        response = await page.goto("http://localhost:8888/lab", timeout=30000)
        print(f"HTTP_STATUS: {response.status}")

        # A redirect to /login means authentication is required - that is a failure
        assert "/login" not in page.url, f"Redirected to login page: {page.url}"
        assert response.status == 200, f"Expected HTTP 200, got {response.status}"

        # Wait for JupyterLab application shell to render
        await page.wait_for_load_state("networkidle", timeout=30000)

        title = await page.title()
        print(f"PAGE_TITLE: {title}")
        content = await page.content()

        # JupyterLab UI is present when the page contains JupyterLab markers
        has_jupyter = (
            "jupyter" in title.lower() or
            "JupyterLab" in content or
            "jp-" in content or
            "notebook" in content.lower()
        )

        assert has_jupyter, (
            f"JupyterLab UI not detected after successful authentication-free load. "
            f"Title: {title}, Content snippet: {content[:500]}"
        )

        await browser.close()
        print("PLAYWRIGHT_JUPYTER_OK")

asyncio.run(main())
"""
        playwright_result = run_command(
            f"python3 -c '{playwright_script}'",
            check=False,
            timeout=60,
        )

        assert (
            playwright_result.returncode == 0
            and "PLAYWRIGHT_JUPYTER_OK" in playwright_result.stdout
        ), (
            f"Playwright verification of JupyterLab failed. "
            f"Return code: {playwright_result.returncode}, "
            f"Output: {playwright_result.stdout[:500]}, "
            f"Stderr: {playwright_result.stderr[:500]}"
        )

    def test_jup_06_labstop_alias_stops_server(self, container):
        """The 'labstop' bash alias stops the JupyterLab server."""
        # Verify JupyterLab is running before stopping
        result_before = run_command(
            "curl -s -o /dev/null -w '%{http_code}' http://localhost:8888/api/status 2>/dev/null || echo '000'",
            check=False,
            timeout=10,
        )
        if "200" not in result_before.stdout:
            pytest.skip("JupyterLab not running before labstop test")

        # Verify PID file exists (created by 'lab' alias)
        pid_exists = run_command(
            "test -f /tmp/jupyter.pid && echo 'exists' || echo 'missing'",
            check=False,
        )
        assert "exists" in pid_exists.stdout, (
            "Jupyter PID file /tmp/jupyter.pid not found - server may not have been started with 'lab' alias"
        )

        # Stop JupyterLab using the labstop alias via interactive bash
        result = run_command("bash -i -c 'labstop'", check=False, timeout=30)
        assert result.returncode == 0, f"labstop alias failed: {result.stderr}"
        assert "stopped" in result.stdout.lower(), (
            f"labstop did not confirm stop: {result.stdout}"
        )

        time.sleep(2)

        # Verify port 8888 is no longer responding
        result_after = run_command(
            "curl -s -o /dev/null -w '%{http_code}' http://localhost:8888/api/status 2>/dev/null || echo '000'",
            check=False,
            timeout=10,
        )
        assert "000" in result_after.stdout or "200" not in result_after.stdout, (
            f"JupyterLab still responding on port 8888 after labstop (HTTP {result_after.stdout.strip()})"
        )

        # Verify PID file was removed
        pid_removed = run_command(
            "test -f /tmp/jupyter.pid && echo 'exists' || echo 'removed'",
            check=False,
        )
        assert "removed" in pid_removed.stdout, (
            "Jupyter PID file still exists after labstop"
        )
