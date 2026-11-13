"""Check installed MCP executables without credentials or external API calls."""
import json
import os
import selectors
import subprocess
import sys
import tempfile
import time

with tempfile.TemporaryDirectory() as work:
    env = os.environ | {
        "HOME": work,
        "XDG_CACHE_HOME": work + "/cache",
        "XDG_DATA_HOME": work + "/data",
        "MCP_TRANSPORT_TYPE": "stdio",
        "MCP_LOG_LEVEL": "error",
        "ELSEVIER_API_KEY": "package-install-check",
        "OURA_ACCESS_TOKEN": "package-install-check",
        "UNPAYWALL_EMAIL": "package-check@example.org",
    }
    with tempfile.TemporaryFile(mode="w+") as stderr:
        proc = subprocess.Popen([sys.argv[1]], cwd=work, env=env,
                                stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                stderr=stderr, text=True, bufsize=1)
        selector = selectors.DefaultSelector()
        selector.register(proc.stdout, selectors.EVENT_READ)

        def send(message):
            proc.stdin.write(json.dumps({"jsonrpc": "2.0", **message}) + "\n")
            proc.stdin.flush()

        def response(request_id):
            deadline = time.monotonic() + 30
            while time.monotonic() < deadline:
                if not selector.select(max(0, deadline - time.monotonic())):
                    break
                line = proc.stdout.readline()
                if not line:
                    break
                message = json.loads(line)  # stdout must contain only JSON-RPC.
                if message.get("id") == request_id:
                    assert "error" not in message, message
                    return message["result"]
            stderr.seek(0)
            raise AssertionError("No MCP response: " + stderr.read())

        try:
            send({"id": 1, "method": "initialize", "params": {
                "protocolVersion": "2024-11-05", "capabilities": {},
                "clientInfo": {"name": "nix-package-check", "version": "1"}}})
            initialized = response(1)
            assert initialized.get("serverInfo"), initialized
            send({"method": "notifications/initialized"})
            send({"id": 2, "method": "tools/list", "params": {}})
            tools = response(2)["tools"]
            assert tools and all(tool.get("name") and tool.get("inputSchema") for tool in tools)
            print(f"{sys.argv[1]}: initialize and tools/list passed ({len(tools)} tools)")
        finally:
            selector.close()
            proc.terminate()
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
