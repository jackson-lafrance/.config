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
alias claude='claude --dangerously-skip-permissions'

sz() {
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zshrc"

  if [[ -n "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
    tmux source-file "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
  fi
}

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

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

# Rosé Pine prompt palette, using zsh prompt escapes so colors stay local to
# the prompt and reset cleanly after each segment.
RP_RESET='%f'
RP_LOVE='%F{#eb6f92}'
RP_GOLD='%F{#f6c177}'
RP_ROSE='%F{#ebbcba}'
RP_PINE='%F{#31748f}'
RP_FOAM='%F{#9ccfd8}'
RP_IRIS='%F{#c4a7e7}'
RP_MUTED='%F{#6e6a86}'

_dotfiles_update_git_prompt() {
  local branch upstream branch_color
  local ahead behind

  _prompt_git_info=''

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
  [[ -n "$branch" ]] || branch=$(git rev-parse --short HEAD 2>/dev/null)
  [[ -n "$branch" ]] || return

  branch_color="$RP_ROSE"

  if ! git diff --quiet --ignore-submodules -- 2>/dev/null \
    || ! git diff --cached --quiet --ignore-submodules -- 2>/dev/null \
    || [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
    branch_color="$RP_GOLD"
  else
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)

    if [[ -n "$upstream" ]]; then
      ahead=$(git rev-list --count "${upstream}..HEAD" 2>/dev/null)
      behind=$(git rev-list --count "HEAD..${upstream}" 2>/dev/null)

      if (( ${ahead:-0} > 0 )); then
        branch_color="$RP_LOVE"
      elif (( ${behind:-0} > 0 )); then
        branch_color="$RP_IRIS"
      else
        branch_color="$RP_PINE"
      fi
    fi
  fi

  _prompt_git_info=" ${RP_MUTED}[${branch_color}${branch}${RP_MUTED}]${RP_RESET}"
}

autoload -Uz add-zsh-hook
add-zsh-hook -d precmd _dotfiles_update_git_prompt 2>/dev/null
add-zsh-hook precmd _dotfiles_update_git_prompt

setopt prompt_subst
PROMPT='${RP_FOAM}%~${RP_RESET}${_prompt_git_info} ${RP_MUTED}%#${RP_RESET} '

_dotfiles_source_syntax_highlighting() {
  local syntax_file
  local candidates=()

  if [[ -n "$HOMEBREW_PREFIX" ]]; then
    candidates+=("$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh")
  fi

  candidates+=(
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  )

  for syntax_file in "${candidates[@]}"; do
    if [[ -f "$syntax_file" ]]; then
      source "$syntax_file"
      return
    fi
  done
}
