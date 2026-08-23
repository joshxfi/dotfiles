# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="amuse"
plugins=(git z zsh-interactive-cd zsh-autosuggestions)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# Managed configuration
source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/tools.zsh"

# Private and machine-specific configuration
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
