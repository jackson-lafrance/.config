# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Tab completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt AUTO_MENU
setopt COMPLETE_IN_WORD

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

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

[ -f /opt/dev/dev.sh ] && source /opt/dev/dev.sh

alias python3='/opt/homebrew/bin/python3'
export PATH="$HOME/.local/bin:$PATH"

tmux source-file ~/.config/tmux/tmux.conf

source <(fzf --zsh)

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

# tmux session picker (fzf)
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

# eza aliases (better ls)
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias la='eza -a --icons'
alias lt='eza --tree --icons --level=2'

setopt prompt_subst

git_prompt() {
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    [[ -z "$branch" ]] && return
    
    local color="green"  
    
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        color="yellow"
    fi
    
    if [[ -n $(git log @{upstream}..HEAD 2>/dev/null) ]]; then
        color="cyan"
    fi
    
    echo "%F{$color} $branch%f"
}

PROMPT='%F{blue}%~%f$(git_prompt) %F{magenta}❯%f '

# Autosuggestions (Ctrl+Space to trigger, lighter color)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=0
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(accept-line)
bindkey '^y' autosuggest-fetch  # Ctrl+Y to trigger
bindkey '^[[Z' autosuggest-accept  # Shift+Tab to accept

source ~/.config/ollama/commands.zsh

# Added by tec agent
[[ -x /Users/jacksonlafranceshopify/.local/state/tec/profiles/base/current/global/init ]] && eval "$(/Users/jacksonlafranceshopify/.local/state/tec/profiles/base/current/global/init zsh)"

# Syntax highlighting (must be last)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
