#!/bin/sh

set -eu

dotfiles_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
created_backup=false

platform=${DOTFILES_PLATFORM:-}
if [ -z "$platform" ]; then
  case "$(uname -s)" in
    Darwin) platform=macos ;;
    Linux) platform=linux ;;
    *)
      printf 'Unsupported operating system: %s\n' "$(uname -s)" >&2
      exit 1
      ;;
  esac
fi

case "$platform" in
  macos|linux) ;;
  *)
    printf 'Unsupported DOTFILES_PLATFORM: %s\n' "$platform" >&2
    exit 1
    ;;
esac

link_config() {
  source_path=$1
  target_path=$2

  mkdir -p "$(dirname -- "$target_path")"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    printf 'Already linked: %s\n' "$target_path"
    return
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    relative_target=${target_path#"$HOME"/}
    mkdir -p "$backup_root/$(dirname -- "$relative_target")"
    mv "$target_path" "$backup_root/$relative_target"
    created_backup=true
    printf 'Backed up:     %s\n' "$target_path"
  fi

  ln -s "$source_path" "$target_path"
  printf 'Linked:        %s -> %s\n' "$target_path" "$source_path"
}

link_config "$dotfiles_root/zsh/zshrc" "$HOME/.zshrc"
link_config "$dotfiles_root/zsh" "$HOME/.config/zsh"
link_config "$dotfiles_root/git/config" "$HOME/.gitconfig"
link_config "$dotfiles_root/ghostty/config.$platform" "$HOME/.config/ghostty/config"
link_config "$dotfiles_root/nvim" "$HOME/.config/nvim"
link_config "$dotfiles_root/herdr/config.$platform.toml" "$HOME/.config/herdr/config.toml"

# Agent tools: portable settings, instructions, hooks, and user-installed skills.
link_config "$dotfiles_root/agents/skills" "$HOME/.agents/skills"
link_config "$dotfiles_root/agents/skill-lock.json" "$HOME/.agents/.skill-lock.json"
link_config "$dotfiles_root/agents/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
link_config "$dotfiles_root/agents/codex/config.$platform.toml" "$HOME/.codex/config.toml"
link_config "$dotfiles_root/agents/codex/hooks.json" "$HOME/.codex/hooks.json"
link_config "$dotfiles_root/agents/codex/herdr-agent-state.sh" "$HOME/.codex/herdr-agent-state.sh"
link_config "$dotfiles_root/agents/codex/rules" "$HOME/.codex/rules"
link_config "$dotfiles_root/agents/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_config "$dotfiles_root/agents/claude/settings.json" "$HOME/.claude/settings.json"
link_config "$dotfiles_root/agents/claude/hooks" "$HOME/.claude/hooks"
link_config "$dotfiles_root/agents/claude/rules" "$HOME/.claude/rules"
link_config "$dotfiles_root/agents/claude/sounds" "$HOME/.claude/sounds"

if [ ! -e "$HOME/.zshrc.local" ]; then
  printf '%s\n' '# Machine-specific shell settings and secrets go here.' > "$HOME/.zshrc.local"
  chmod 600 "$HOME/.zshrc.local"
  printf 'Created local: %s\n' "$HOME/.zshrc.local"
fi

if [ "$created_backup" = true ]; then
  printf '\nBackups: %s\n' "$backup_root"
fi

printf '\n%s dotfiles installed. Open a new terminal to load the shell config.\n' "$platform"
