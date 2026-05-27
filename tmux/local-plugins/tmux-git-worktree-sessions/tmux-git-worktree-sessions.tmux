#!/usr/bin/env bash
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local value

  value="$(tmux show-option -gqv "$option" 2>/dev/null || true)"

  if [[ -z "$value" ]]; then
    printf '%s' "$default_value"
  else
    printf '%s' "$value"
  fi
}

open_key="$(get_tmux_option "@gwt-open-key" "G")"
popup_width="$(get_tmux_option "@gwt-popup-width" "80%")"
popup_height="$(get_tmux_option "@gwt-popup-height" "60%")"

# prefix + G by default: open/create a Git-worktree-backed tmux session for a branch.
tmux bind-key "$open_key" display-popup \
  -d "#{pane_current_path}" \
  -w "$popup_width" \
  -h "$popup_height" \
  -E "$CURRENT_DIR/scripts/open.sh"
