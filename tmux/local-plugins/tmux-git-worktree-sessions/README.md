# tmux-git-worktree-sessions

Local tmux plugin for opening one tmux session per Git branch using `git worktree`.

This is meant for large repos where you want multiple branches checked out at once without repeatedly recloning the repo.

`fzf` is required and is always used for branch selection.

## Usage

From inside a Git repo in tmux:

1. Press `prefix + G`.
2. Pick a branch with `fzf` using cached local and remote refs.
3. The plugin creates or reuses a Git worktree for that branch.
4. The plugin switches to a tmux session rooted at that worktree.

In the `fzf` picker:

- `Enter` opens the selected branch.
- `Ctrl-N` lets you type a new branch name.
- `Ctrl-R` runs `git fetch --prune --no-tags origin`, refreshes the branch list, and reopens the picker.
- `Esc` cancels and closes the popup.

Fetch is manual so opening the picker and creating a new branch stay fast in large repos.
Fetch output is suppressed so the picker and new-branch prompt stay clean.
If the manual refresh fails, the plugin treats that as fatal and closes the popup after showing a tmux message.

If the branch exists locally, the worktree is created from the local branch.
If the branch exists as `origin/<branch>`, the plugin creates a local branch from the remote branch.
If the branch does not exist, the plugin asks whether to create it from the configured default base.

## Configuration

Configured from `~/.config/tmux/tmux.conf`:

```tmux
set -g @gwt-root "$HOME/src/git-worktrees"
set -g @gwt-open-key "G"
set -g @gwt-default-base "main"
set -g @gwt-remote "origin"
run-shell '~/.config/tmux/local-plugins/tmux-git-worktree-sessions/tmux-git-worktree-sessions.tmux'
```

Options:

- `@gwt-root`: parent directory for generated worktrees.
- `@gwt-open-key`: tmux prefix binding. Defaults to `G`.
- `@gwt-default-base`: base ref used when creating a new branch. Defaults to `HEAD`.
- `@gwt-remote`: remote checked for existing remote branches and refreshed by `Ctrl-R`. Defaults to `origin`.
- `@gwt-popup-width`: popup width. Defaults to `80%`.
- `@gwt-popup-height`: popup height. Defaults to `60%`.

## Generated layout

For a repo named `shopify` and a branch named `feature/foo`, the generated worktree path looks like:

```text
$HOME/src/git-worktrees/shopify/feature-foo-<hash>
```

The hash prevents collisions between branch names that sanitize to the same path component.

## Safety notes

The plugin does not run `git checkout` in your current checkout. It uses `git worktree`, so each branch gets isolated files and an isolated Git index.

The plugin does not delete worktrees. Cleanup should be done manually for now:

```bash
git worktree list
git worktree remove /path/to/worktree
```

Before removing a worktree, check for uncommitted changes:

```bash
git -C /path/to/worktree status --porcelain
```
