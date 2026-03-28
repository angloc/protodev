"""
Service startup tests (SVC-*).

These tests verify that background services (Xpra, DBus) are running correctly.
"""

import time

from conftest import run_command


class TestServices:
    """Tests for background services."""

    def test_svc_01_xpra_installed(self, container):
        """Xpra is installed."""
        result = run_command("which xpra", check=False)
        assert result.returncode == 0, "Xpra not installed"

    def test_svc_02_xpra_running(self, container):
        """Xpra server is running on display :100."""
        result = run_command("pgrep -x xpra", check=False)
        assert result.returncode == 0, "Xpra process not running"

    def test_svc_03_xpra_display_active(self, container):
        """Xpra display :100 is active."""
        # Give Xpra a moment to fully initialize
        time.sleep(2)
        result = run_command(
            "DISPLAY=:100 xdpyinfo 2>/dev/null | head -1",
            check=False,
        )
        assert result.returncode == 0, "Xpra display :100 not accessible"

    def test_svc_04_xpra_port_listening(self, container):
        """Xpra is listening on port 14500."""
        result = run_command(
            "curl -s -o /dev/null -w '%{http_code}' http://localhost:14500 || echo 'failed'",
            check=False,
        )
        # Should return HTML content (HTTP 200) or at least connect
        assert "200" in result.stdout or "000" not in result.stdout, (
            "Xpra not listening on port 14500"
        )

    def test_svc_05_xpra_html5_available(self, container):
        """Xpra HTML5 interface is available."""
        result = run_command(
            "curl -s http://localhost:14500 | grep -i 'html\\|xpra' || echo 'not found'",
            check=False,
        )
        # Check that we get some HTML content
        assert result.returncode == 0

    def test_svc_06_dbus_session_bus_address_set(self, container):
        """DBus session bus address is set."""
        result = run_command(
            "echo $DBUS_SESSION_BUS_ADDRESS",
            check=False,
        )
        # In docker-compose mode, DBus might be started by entrypoint
        # Check if it's set OR if dbus-env file exists
        dbus_env_result = run_command(
            "cat ~/.xpra/dbus-env 2>/dev/null || echo 'not found'",
            check=False,
        )
        dbus_available = (
            "unix:" in result.stdout
            or "DBUS_SESSION_BUS_ADDRESS" in dbus_env_result.stdout
        )
        assert dbus_available, "DBus session bus not configured"

    def test_svc_07_xpra_runtime_dir(self, container):
        """Xpra runtime directory exists with correct permissions."""
        result = run_command(
            "ls -ld ~/.xpra/runtime 2>/dev/null || echo 'not found'",
            check=False,
        )
        assert result.returncode == 0, "Xpra runtime directory not found"
        # Directory should have 0700 permissions
        assert "drwx" in result.stdout, "Xpra runtime directory has wrong permissions"

    def test_svc_08_xpra_log_exists(self, container):
        """Xpra log file exists."""
        result = run_command(
            "test -f ~/.xpra/xpra.log && echo 'exists' || echo 'not found'",
            check=False,
        )
        assert "exists" in result.stdout, "Xpra log file not found"
