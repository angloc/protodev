"""
Container startup tests (START-*).

These tests verify that the container starts correctly and is properly configured.
The container uses a single postStartCommand.sh script for all runtime setup.
"""

from conftest import run_command


class TestContainerStartup:
    """Tests for container startup and basic configuration."""

    def test_start_01_container_running(self, container):
        """Container is running and accessible."""
        result = run_command("echo 'container is running'", check=False)
        assert result.returncode == 0, "Container is not running or not accessible"

    def test_start_02_vscode_user_exists(self, container):
        """VS Code user exists with correct configuration."""
        result = run_command("id vscode", check=False)
        assert result.returncode == 0, "vscode user does not exist"
        assert "vscode" in result.stdout

    def test_start_03_vscode_user_home(self, container):
        """VS Code user has a home directory."""
        result = run_command("echo $HOME", check=False)
        assert result.returncode == 0
        assert "/home/vscode" in result.stdout

    def test_start_04_workspace_exists(self, container):
        """Workspace directory exists and is accessible."""
        result = run_command("ls -la /workspace", check=False)
        assert result.returncode == 0, "/workspace directory does not exist"

    def test_start_05_workspace_writable(self, container):
        """Workspace directory is writable by vscode user."""
        result = run_command(
            "touch /workspace/test_write && rm /workspace/test_write",
            check=False,
        )
        assert result.returncode == 0, "Cannot write to /workspace"

    def test_start_06_sudo_configured(self, container):
        """Sudo is configured for passwordless access."""
        result = run_command("sudo -n whoami", check=False)
        assert result.returncode == 0, "Sudo not configured for passwordless access"
        assert "root" in result.stdout

    def test_start_07_git_configured(self, container):
        """Git is configured with safe.directory (baked into image)."""
        result = run_command(
            "git config --global --get safe.directory",
            check=False,
        )
        assert result.returncode == 0, "Git safe.directory not configured"
        assert "*" in result.stdout

    def test_start_08_bash_aliases_exist(self, container):
        """Bash aliases are configured (baked into image)."""
        result = run_command(
            "grep -q 'chrome-xpra' ~/.bashrc && echo 'found'",
            check=False,
        )
        assert result.returncode == 0, "Bash aliases not configured"

    def test_start_09_environment_variables(self, container):
        """Required environment variables are set."""
        result = run_command("echo $PYTHONUNBUFFERED", check=False)
        assert "1" in result.stdout, "PYTHONUNBUFFERED not set"

        result = run_command("echo $DISPLAY", check=False)
        assert ":100" in result.stdout, "DISPLAY not set correctly"
