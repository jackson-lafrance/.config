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

export PNPM_HOME="$HOME/Library/pnpm"
path_prepend "$PNPM_HOME"

alias vim='nvim'
alias claude='claude --dangerously-skip-permissions'

export JUNIT_JAR="$HOME/lib/junit-platform-console-standalone.jar"
alias jcompile='javac -cp ".:$JUNIT_JAR" *.java ods/*.java'
jtest() {
  java -jar "$JUNIT_JAR" --class-path . --select-class "$1"
}
alias jtestall='java -jar "$JUNIT_JAR" --class-path . --scan-class-path'

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

autoload -Uz compinit
_zcompdump_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
_zcompdump_file="$_zcompdump_dir/zcompdump-${ZSH_VERSION}"
mkdir -p "$_zcompdump_dir"

if [[ -f "$_zcompdump_file" ]]; then
  compinit -C -d "$_zcompdump_file"
else
  compinit -d "$_zcompdump_file"
fi

unset _zcompdump_dir _zcompdump_file

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

if [[ -t 0 && -t 1 ]] && command -v fzf >/dev/null 2>&1; then
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
  local branch upstream branch_color root
  local ahead behind

  _prompt_git_info=''

  root=$(git rev-parse --show-toplevel 2>/dev/null) || return

  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
  [[ -n "$branch" ]] || branch=$(git rev-parse --short HEAD 2>/dev/null)
  [[ -n "$branch" ]] || return

  # World has hundreds of thousands of files/refs, so dirty/untracked/ahead
  # checks make every prompt noticeably slow there. Keep the prompt to branch
  # name only inside World checkouts.
  if [[ "$root" == "$HOME"/world/trees/*/src ]]; then
    _prompt_git_info=" ${RP_MUTED}[${RP_PINE}${branch}${RP_MUTED}]${RP_RESET}"
    return
  fi

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

typeset -g _dotfiles_git_prompt_cache_pwd=''
typeset -gi _dotfiles_git_prompt_cache_time=0
typeset -gi _dotfiles_git_prompt_cache_dirty=1

_dotfiles_invalidate_git_prompt_cache() {
  case "$1" in
    git|git\ *|g|g\ *|dev|dev\ *|tec|tec\ *)
      _dotfiles_git_prompt_cache_dirty=1
      ;;
  esac
}

_dotfiles_update_git_prompt_cached() {
  local ttl="${DOTFILES_GIT_PROMPT_TTL:-5}"
  [[ "$ttl" == <-> ]] || ttl=5

  if [[ "$PWD" == "$_dotfiles_git_prompt_cache_pwd" \
    && "$_dotfiles_git_prompt_cache_dirty" -eq 0 \
    && $(( SECONDS - _dotfiles_git_prompt_cache_time )) -lt "$ttl" ]]; then
    return
  fi

  _dotfiles_update_git_prompt
  _dotfiles_git_prompt_cache_pwd="$PWD"
  _dotfiles_git_prompt_cache_time="$SECONDS"
  _dotfiles_git_prompt_cache_dirty=0
}

autoload -Uz add-zsh-hook
add-zsh-hook -d precmd _dotfiles_update_git_prompt 2>/dev/null
add-zsh-hook -d precmd _dotfiles_update_git_prompt_cached 2>/dev/null
add-zsh-hook -d preexec _dotfiles_invalidate_git_prompt_cache 2>/dev/null
add-zsh-hook precmd _dotfiles_update_git_prompt_cached
add-zsh-hook preexec _dotfiles_invalidate_git_prompt_cache

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

pi() {
  # Dynamically symlink settings and models based on the hostname of the active machine
  if [[ "$(hostname)" == *"jacksons-macbook-pro"* ]]; then
    ln -sf "$HOME/.pi/agent/settings.work.json" "$HOME/.pi/agent/settings.json"
    ln -sf "$HOME/.pi/agent/models.work.json" "$HOME/.pi/agent/models.json"
  else
    ln -sf "$HOME/.pi/agent/settings.personal.json" "$HOME/.pi/agent/settings.json"
    ln -sf "$HOME/.pi/agent/models.personal.json" "$HOME/.pi/agent/models.json"
  fi
  command pi "$@"
}
