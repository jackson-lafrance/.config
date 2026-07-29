# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo

export ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export DOTFILES_PROFILE_FILE="$ZSH_CONFIG_DIR/.profile.local.zsh"

if [[ -f "$ZSH_CONFIG_DIR/common.zsh" ]]; then
  source "$ZSH_CONFIG_DIR/common.zsh"
else
  print -u2 "dotfiles: missing shared zsh config: $ZSH_CONFIG_DIR/common.zsh"
fi

if typeset -f path_prepend >/dev/null 2>&1; then
  path_prepend "$HOME/.gem/ruby/4.0.0/bin"
fi

if [[ -f "$DOTFILES_PROFILE_FILE" ]]; then
  source "$DOTFILES_PROFILE_FILE"
else
  print -u2 "dotfiles: no $DOTFILES_PROFILE_FILE; using the personal profile"
  print -u2 "dotfiles: copy $ZSH_CONFIG_DIR/.profile.local.zsh.example to $DOTFILES_PROFILE_FILE to change it"
fi

# Work tooling is strictly opt-in. Only an explicit DOTFILES_PROFILE=shopify
# loads it; a fresh clone, an unset value, or a typo all resolve to personal.
# That is what keeps a personal machine free of Shopify paths, aliases, and
# agent settings even though this repo is shared between both machines.
case "${DOTFILES_PROFILE:-}" in
  shopify|personal|arch)
    ;;
  "")
    DOTFILES_PROFILE=personal
    ;;
  *)
    print -u2 "dotfiles: unknown DOTFILES_PROFILE='$DOTFILES_PROFILE'; using personal"
    DOTFILES_PROFILE=personal
    ;;
esac

export DOTFILES_PROFILE

if [[ "$DOTFILES_PROFILE" == "shopify" ]]; then
  if [[ -f "$ZSH_CONFIG_DIR/profiles/shopify.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/profiles/shopify.zsh"
  else
    print -u2 "dotfiles: missing Shopify profile: $ZSH_CONFIG_DIR/profiles/shopify.zsh"
  fi
fi

# ESP-IDF environment helper.
# Run `get_idf` in a terminal before using idf.py.
get_idf() {
  source "$HOME/esp-idf/export.sh"
}

# Syntax highlighting should be loaded after aliases, widgets, and profile setup.
if typeset -f _dotfiles_source_syntax_highlighting >/dev/null 2>&1; then
  _dotfiles_source_syntax_highlighting
fi


# Added by tec agent
[[ -x /Users/jacksonlafranceshopify/.local/state/tec/profiles/base/current/global/init ]] && eval "$(/Users/jacksonlafranceshopify/.local/state/tec/profiles/base/current/global/init zsh)"
