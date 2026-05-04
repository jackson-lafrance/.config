# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo

alias vim=nvim
alias sz='source ~/.config/zsh/.zshrc'
alias tmx='tmux attach -t $(tmux ls -F "#{session_name}" | fzf)'
