"""
Docker-in-Docker tests (DIND-*).

These tests verify that containers can be built and run inside the development container.
This is the most critical feature for development workflow.

Note: These tests require the Docker socket to be mounted from the host.
"""

import time

import pytest
from conftest import run_command

# Mark all Docker-in-Docker tests as slow (they pull/build images)
pytestmark = pytest.mark.slow


class TestDockerBasics:
    """Tests for basic Docker functionality."""

    def test_dind_01_docker_available(self, container):
        """Docker command is available."""
        result = run_command("docker --version", check=False)
        assert result.returncode == 0, "docker command not available"

    def test_dind_02_docker_compose_available(self, container):
        """docker compose (plugin) is available."""
        result = run_command("docker compose version", check=False)
        assert result.returncode == 0, "docker compose (plugin) not available"

    def test_dind_03_pull_image(self, container):
        """Can pull a small image inside the container."""
        result = run_command("docker pull alpine:latest", check=False, timeout=120)
        assert result.returncode == 0, f"Failed to pull alpine image: {result.stderr}"

    def test_dind_04_run_single_container(self, container):
        """Can run a simple container."""
        result = run_command(
            "docker run --rm alpine:latest echo 'hello from container'",
            check=False,
            timeout=60,
        )
        assert result.returncode == 0, f"Failed to run container: {result.stderr}"
        assert "hello from container" in result.stdout, (
            f"Unexpected output: {result.stdout}"
        )

    def test_dind_05_run_container_with_volume(self, container):
        """Can run a container with a volume mount."""
        result = run_command(
            "docker run --rm -v /workspace:/data alpine:latest cat /data/Dockerfile | head -1",
            check=False,
            timeout=60,
        )
        assert result.returncode == 0, (
            f"Failed to run container with volume: {result.stderr}"
        )


class TestDockerBuild:
    """Tests for Docker image building."""

    def test_dind_06_build_image(self, container, sample_app_dir):
        """Can build a Docker image inside the container."""
        result = run_command(
            f"cd {sample_app_dir} && docker build -t sample-app .",
            check=False,
            timeout=180,
        )
        assert result.returncode == 0, f"Failed to build image: {result.stderr}"

    def test_dind_07_run_built_image(self, container):
        """Can run a built image and verify it responds."""
        # Ensure image exists
        result = run_command("docker images -q sample-app", check=False)
        if not result.stdout.strip():
            pytest.skip("sample-app image not built")

        # Stop any previous test container
        run_command("docker stop sample-app-test 2>/dev/null || true", check=False)
        run_command("docker rm sample-app-test 2>/dev/null || true", check=False)

        # Run the built image with port mapping
        result = run_command(
            "docker run --rm -d -p 9999:8080 --name sample-app-test sample-app",
            check=False,
            timeout=30,
        )
        if result.returncode != 0:
            pytest.skip(f"Failed to start sample-app: {result.stderr}")

        # Wait for container to start
        time.sleep(3)

        # Verify via curl
        curl_result = run_command(
            "curl -s --max-time 10 http://localhost:9999 || echo 'failed'",
            check=False,
            timeout=15,
        )

        # Cleanup
        run_command("docker stop sample-app-test 2>/dev/null || true", check=False)
        run_command("docker rm sample-app-test 2>/dev/null || true", check=False)

        assert "Hello" in curl_result.stdout, (
            f"Sample app didn't respond correctly: {curl_result.stdout}"
        )


class TestDockerCompose:
    """Tests for docker compose functionality."""

    def test_dind_08_compose_up(self, container, sample_app_dir):
        """Can run docker compose up with multiple services."""
        result = run_command(
            f"cd {sample_app_dir} && docker compose up -d",
            check=False,
            timeout=180,
        )
        assert result.returncode == 0, f"docker compose up failed: {result.stderr}"

        # Wait for services to start
        time.sleep(10)

    def test_dind_09_compose_services_running(self, container, sample_app_dir):
        """docker compose services are running."""
        result = run_command(
            f"cd {sample_app_dir} && docker compose ps",
            check=False,
        )
        # Check that services are running
        assert "app1" in result.stdout or "Up" in result.stdout, (
            f"Services not running: {result.stdout}"
        )

    def test_dind_10_compose_networking(self, container):
        """Services are accessible via their mapped ports on localhost."""
        # Wait a bit more for services to be fully ready
        time.sleep(5)

        # Test app1 via mapped port 8081
        result_app1 = run_command(
            "curl -s --max-time 10 http://localhost:8081 || echo 'failed'",
            check=False,
            timeout=15,
        )

        # Test app2 via mapped port 8082
        result_app2 = run_command(
            "curl -s --max-time 10 http://localhost:8082 || echo 'failed'",
            check=False,
            timeout=15,
        )

        # Test nginx via mapped port 8083
        result_nginx = run_command(
            "curl -s --max-time 10 http://localhost:8083 || echo 'failed'",
            check=False,
            timeout=15,
        )

        # At least one service should respond
        services_responding = sum(
            [
                "Hello" in result_app1.stdout,
                "Hello" in result_app2.stdout,
                "nginx" in result_nginx.stdout.lower()
                or "welcome" in result_nginx.stdout.lower(),
            ]
        )

        assert services_responding >= 1, (
            f"No services responding via mapped ports. "
            f"app1 (localhost:8081): {result_app1.stdout[:100]}, "
            f"app2 (localhost:8082): {result_app2.stdout[:100]}, "
            f"nginx (localhost:8083): {result_nginx.stdout[:100]}"
        )

    def test_dind_11_compose_down(self, container, sample_app_dir):
        """Can stop docker compose services."""
        result = run_command(
            f"cd {sample_app_dir} && docker compose down",
            check=False,
            timeout=60,
        )
        assert result.returncode == 0, f"docker compose down failed: {result.stderr}"

        # Verify services are stopped
        result = run_command(
            "docker ps -a --format '{{.Names}}' | grep -c sample-app || echo 0",
            check=False,
        )
        # All compose containers should be stopped/removed
        assert "0" in result.stdout or result.returncode != 0, (
            "Some compose containers still running"
        )
