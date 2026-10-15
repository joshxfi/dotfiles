"""Watch the lid while keep_awake.py holds lid-closed mode.

Dims the built-in display while the lid is closed and restores it when the lid
opens. If the Mac is on battery at or below the floor, it releases lid-closed
mode so the Mac sleeps instead of running flat. It exits, restoring the
brightness, on SIGTERM or when the Herdr server it was started for goes away.
"""

import fcntl
import os
import shutil
import signal
import subprocess
import sys
import time

import power

server_pid = int(sys.argv[1])
brightness = shutil.which("nosleep-brightness") or os.path.expanduser("~/.local/bin/nosleep-brightness")


def run(*args):
    result = subprocess.run([brightness, *args], capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else None


def lid_closed():
    output = subprocess.run(
        ["ioreg", "-r", "-k", "AppleClamshellState", "-d", "4"], capture_output=True, text=True
    ).stdout
    return any('"AppleClamshellState" = Yes' in line for line in output.splitlines())


def server_alive():
    try:
        os.kill(server_pid, 0)
        return True
    except OSError:
        return False


def release_lid_mode():
    """Give disablesleep back so the closed Mac sleeps. Returns True if released."""
    with open(power.lock_path, "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if not os.path.exists(power.lid_file) or power.nosleep_active():
            return False
        if power.set_disablesleep("0"):
            os.remove(power.lid_file)
            return True
    return False


stopping = False


def stop(*_):
    global stopping
    stopping = True


signal.signal(signal.SIGTERM, stop)
signal.signal(signal.SIGHUP, stop)

display_id = None
saved_level = None
was_closed = None
try:
    while not stopping and server_alive():
        closed = lid_closed()
        if not closed and was_closed is not False:
            if saved_level is not None:
                run("--display", display_id, "set", saved_level)
                saved_level = None
            snapshot = run("snapshot")
            display_id = snapshot.split()[0] if snapshot else None
        elif closed and was_closed is False and display_id and not power.nosleep_active():
            # nosleep runs its own lid watcher, so leave the display to it.
            level = run("--display", display_id, "get")
            if level and run("--display", display_id, "set", "0") is not None:
                saved_level = level
        if closed and power.battery_low():
            # Restore first so the display is normal on wake.
            if saved_level is not None:
                run("--display", display_id, "set", saved_level)
                saved_level = None
            if release_lid_mode():
                break
        was_closed = closed
        time.sleep(1)
finally:
    if saved_level is not None:
        run("--display", display_id, "set", saved_level)
