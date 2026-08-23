#!/bin/sh

sound_name=${1:-}
sound_file="$HOME/.claude/sounds/$sound_name.mp3"

[ -f "$sound_file" ] || exit 0

if command -v afplay >/dev/null 2>&1; then
  afplay -v 0.8 "$sound_file" >/dev/null 2>&1 || true
elif command -v pw-play >/dev/null 2>&1; then
  pw-play "$sound_file" >/dev/null 2>&1 || true
elif command -v paplay >/dev/null 2>&1; then
  paplay "$sound_file" >/dev/null 2>&1 || true
elif command -v aplay >/dev/null 2>&1; then
  aplay "$sound_file" >/dev/null 2>&1 || true
fi

exit 0
