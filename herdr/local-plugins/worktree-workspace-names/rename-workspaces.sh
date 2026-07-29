#!/usr/bin/env bash

# Herdr's agent panel uses the workspace label as each card's primary name.
# Keep worktree-backed workspace labels aligned with their checked-out branches.
set -u

herdr_bin="${HERDR_BIN_PATH:-herdr}"

if ! command -v git >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  printf 'worktree workspace naming requires git and jq\n' >&2
  exit 1
fi

worktree_name() {
  local checkout=$1
  local branch fallback

  branch=$(git -C "$checkout" symbolic-ref --quiet --short HEAD 2>/dev/null || true)
  if [[ -n "$branch" ]]; then
    printf '%s\n' "$branch"
    return
  fi

  # Detached World trees all end in /src, so their parent directory is the
  # useful worktree identity. Other repositories use the checkout basename.
  fallback=$(basename "$checkout")
  if [[ "$fallback" == "src" ]]; then
    fallback=$(basename "$(dirname "$checkout")")
  fi
  printf '%s\n' "$fallback"
}

rename_workspace() {
  local workspace_id=$1
  local payload checkout current_label desired_label

  payload=$("$herdr_bin" workspace get "$workspace_id" 2>/dev/null) || return 0
  checkout=$(jq -r '.result.workspace.worktree.checkout_path // empty' <<<"$payload")
  [[ -n "$checkout" && -d "$checkout" ]] || return 0

  current_label=$(jq -r '.result.workspace.label // empty' <<<"$payload")
  desired_label=$(worktree_name "$checkout")
  [[ -n "$desired_label" && "$current_label" != "$desired_label" ]] || return 0

  "$herdr_bin" workspace rename "$workspace_id" "$desired_label" >/dev/null
}

sync_all() {
  local workspace_id

  while IFS= read -r workspace_id; do
    [[ -n "$workspace_id" ]] && rename_workspace "$workspace_id"
  done < <(
    "$herdr_bin" workspace list 2>/dev/null |
      jq -r '.result.workspaces[] | select(.worktree.checkout_path != null) | .workspace_id'
  )
}

case "${1:-event}" in
  sync)
    sync_all
    ;;
  event)
    if [[ -n "${HERDR_WORKSPACE_ID:-}" ]]; then
      rename_workspace "$HERDR_WORKSPACE_ID"
    else
      sync_all
    fi
    ;;
  *)
    printf 'usage: %s {sync|event}\n' "$0" >&2
    exit 2
    ;;
esac
