#!/bin/sh
# Apply curated KDE Plasma settings. KDE rewrites its rc files constantly, so
# settings are written with kwriteconfig6 instead of symlinking whole files.

set -eu

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
  printf 'Skipped Plasma: kwriteconfig6 not found\n'
  exit 0
fi

# Caps Lock acts as Left Ctrl (herdr prefix: Caps+A).
kwriteconfig6 --file kxkbrc --group Layout --key ResetOldOptions true
kwriteconfig6 --file kxkbrc --group Layout --key Options ctrl:nocaps

# Ask KWin to reload the keyboard config for the running session.
if command -v dbus-send >/dev/null 2>&1; then
  dbus-send --session --type=signal /Layouts org.kde.keyboard.reloadConfig 2>/dev/null || true
fi

printf 'Applied:       Plasma settings\n'
