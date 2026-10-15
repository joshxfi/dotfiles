"""Keep the machine awake while any agent is working, a closed Mac lid included.

caffeinate on macOS and a systemd-inhibit sleep lock on Linux block idle sleep.
On macOS, `pmset disablesleep` also keeps the Mac awake with the lid shut; it
needs the sudoers rule in this directory and is skipped without it, or while on
battery at or below the floor in power.py. While the plugin holds
disablesleep, lid_watcher.py dims the display when the lid closes and lets the
Mac sleep if the battery drops to the floor. disablesleep is one global flag that
`nosleep` also uses, so the plugin only turns it off when it turned it on and no
`nosleep` session is running.
"""

import fcntl
import json
import os
import signal
import socket
import subprocess
import sys

import power

inhibitor_pid = os.path.join(power.state_dir, "inhibitor.pid")
if sys.platform == "darwin":
    inhibitor = "caffeinate"
else:
    inhibitor = "systemd-inhibit"
watcher_pid = os.path.join(power.state_dir, "lid_watcher.pid")


def any_working():
    request = {"id": "keep-awake", "method": "workspace.list", "params": {}}
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        client.settimeout(2)
        client.connect(os.environ["HERDR_SOCKET_PATH"])
        client.sendall((json.dumps(request) + "\n").encode())
        buffer = b""
        while not buffer.endswith(b"\n"):
            chunk = client.recv(65536)
            if not chunk:
                break
            buffer += chunk
    workspaces = json.loads(buffer)["result"]["workspaces"]
    return any(w["agent_status"] == "working" for w in workspaces)


def running_pid(pid_file, marker):
    try:
        pid = int(open(pid_file).read())
        command = subprocess.run(["ps", "-p", str(pid), "-o", "command="], capture_output=True, text=True).stdout
    except (OSError, ValueError):
        return None
    return pid if marker in command else None


def start(pid_file, command):
    process = subprocess.Popen(
        command,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    open(pid_file, "w").write(str(process.pid))


def stop(pid_file, marker):
    pid = running_pid(pid_file, marker)
    if pid is not None:
        os.kill(pid, signal.SIGTERM)
    if os.path.exists(pid_file):
        os.remove(pid_file)


with open(power.lock_path, "w") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    # Hooks run as children of the Herdr server; tie helpers to its lifetime.
    server = str(os.getppid())
    if any_working():
        if running_pid(inhibitor_pid, inhibitor) is None:
            if sys.platform == "darwin":
                start(inhibitor_pid, ["caffeinate", "-i", "-w", server])
            else:
                # The lock lasts as long as tail, which exits with the server.
                start(inhibitor_pid, [
                    "systemd-inhibit", "--what=sleep", "--who=Herdr", "--why=An agent is working",
                    "tail", f"--pid={server}", "-f", "/dev/null",
                ])
        if sys.platform == "darwin" and not power.sleep_disabled() and not power.battery_low():
            if power.set_disablesleep("1"):
                open(power.lid_file, "w").close()
        if os.path.exists(power.lid_file) and running_pid(watcher_pid, "lid_watcher.py") is None:
            start(watcher_pid, [sys.executable, "lid_watcher.py", server])
    else:
        stop(inhibitor_pid, inhibitor)
        stop(watcher_pid, "lid_watcher.py")
        if os.path.exists(power.lid_file):
            if power.nosleep_active() or power.set_disablesleep("0"):
                os.remove(power.lid_file)
