"""Move a workspace to the top of the sidebar when an agent in it starts working."""

import json
import os
import socket

event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "{}")
data = event.get("data", event)

if data.get("agent_status") == "working" and data.get("workspace_id"):
    request = {
        "id": "active-first",
        "method": "workspace.move",
        "params": {"workspace_id": data["workspace_id"], "insert_index": 0},
    }
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(2)
        client.connect(os.environ["HERDR_SOCKET_PATH"])
        client.sendall((json.dumps(request) + "\n").encode())
        client.recv(65536)
