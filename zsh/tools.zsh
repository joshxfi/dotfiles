# Keep each PATH entry unique while preserving precedence.
typeset -U path PATH
typeset -a platform_paths

case "$OSTYPE" in
  darwin*)
    export PNPM_HOME="$HOME/Library/pnpm"
    platform_paths=("/opt/homebrew/opt/llvm/bin")
    ;;
  linux*)
    export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
    platform_paths=()
    ;;
  *)
    export PNPM_HOME="$HOME/.local/share/pnpm"
    platform_paths=()
    ;;
esac

path=(
  "$HOME/.local/bin"
  "$PNPM_HOME/bin"
  "$PNPM_HOME"
  "$HOME/.bun/bin"
  "$HOME/.lmstudio/bin"
  $platform_paths
  $path
)

export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"

[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

[[ -r "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -r "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"
[[ -r "$HOME/.turso/env" ]] && source "$HOME/.turso/env"
[[ -r "$HOME/.vite-plus/env" ]] && source "$HOME/.vite-plus/env"
