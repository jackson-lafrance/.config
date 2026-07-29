# Shopify development environment. This file is tracked, but it only runs when
# zsh/.profile.local.zsh sets DOTFILES_PROFILE=shopify.

TEC_INIT="$HOME/.local/state/tec/profiles/base/current/global/init"
if [[ -x "$TEC_INIT" ]]; then
  eval "$("$TEC_INIT" zsh)"
fi

if [[ -f /opt/dev/dev.sh ]]; then
  source /opt/dev/dev.sh
fi

export NVM_DIR="$HOME/.nvm"
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]] && source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
  [[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]] && source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
fi

# Shopify laptops lock down npm. Keep pnpm on PATH, but do not derive PATH from npm.
export PNPM_HOME="$HOME/Library/pnpm"
path_prepend "$PNPM_HOME"
alias prd='pnpm run dev'
alias prs='pnpm run start'
alias prc='pnpm run compile'

# Always launch Shopify's World-aware Herdr wrapper.
alias herdr='devx herdr'
alias h='devx herdr'
