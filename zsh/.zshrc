path_prepend() {
  [[ -d "$1" ]] || return
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

path_prepend "$HOME/.local/bin"

alias vim='nvim'
alias sz='source ~/.config/zsh/.zshrc'

[[ -n "$TMUX" ]] && tmux source-file ~/.config/tmux/tmux.conf

tmx() {
  local session

  if ! command -v tmux >/dev/null 2>&1; then
    echo 'tmx requires tmux' >&2
    return 1
  fi

  if command -v fzf >/dev/null 2>&1; then
    session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --height 50% --prompt 'session> ')
  else
    session="$1"
  fi

  [[ -z "$session" ]] && return

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons'
  alias ll='eza -l --icons --git'
  alias la='eza -la --icons'
  alias lt='eza --tree --icons --level=2'
  alias gls='eza --git-ignore --icons --group-directories-first'
fi

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' [%b]'

setopt prompt_subst
PROMPT='%~${vcs_info_msg_0_} %# '

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

[[ -f ~/.config/zsh/.personal.local.zsh ]] && source ~/.config/zsh/.personal.local.zsh

if [[ -n "$HOMEBREW_PREFIX" && -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
