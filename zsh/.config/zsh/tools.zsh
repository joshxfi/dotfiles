# Keep each PATH entry unique while preserving precedence.
typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "$HOME/Library/pnpm"
  "$HOME/.bun/bin"
  "$HOME/.lmstudio/bin"
  "/opt/homebrew/opt/llvm/bin"
  $path
)

export PNPM_HOME="$HOME/Library/pnpm"
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"

[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

[[ -r "$HOME/google-cloud-sdk/path.zsh.inc" ]] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -r "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && source "$HOME/google-cloud-sdk/completion.zsh.inc"
[[ -r "$HOME/.turso/env" ]] && source "$HOME/.turso/env"
[[ -r "$HOME/.vite-plus/env" ]] && source "$HOME/.vite-plus/env"
