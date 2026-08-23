# Dotfiles

Personal macOS configuration, organized by application. This repository is the
single source of truth for every managed configuration.

## Managed configuration

- `ghostty/.config/ghostty/config`
- `nvim/.config/nvim`
- `zsh/.zshrc` and `zsh/.config/zsh/`
- `git/.gitconfig`

Machine-specific or private settings stay outside this repository:

- `~/.zshrc.local`
- `~/.gitconfig.local`

## Set up a new Mac

```sh
git clone git@github.com:joshxfi/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

The installer creates symbolic links. If a destination already exists, it is
moved to a timestamped directory under `~/.dotfiles-backups/` first.

## Daily use

Edit files through their normal paths (`~/.zshrc`, `~/.config/ghostty/config`,
and so on), then commit and push every change from `~/.dotfiles`.
