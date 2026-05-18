# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo

# Homebrew and user binaries first so macOS shells find brewed tools and npm globals.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
if command -v npm >/dev/null 2>&1; then
  export PATH="$(npm prefix -g)/bin:$PATH"
fi

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

# Git / project aliases
alias ga="git add"
alias gr="git restore"
alias gp="git push"
alias gc="git commit"
alias gs="git status"
alias gd="git diff"
alias gl="git pull"
alias g="git"
alias gco="git checkout"
alias gb="git branch"
alias gcm="git commit -m"
alias nrd="npm run dev"
alias nrs="npm run start"
alias nrc="npm run compile"

alias vim="nvim"
alias sz='source ~/.config/zsh/.zshrc'
alias python3='/opt/homebrew/bin/python3'

# nvm from Homebrew, if installed.
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# DevDegree helper, if present.
[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

# fzf shell integration, if installed.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Reload tmux config inside tmux sessions.
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

# Java/JUnit helpers.
export JUNIT_JAR="$HOME/lib/junit-platform-console-standalone.jar"
alias jcompile='javac -cp ".:$JUNIT_JAR" *.java ods/*.java'
jtest() {
  java -jar "$JUNIT_JAR" --class-path . --select-class "$1"
}
alias jtestall='java -jar "$JUNIT_JAR" --class-path . --scan-class-path'

# tmux session picker.
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

# eza aliases.
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

  echo "%F{$color} $branch%f"
}

PROMPT='%F{blue}%~%f$(git_prompt) %F{magenta}❯%f '

# Autosuggestions.
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=0
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(accept-line)
  bindkey '^y' autosuggest-fetch
  bindkey '^[[Z' autosuggest-accept
fi

alias idf=". $HOME/.espressif/v6.0/esp-idf/export.sh"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# LM Studio CLI.
export PATH="$PATH:$HOME/.lmstudio/bin"

# Syntax highlighting should be loaded near the end.
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
