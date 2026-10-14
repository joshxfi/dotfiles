# Dotfiles

Personal macOS and Linux configuration, organized by application. This
repository is the source of truth for every managed configuration.

## Managed configuration

- `ghostty/config.{macos,linux}`
- `herdr/config.{macos,linux}.toml`
- `plasma/apply.sh`: curated KDE Plasma settings (Linux only)
- `dns/apply.sh`: Cloudflare DNS (1.1.1.1) for the whole machine
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
git clone https://github.com/joshxfi/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

The installer creates symbolic links. If a destination already exists, it is
moved to a timestamped directory under `~/.dotfiles-backups/` first.

It detects macOS or Linux and selects the matching Ghostty, herdr, and Codex
profiles. On Linux it also runs `plasma/apply.sh`, which writes a few KDE
Plasma settings (such as Caps Lock as Ctrl) with `kwriteconfig6` rather than
symlinking KDE's frequently rewritten rc files. Rerun it after changing it.
The shared Zsh config uses `~/Library/pnpm` on macOS. On Linux it uses
`$XDG_DATA_HOME/pnpm`, falling back to `~/.local/share/pnpm`. Claude sound hooks
use the first available player from `afplay`, `pw-play`, `paplay`, or `aplay`.

For containers or unusual environments, override detection with
`DOTFILES_PLATFORM` set to `macos` or `linux`:

```sh
DOTFILES_PLATFORM=linux ~/.dotfiles/install.sh
```

The installer does not change DNS, because that is a machine-wide setting
that needs `sudo` on Linux. Run the DNS script once on each machine:

```sh
~/.dotfiles/dns/apply.sh
```

On macOS it sets the DNS servers of every enabled network service that has a
device, so VPN services such as Tailscale keep their own DNS. On Linux it writes
`/etc/NetworkManager/conf.d/90-cloudflare-dns.conf`, a global DNS config that
overrides the servers each connection gets from DHCP. Without NetworkManager it
writes `/etc/systemd/resolved.conf.d/90-cloudflare-dns.conf` instead.

To undo it, run `networksetup -setdnsservers <service> empty` on macOS. On
Linux, delete the file and reload NetworkManager or restart systemd-resolved.

herdr plugins are not managed. Install the repository picker (bound to
`prefix+o`, requires `bun`) separately:

```sh
herdr plugin install princejoogie/herdr-repo-picker
```

`herdr/plugins/active-first` moves a workspace to the top of the sidebar when
an agent in it starts working. It goes below workspaces that already have a
working or blocked agent. Link it once:

```sh
herdr plugin link ~/.dotfiles/herdr/plugins/active-first
```

## Daily use

Edit files through their normal paths (`~/.zshrc`, `~/.config/ghostty/config`,
and so on), then commit and push every change from `~/.dotfiles`.
