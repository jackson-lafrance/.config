# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo
export PI_CODING_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.config/pi/agent}"

alias vim=nvim
alias sz='source ~/.config/zsh/.zshrc'
unalias tmx 2>/dev/null

tmx() {
  local session sessions choice

  sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"

  if [[ -z "$sessions" ]]; then
    tmux start-server >/dev/null 2>&1

    for _ in {1..20}; do
      sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"
      [[ -n "$sessions" ]] && break
      sleep 0.1
    done
  fi

  choice="$(
    {
      printf '%s\n' '+ new session'
      [[ -n "$sessions" ]] && printf '%s\n' "$sessions"
    } | fzf --prompt='tmux> ' --height=40% --border
  )" || return

  if [[ "$choice" == '+ new session' ]]; then
    read -r "session?session name: " || return
    [[ -z "$session" ]] && return
  else
    session="$choice"
  fi

  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias lt="eza --tree"
alias gls="eza --git-ignore --icons --group-directories-first"

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats ' [%b]'

setopt prompt_subst
PROMPT='%~${vcs_info_msg_0_} %# '

autoload -Uz compinit && compinit
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="$HOME/.local/bin:$PATH"
