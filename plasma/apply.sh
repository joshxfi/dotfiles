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

# Meta+S takes a Spectacle region screenshot (no Print key on this keyboard).
# Keeps Spectacle's default Meta+Shift+Print.
kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.spectacle.desktop \
  --key RectangularRegionScreenShot "$(printf 'Meta+S\tMeta+Shift+Print')"

# The running shortcut service keeps its own copy and would overwrite the file,
# so also set it over D-Bus. Key codes are Qt's: Meta+S, Meta+Shift+Print.
if command -v gdbus >/dev/null 2>&1; then
  gdbus call --session --dest org.kde.kglobalaccel --object-path /kglobalaccel \
    --method org.kde.KGlobalAccel.setForeignShortcut \
    "['org.kde.spectacle.desktop','RectangularRegionScreenShot','Spectacle','Capture Rectangular Region']" \
    "[268435539, 318767113]" >/dev/null 2>&1 || true
fi

printf 'Applied:       Plasma settings\n'
