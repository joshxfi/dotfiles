# Dotfiles

Personal macOS and Linux configuration, organized by application. This
repository is the source of truth for every managed configuration.

## Managed configuration

- `ghostty/config.{macos,linux}`
- `nvim/`
- `zsh/`
- `git/config`
- `agents/skills/`: shared user-installed agent skills
- `agents/codex/`: shared Codex files plus platform config profiles
- `agents/claude/`: portable Claude Code settings, rules, hooks, and sounds

Machine-specific or private settings stay outside this repository:

- `~/.zshrc.local`
- `~/.gitconfig.local`

Authentication, sessions, histories, databases, caches, generated files, and
downloaded plugin/runtime bundles are intentionally not managed. Codex and
Claude recreate those locally; sign-in remains a separate setup step.

## Set up a new machine

```sh
git clone git@github.com:joshxfi/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

The installer creates symbolic links. If a destination already exists, it is
moved to a timestamped directory under `~/.dotfiles-backups/` first.

It detects macOS or Linux and selects the matching Ghostty and Codex profiles.
The shared Zsh config uses `~/Library/pnpm` on macOS. On Linux it uses
`$XDG_DATA_HOME/pnpm`, falling back to `~/.local/share/pnpm`. Claude sound hooks
use the first available player from `afplay`, `pw-play`, `paplay`, or `aplay`.

For containers or unusual environments, override detection with
`DOTFILES_PLATFORM` set to `macos` or `linux`:

```sh
DOTFILES_PLATFORM=linux ~/.dotfiles/install.sh
```

## Daily use

Edit files through their normal paths (`~/.zshrc`, `~/.config/ghostty/config`,
and so on), then commit and push every change from `~/.dotfiles`.
