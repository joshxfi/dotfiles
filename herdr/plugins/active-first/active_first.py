"""Keep workspaces with running agents at the top of the sidebar.

When an agent starts working, its workspace joins the active block at the top,
below the workspaces that were already active. Idle workspaces keep their
relative order underneath, so the most recently active ones stay near the top.
"""

import json
import os
import socket

ACTIVE = {"working", "blocked"}


def call(method, params=None):
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(2)
        client.connect(os.environ["HERDR_SOCKET_PATH"])
        request = {"id": f"active-first:{method}", "method": method, "params": params or {}}
        client.sendall((json.dumps(request) + "\n").encode())
        buffer = b""
        while not buffer.endswith(b"\n"):
            chunk = client.recv(65536)
            if not chunk:
                break
            buffer += chunk
    response = json.loads(buffer)
    if "error" in response:
        raise SystemExit(f"{method} failed: {response['error']}")
    return response["result"]


def main():
    event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "{}")
    data = event.get("data", event)
    if data.get("agent_status") != "working":
        return
    target = data.get("workspace_id")
    if not target:
        return

    listed = call("workspace.list")["workspaces"]
    workspaces = [w["workspace_id"] for w in listed]
    statuses = {w["workspace_id"]: w["agent_status"] for w in listed}
    if target not in statuses:
        return
    active = [w for w in workspaces if w != target and statuses.get(w) in ACTIVE]

    # Already sitting in the contiguous active run at the top: leave it alone.
    leading = 0
    while leading < len(workspaces) and statuses.get(workspaces[leading]) in ACTIVE:
        leading += 1
    if target in workspaces[:leading] and set(active) <= set(workspaces[:leading]):
        return

    block = active + [target]
    rest = [w for w in workspaces if w not in block]
    if workspaces[: len(block)] == block:
        return
    params = {"workspace_ids": block}
    if rest:
        params["before_workspace_id"] = rest[0]
    call("workspace.move_block", params)


if __name__ == "__main__":
    main()
