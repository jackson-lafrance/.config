#!/usr/bin/env bash
set -euo pipefail

display_message() {
  if [[ -n "${TMUX:-}" ]]; then
    tmux display-message "gwt: $*" 2>/dev/null || true
  fi
}

pause_before_exit() {
  if [[ -t 0 && "${GWT_NO_PAUSE:-0}" != "1" ]]; then
    printf '\n'
    read -r -p "Press Enter to close..." _ || true
  fi
}

die() {
  printf '\nError: %s\n' "$*" >&2
  display_message "$*"
  pause_before_exit
  exit 1
}

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

expand_path() {
  local path="$1"

  if [[ "$path" == "~" ]]; then
    printf '%s' "$HOME"
  elif [[ "$path" == "~/"* ]]; then
    printf '%s' "$HOME/${path#~/}"
  elif [[ "$path" == '$HOME' ]]; then
    printf '%s' "$HOME"
  elif [[ "$path" == '$HOME/'* ]]; then
    printf '%s' "$HOME${path:5}"
  else
    printf '%s' "$path"
  fi
}

hash_string() {
  local value="$1"

  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$value" | shasum | awk '{print substr($1, 1, 8)}'
  elif command -v sha1sum >/dev/null 2>&1; then
    printf '%s' "$value" | sha1sum | awk '{print substr($1, 1, 8)}'
  else
    printf '%s' "$value" | cksum | awk '{print $1}'
  fi
}

sanitize_component() {
  local value="$1"
  local fallback="$2"
  local max_length="${3:-80}"
  local clean

  clean="$(printf '%s' "$value" | LC_ALL=C tr ' /:@' '-----' | LC_ALL=C tr -cs '[:alnum:]_.-' '-')"
  clean="${clean#-}"
  clean="${clean%-}"

  if [[ -z "$clean" ]]; then
    clean="$fallback"
  fi

  printf '%s' "${clean:0:max_length}"
}

trim_whitespace() {
  local value="$1"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  printf '%s' "$value"
}

existing_worktree_for_branch() {
  local repo="$1"
  local branch="$2"

  git -C "$repo" worktree list --porcelain |
    awk -v wanted="refs/heads/$branch" '
      $1 == "worktree" {
        path = substr($0, 10)
      }

      $1 == "branch" && $2 == wanted {
        print path
        exit
      }
    '
}

create_worktree() {
  local repo="$1"
  local branch="$2"
  local worktree="$3"
  local remote="$4"
  local default_base="$5"

  if git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"; then
    printf '\nCreating worktree for local branch %s...\n' "$branch"
    git -C "$repo" worktree add "$worktree" "$branch" || die "Failed to create worktree for local branch $branch"
  elif git -C "$repo" show-ref --verify --quiet "refs/remotes/$remote/$branch"; then
    printf '\nCreating local branch %s from %s/%s...\n' "$branch" "$remote" "$branch"
    git -C "$repo" worktree add -b "$branch" "$worktree" "$remote/$branch" || die "Failed to create worktree from $remote/$branch"
  else
    printf '\nBranch "%s" does not exist locally or as %s/%s.\n' "$branch" "$remote" "$branch"
    read -r -p "Create it from $default_base? [y/N] " create_branch || exit 0

    case "$create_branch" in
      [Yy] | [Yy][Ee][Ss])
        git -C "$repo" rev-parse --verify "$default_base^{commit}" >/dev/null 2>&1 || die "Default base is not a valid commit: $default_base"
        printf '\nCreating branch %s from %s...\n' "$branch" "$default_base"
        git -C "$repo" worktree add -b "$branch" "$worktree" "$default_base" || die "Failed to create worktree from $default_base"
        ;;
      *)
        exit 0
        ;;
    esac
  fi
}

if [[ -z "${TMUX:-}" ]]; then
  die "This command must run inside tmux"
fi

repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo" ]]; then
  die "Not inside a Git repository"
fi

repo_name="$(basename "$repo")"
repo_component="$(sanitize_component "$repo_name" "repo" 64)"
current_branch="$(git -C "$repo" branch --show-current 2>/dev/null || true)"

root_option="$(get_tmux_option "@gwt-root" "$HOME/.local/share/tmux-git-worktrees")"
root="$(expand_path "$root_option")"
remote="$(get_tmux_option "@gwt-remote" "origin")"
default_base="$(get_tmux_option "@gwt-default-base" "HEAD")"

branch="${1:-${GWT_BRANCH:-}}"

if [[ -z "$branch" ]]; then
  printf 'Repo: %s\n' "$repo"
  if [[ -n "$current_branch" ]]; then
    printf 'Current branch: %s\n' "$current_branch"
  fi
  printf 'Worktree root: %s\n\n' "$root"
  read -r -p "Branch name: " branch || exit 0
fi

branch="$(trim_whitespace "$branch")"

if [[ "$branch" == "$remote/"* ]]; then
  branch="${branch#"$remote/"}"
fi

if [[ -z "$branch" ]]; then
  exit 0
fi

normalized_branch="$(git -C "$repo" check-ref-format --branch "$branch" 2>/dev/null || true)"

if [[ -z "$normalized_branch" ]]; then
  die "Invalid branch name: $branch"
fi

branch="$normalized_branch"
branch_component="$(sanitize_component "$branch" "branch" 80)-$(hash_string "$branch")"
session_name="$repo_component-$branch_component"

existing_worktree="$(existing_worktree_for_branch "$repo" "$branch")"

if [[ -n "$existing_worktree" ]]; then
  worktree="$existing_worktree"
  printf '\nReusing existing worktree: %s\n' "$worktree"
else
  worktree="$root/$repo_component/$branch_component"
  mkdir -p "$(dirname "$worktree")" || die "Failed to create worktree parent directory"

  if [[ -e "$worktree/.git" ]]; then
    actual_branch="$(git -C "$worktree" branch --show-current 2>/dev/null || true)"

    if [[ "$actual_branch" != "$branch" ]]; then
      die "Worktree path already exists for branch $actual_branch: $worktree"
    fi
  elif [[ -e "$worktree" ]]; then
    die "Worktree path already exists but is not a Git worktree: $worktree"
  else
    create_worktree "$repo" "$branch" "$worktree" "$remote" "$default_base"
  fi
fi

if tmux has-session -t "=$session_name" 2>/dev/null; then
  tmux switch-client -t "=$session_name" || die "Failed to switch to tmux session $session_name"
else
  tmux new-session -d -s "$session_name" -n "$branch" -c "$worktree" || die "Failed to create tmux session $session_name"
  tmux switch-client -t "=$session_name" || die "Failed to switch to tmux session $session_name"
fi

display_message "switched to $branch at $worktree"
