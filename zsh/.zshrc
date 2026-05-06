# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo

alias vim=nvim
alias sz='source ~/.config/zsh/.zshrc'
alias tmx='tmux attach -t $(tmux ls -F "#{session_name}" | fzf)'

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
