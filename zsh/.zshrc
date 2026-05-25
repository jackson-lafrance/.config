# ln -s ~/.config/zsh/.zshrc ~/.zshrc remember this command when pulling repo

path_prepend() {
  [[ -d "$1" ]] || return
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# Homebrew first; Shopify tec/dev can then take precedence where needed.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

path_prepend "$HOME/.local/bin"

# Shopify development environment.
TEC_INIT="$HOME/.local/state/tec/profiles/base/current/global/init"
[[ -x "$TEC_INIT" ]] && eval "$("$TEC_INIT" zsh)"
[[ -f /opt/dev/dev.sh ]] && source /opt/dev/dev.sh

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

alias vim="nvim"
alias sz='source ~/.config/zsh/.zshrc'
alias python3='/opt/homebrew/bin/python3'

alias ga='git add'
alias gr='git restore'
alias gp='git push'
alias gc='git commit'
alias gs='git status'
alias gd='git diff'
alias gl='git pull'
alias g='git'
alias gco='git checkout'
alias gb='git branch'
alias gcm='git commit -m'

export NVM_DIR="$HOME/.nvm"
[[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]] && source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]] && source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# Shopify laptops lock down npm. Keep pnpm on PATH, but do not derive PATH from npm.
export PNPM_HOME="$HOME/Library/pnpm"
path_prepend "$PNPM_HOME"
alias prd='pnpm run dev'
alias prs='pnpm run start'
alias prc='pnpm run compile'

# Ruby LSP is intentionally provided by the active Ruby/dev environment, not Mason.
# Override this in zsh/.shopify.local.zsh if a repo needs a different command.
export RUBY_LSP_CMD="${RUBY_LSP_CMD:-ruby-lsp}"

[[ -n "$TMUX" ]] && tmux source-file ~/.config/tmux/tmux.conf

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

cd_to_dir() {
  local dir="${1:-.}"
  local selected_dir

  if command -v fzf >/dev/null 2>&1; then
    selected_dir=$(fd --type d --base-directory "$dir" | fzf +m --height 50% --preview "eza --tree --level=2 --icons --color=always $dir/{}")
  fi

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

  if command -v fzf >/dev/null 2>&1; then
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --height 50% --prompt 'session> ')
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

# eza aliases (better ls)
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

PROMPT='%F{blue}%~%f$(git_prompt) %F{magenta}❯%f '

if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=0
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(accept-line)
  bindkey '^y' autosuggest-fetch
  bindkey '^[[Z' autosuggest-accept
fi

[[ -f ~/.config/ollama/commands.zsh ]] && source ~/.config/ollama/commands.zsh

# Non-secret Shopify AI defaults. Put keys/tokens in ~/.config/zsh/.shopify.local.zsh.
export OPENAI_API_BASE="${OPENAI_API_BASE:-https://proxy.shopify.ai/v1}"
export OPENAI_MODEL="${OPENAI_MODEL:-gpt-4}"
[[ -f ~/.config/zsh/.shopify.local.zsh ]] && source ~/.config/zsh/.shopify.local.zsh

# Added by LM Studio CLI (lms), if installed.
path_prepend "$HOME/.lmstudio/bin"

# Always run claude with permission prompts skipped.
alias claude='claude --dangerously-skip-permissions'

# Syntax highlighting (must be last)
if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
