#!/bin/sh

set -eu

dotfiles_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
backup_root="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
created_backup=false

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

link_config "$dotfiles_root/zsh/.zshrc" "$HOME/.zshrc"
link_config "$dotfiles_root/zsh/.config/zsh" "$HOME/.config/zsh"
link_config "$dotfiles_root/git/.gitconfig" "$HOME/.gitconfig"
link_config "$dotfiles_root/ghostty/.config/ghostty/config" "$HOME/.config/ghostty/config"
link_config "$dotfiles_root/nvim/.config/nvim" "$HOME/.config/nvim"

if [ ! -e "$HOME/.zshrc.local" ]; then
  printf '%s\n' '# Machine-specific shell settings and secrets go here.' > "$HOME/.zshrc.local"
  chmod 600 "$HOME/.zshrc.local"
  printf 'Created local: %s\n' "$HOME/.zshrc.local"
fi

if [ "$created_backup" = true ]; then
  printf '\nBackups: %s\n' "$backup_root"
fi

printf '\nDotfiles installed. Open a new terminal to load the shell config.\n'
