#!/bin/bash
# Mirrors the oh-my-zsh "amuse" prompt: path, git branch, clock
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
dir="${cwd/#$HOME/~}"

branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  b=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
      || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  mark=""
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    mark=$(printf '\033[31m!')
  fi
  branch=$(printf ' on \033[35m\xee\x82\xa0 %s%s\033[0m' "$b" "$mark")
fi

model=$(echo "$input" | jq -r '.model.display_name')
printf '\033[1;32m%s\033[0m%s \xe2\x8c\x9a \033[1;31m%s\033[0m \033[2m%s\033[0m' \
  "$dir" "$branch" "$(date +%H:%M:%S)" "$model"
