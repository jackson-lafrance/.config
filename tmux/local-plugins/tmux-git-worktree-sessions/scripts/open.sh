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

clear_screen() {
  if [[ -t 2 ]]; then
    printf '\033[2J\033[H' >&2
  elif [[ -t 1 ]]; then
    printf '\033[2J\033[H'
  fi
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

is_truthy() {
  local value

  value="$(printf '%s' "$1" | LC_ALL=C tr '[:upper:]' '[:lower:]')"

  case "$value" in
    1 | on | true | yes | y)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_shell_command() {
  local command="$1"
  local shell_name="${SHELL##*/}"

  command="${command#-}"

  case "$command" in
    "$shell_name" | sh | bash | zsh | fish | nu | elvish | ksh | dash | tcsh | csh)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

mark_gwt_session() {
  local target="$1"
  local repo="$2"

  tmux set-option -q -t "$target" @gwt-managed-session "1" 2>/dev/null || true
  tmux set-option -q -t "$target" @gwt-repo-root "$repo" 2>/dev/null || true
}

source_session_is_managed() {
  local source_session_id="$1"
  local source_session_name="$2"
  local repo_component="$3"
  local repo="$4"
  local managed
  local managed_repo

  managed="$(tmux show-option -qv -t "$source_session_id" @gwt-managed-session 2>/dev/null || true)"
  managed_repo="$(tmux show-option -qv -t "$source_session_id" @gwt-repo-root 2>/dev/null || true)"

  if [[ "$managed" == "1" && ( -z "$managed_repo" || "$managed_repo" == "$repo" ) ]]; then
    return 0
  fi

  # Migration fallback for sessions created before @gwt-managed-session existed.
  [[ "$source_session_name" == "$repo_component-"* ]]
}

session_appears_empty() {
  local target="$1"
  local attached_count
  local window_count
  local pane_count
  local pane_command

  attached_count="$(tmux display-message -p -t "$target" '#{session_attached}' 2>/dev/null || true)"
  window_count="$(tmux display-message -p -t "$target" '#{session_windows}' 2>/dev/null || true)"
  pane_count="$(tmux list-panes -s -t "$target" -F '#{pane_id}' 2>/dev/null | wc -l | tr -d '[:space:]' || true)"
  pane_command="$(tmux list-panes -s -t "$target" -F '#{pane_current_command}' 2>/dev/null | sed -n '1p' || true)"

  [[ "$attached_count" == "0" ]] || return 1
  [[ "$window_count" == "1" ]] || return 1
  [[ "$pane_count" == "1" ]] || return 1
  is_shell_command "$pane_command"
}

maybe_kill_source_session() {
  local enabled="$1"
  local source_session_id="$2"
  local source_session_name="$3"
  local target_session_name="$4"
  local repo_component="$5"
  local repo="$6"

  is_truthy "$enabled" || return 0
  [[ -n "$source_session_id" && -n "$source_session_name" ]] || return 0
  [[ "$source_session_name" != "$target_session_name" ]] || return 0
  tmux has-session -t "$source_session_id" 2>/dev/null || return 0
  source_session_is_managed "$source_session_id" "$source_session_name" "$repo_component" "$repo" || return 0
  session_appears_empty "$source_session_id" || return 0

  tmux kill-session -t "$source_session_id" 2>/dev/null || true
}

refresh_remote() {
  local repo="$1"
  local remote="$2"

  clear_screen
  printf 'Refreshing %s...\n' "$remote" >&2

  if ! git -C "$repo" fetch --prune --no-tags "$remote" >/dev/null 2>&1; then
    display_message "git fetch --prune --no-tags $remote failed; branch picker closed"
    exit 1
  fi

  clear_screen
}

is_world_repo() {
  local repo="$1"

  [[ "$repo" == "$HOME"/world/trees/*/src ]]
}

world_tree_id_from_path() {
  local path="$1"
  local relative

  case "$path" in
    "$HOME"/world/trees/*)
      relative="${path#"$HOME"/world/trees/}"
      printf '%s' "${relative%%/*}"
      ;;
    *)
      printf 'world'
      ;;
  esac
}

switch_with_dev_tree() {
  local finalizers_file
  local status
  local line
  local destination=""
  local tree_id
  local session_name
  local window_name

  command -v dev >/dev/null 2>&1 || die "World worktrees should be managed with dev tree, but dev was not found"

  finalizers_file="$(mktemp "${TMPDIR:-/tmp}/gwt-dev-tree-finalizers.XXXXXX")" || die "Failed to create finalizer tempfile"

  set +e
  dev tree switch 9>"$finalizers_file"
  status=$?
  set -e

  if [[ $status -ne 0 ]]; then
    rm -f "$finalizers_file"
    display_message "dev tree switch failed"
    pause_before_exit
    exit "$status"
  fi

  while IFS= read -r line; do
    case "$line" in
      cd:*)
        destination="${line#cd:}"
        ;;
    esac
  done < "$finalizers_file"

  rm -f "$finalizers_file"

  # Cancelling the picker or selecting the current tree produces no cd finalizer.
  [[ -n "$destination" ]] || exit 0

  [[ -d "$destination" ]] || die "dev tree returned a directory that does not exist: $destination"

  tree_id="$(world_tree_id_from_path "$destination")"
  session_name="$(sanitize_component "world-$tree_id" "world-tree" 80)"
  window_name="$(sanitize_component "$tree_id" "tree" 40)"

  if tmux has-session -t "=$session_name" 2>/dev/null; then
    tmux switch-client -t "=$session_name" || die "Failed to switch to tmux session $session_name"
  else
    tmux new-session -d -s "$session_name" -n "$window_name" -c "$destination" || die "Failed to create tmux session $session_name"
    tmux switch-client -t "=$session_name" || die "Failed to switch to tmux session $session_name"
  fi

  display_message "switched to dev tree $tree_id at $destination"
}

list_branches() {
  local repo="$1"
  local remote="$2"

  {
    git -C "$repo" for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads

    # World has hundreds of thousands of remote refs. Listing them makes the
    # picker feel frozen, and World worktrees are normally managed with `dev tree`.
    if ! is_world_repo "$repo"; then
      git -C "$repo" for-each-ref --sort=-committerdate --format='%(refname:short)' "refs/remotes/$remote" |
        awk -v remote="$remote" '
          $0 == remote "/HEAD" { next }
          index($0, remote "/") == 1 { print substr($0, length(remote) + 2) }
        '
    fi
  } | awk 'NF && !seen[$0]++'
}

prompt_for_new_branch() {
  local default_branch="$1"
  local branch

  clear_screen
  printf 'Create a new branch\n\n' >&2

  if [[ -n "$default_branch" ]]; then
    read -r -p "Branch name [$default_branch]: " branch || exit 0
    branch="${branch:-$default_branch}"
  else
    read -r -p "Branch name: " branch || exit 0
  fi

  printf '%s' "$branch"
}

select_branch_with_fzf() {
  local repo="$1"
  local remote="$2"
  local branches
  local output
  local status
  local line_count
  local query
  local second_line
  local selected
  local initial_query=""

  command -v fzf >/dev/null 2>&1 || die "fzf is required but was not found"

  while true; do
    branches="$(list_branches "$repo" "$remote")"

    clear_screen

    set +e
    output="$({
      if [[ -n "$branches" ]]; then
        printf '%s\n' "$branches"
      fi
    } |
      fzf \
        --prompt="branch> " \
        --height=100% \
        --layout=reverse \
        --border \
        --no-multi \
        --cycle \
        --query="$initial_query" \
        --header="Enter: open selected | Ctrl-N: new branch | Ctrl-R: refresh refs | Esc: cancel" \
        --expect=ctrl-n,ctrl-r \
        --print-query)"
    status=$?
    set -e

    if [[ $status -eq 130 || -z "$output" ]]; then
      exit 0
    fi

    if [[ $status -ne 0 && $status -ne 1 ]]; then
      die "fzf failed with exit status $status"
    fi

    query="$(printf '%s\n' "$output" | sed -n '1p')"
    second_line="$(printf '%s\n' "$output" | sed -n '2p')"
    line_count="$(printf '%s\n' "$output" | awk 'END { print NR }')"

    case "$second_line" in
      ctrl-n)
        prompt_for_new_branch "$query"
        return 0
        ;;
      ctrl-r)
        initial_query="$query"
        refresh_remote "$repo" "$remote"
        continue
        ;;
    esac

    if [[ "$line_count" -ge 2 ]]; then
      selected="$(printf '%s\n' "$output" | tail -n 1)"
    else
      selected="$query"
    fi

    printf '%s' "$selected"
    return 0
  done
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

source_session_id="$(tmux display-message -p '#{session_id}' 2>/dev/null || true)"
source_session_name="$(tmux display-message -p '#{session_name}' 2>/dev/null || true)"

repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [[ -z "$repo" ]]; then
  die "Not inside a Git repository"
fi

if is_world_repo "$repo"; then
  switch_with_dev_tree
  exit 0
fi

repo_name="$(basename "$repo")"
repo_component="$(sanitize_component "$repo_name" "repo" 64)"

root_option="$(get_tmux_option "@gwt-root" "$HOME/.local/share/tmux-git-worktrees")"
root="$(expand_path "$root_option")"
remote="$(get_tmux_option "@gwt-remote" "origin")"
default_base="$(get_tmux_option "@gwt-default-base" "HEAD")"
kill_source_session="$(get_tmux_option "@gwt-kill-source-session" "off")"

branch="$(select_branch_with_fzf "$repo" "$remote")"

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
  mark_gwt_session "$session_name" "$repo"
  tmux switch-client -t "=$session_name" || die "Failed to switch to tmux session $session_name"
else
  tmux new-session -d -s "$session_name" -n "$branch" -c "$worktree" || die "Failed to create tmux session $session_name"
  mark_gwt_session "$session_name" "$repo"
  tmux switch-client -t "=$session_name" || die "Failed to switch to tmux session $session_name"
fi

maybe_kill_source_session "$kill_source_session" "$source_session_id" "$source_session_name" "$session_name" "$repo_component" "$repo"

display_message "switched to $branch at $worktree"
