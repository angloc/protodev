"""
Test configuration and fixtures for protodev container tests.

These tests verify the development container works correctly, including:
- Container startup and configuration
- Service availability (Xpra, DBus)
- Tool availability (Python, Node.js, Docker, etc.)
- Docker-in-Docker functionality (critical feature)

Tests MUST run inside the protodev container. Run tests via:
    make test     # Inside the container (devcontainer mode)
"""

import os
import subprocess
import time

import pytest

# Container configuration
CONTAINER_NAME = os.environ.get("PROTODEV_CONTAINER", "protodev")
TEST_TIMEOUT = int(os.environ.get("TEST_TIMEOUT", "60"))

# Verify we're running inside the container
IN_CONTAINER = os.path.exists("/workspace") and os.path.exists("/home/vscode")
if not IN_CONTAINER:
    pytest.exit(
        "Tests must run inside the protodev container.\n"
        "Run 'make test' from inside the container, or use 'make pytest' for CI mode.",
        returncode=1,
    )


def wait_for(condition, timeout=30, interval=1, message="Condition not met"):
    """
    Poll until a condition is true or timeout expires.

    Args:
        condition: Callable that returns True when condition is met
        timeout: Maximum seconds to wait
        interval: Seconds between polls
        message: Error message on timeout

    Returns:
        True if condition met, raises TimeoutError otherwise
    """
    start = time.time()
    while time.time() - start < timeout:
        if condition():
            return True
        time.sleep(interval)
    raise TimeoutError(f"{message} after {timeout}s")


def run_command(cmd, timeout=TEST_TIMEOUT, check=True, capture_output=True):
    """Run a shell command and return the result."""
    result = subprocess.run(
        cmd, shell=True, timeout=timeout, capture_output=capture_output, text=True
    )
    if check and result.returncode != 0:
        raise subprocess.CalledProcessError(
            result.returncode, cmd, result.stdout, result.stderr
        )
    return result


@pytest.fixture(scope="session")
def container():
    """
    Provide container name for test consistency.

    Since tests run inside the container, this just returns the container name
    for use in test signatures. All commands run directly via run_command().
    """
    yield CONTAINER_NAME


@pytest.fixture(scope="session")
def sample_app_dir(tmp_path_factory):
    """
    Create a sample application fixture for Docker-in-Docker tests.
    Returns the path to a directory containing:
    - A simple Dockerfile
    - A docker-compose.yml with multiple services
    """
    app_dir = tmp_path_factory.mktemp("sample-app")

    # Create a simple Python web app
    (app_dir / "app.py").write_text("""
from http.server import HTTPServer, BaseHTTPRequestHandler
import os

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        message = os.environ.get('APP_MESSAGE', 'Hello from sample app')
        self.wfile.write(message.encode())

    def log_message(self, format, *args):
        pass  # Suppress logging

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    HTTPServer(('0.0.0.0', port), Handler).serve_forever()
""")

    # Create Dockerfile
    (app_dir / "Dockerfile").write_text("""
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
ENV PORT=8080
EXPOSE 8080
CMD ["python", "app.py"]
""")

    # Create docker-compose.yml with multiple services
    (app_dir / "docker-compose.yml").write_text("""
services:
  app1:
    build: .
    ports:
      - "8081:8080"
    environment:
      - APP_MESSAGE=Hello from app1

  app2:
    build: .
    ports:
      - "8082:8080"
    environment:
      - APP_MESSAGE=Hello from app2

  nginx:
    image: nginx:alpine
    ports:
      - "8083:80"
""")

    return app_dir
