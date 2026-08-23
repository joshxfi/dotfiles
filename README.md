# Dotfiles

Personal macOS configuration, organized by application. This repository is the
single source of truth for every managed configuration.

## Managed configuration

- `ghostty/config`
- `nvim/`
- `zsh/`
- `git/config`
- `agents/skills/` — shared user-installed agent skills
- `agents/codex/` — Codex settings, rules, hooks, and Codex-only skills
- `agents/claude/` — Claude Code settings, rules, hooks, and sounds

Machine-specific or private settings stay outside this repository:

- `~/.zshrc.local`
- `~/.gitconfig.local`

Authentication, sessions, histories, databases, caches, generated files, and
downloaded plugin/runtime bundles are intentionally not managed. Codex and
Claude recreate those locally; sign-in remains a separate setup step.

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
