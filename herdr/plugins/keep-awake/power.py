"""Sleep and battery helpers shared by keep_awake.py and lid_watcher.py."""

import os
import re
import subprocess
import sys
import time

BATTERY_FLOOR = 10

state_dir = os.environ["HERDR_PLUGIN_STATE_DIR"]
lock_path = os.path.join(state_dir, "lock")
# Exists while the plugin, not nosleep, owns disablesleep.
lid_file = os.path.join(state_dir, "disablesleep")
nosleep_off_at = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "nosleep", "off_at"
)


def sleep_disabled():
    output = subprocess.run(["pmset", "-g"], capture_output=True, text=True).stdout
    return any(line.split()[:2] == ["SleepDisabled", "1"] for line in output.splitlines())


def set_disablesleep(value):
    result = subprocess.run(
        ["sudo", "-n", "/usr/bin/pmset", "-a", "disablesleep", value], capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"pmset disablesleep {value} failed: {result.stderr.strip()}", file=sys.stderr)
    return result.returncode == 0


def nosleep_active():
    try:
        return int(open(nosleep_off_at).read()) > time.time()
    except (OSError, ValueError):
        return False


def battery_low():
    """True when running on battery at or below BATTERY_FLOOR percent."""
    output = subprocess.run(["pmset", "-g", "batt"], capture_output=True, text=True).stdout
    match = re.search(r"(\d+)%", output)
    return "'Battery Power'" in output and match is not None and int(match.group(1)) <= BATTERY_FLOOR
