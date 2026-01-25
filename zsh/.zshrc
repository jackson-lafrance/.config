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
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh

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

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

alias python3='/opt/homebrew/bin/python3'

chruby ruby-4.0.0 > /dev/null 2>&1

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

alias cdd='cd_to_dir ~/Desktop'
alias cds='cd_to_dir'

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

# Autosuggestions (grey text as you type)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting (must be last)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
