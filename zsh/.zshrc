# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
if command -v npm >/dev/null 2>&1; then
  export PATH="$(npm prefix -g)/bin:$PATH"
fi

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

alias vim="nvim"
alias sz='source ~/.config/zsh/.zshrc'
alias python3='/opt/homebrew/bin/python3'

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

[[ -n "$TMUX" ]] && tmux source-file ~/.config/tmux/tmux.conf

cd_to_dir() {
  local dir="${1:-.}"
  local selected_dir

  selected_dir=$(fd --type d --base-directory "$dir" | fzf +m --height 50% --preview "eza --tree --level=2 --icons --color=always $dir/{}")
  if [[ -n "$selected_dir" ]]; then
    cd "$dir/$selected_dir" || return 1
  fi
}
alias cdq='cd_to_dir ~/slaade'
alias cdd='cd_to_dir ~/src/github.com/DevDegree'
alias cds='cd_to_dir'

export JUNIT_JAR="$HOME/lib/junit-platform-console-standalone.jar"
alias jcompile='javac -cp ".:$JUNIT_JAR" *.java ods/*.java'
jtest() {
  java -jar "$JUNIT_JAR" --class-path . --select-class "$1"
}
alias jtestall='java -jar "$JUNIT_JAR" --class-path . --scan-class-path'

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

alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -a --icons'
alias lt='eza --tree --icons --level=2'
alias gls='eza --git-ignore --icons --group-directories-first'

setopt prompt_subst

git_prompt() {
  local branch
  local color="green"

  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    color="yellow"
  fi

  if [[ -n $(git log @{upstream}..HEAD 2>/dev/null) ]]; then
    color="cyan"
  fi

  echo " %F{$color}[$branch]%f"
}

PROMPT='%F{blue}%~%f$(git_prompt) %F{magenta}%#%f '

if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=0
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(accept-line)
  bindkey '^y' autosuggest-fetch
  bindkey '^[[Z' autosuggest-accept
fi

alias idf=". $HOME/.espressif/v6.0/esp-idf/export.sh"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
