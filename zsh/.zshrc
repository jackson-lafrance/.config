# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo
alias vim=nvim
alias sz='source ~/.config/zsh/.zshrc'

[[ -n "$TMUX" ]] && tmux source-file ~/.config/tmux/tmux.conf

tmx() {
  local session

  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --height 50% --prompt 'session> ')
  [[ -z "$session" ]] && return
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
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="$HOME/.local/bin:$PATH"
