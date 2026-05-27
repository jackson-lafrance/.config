# tmux-git-worktree-sessions

Local tmux plugin for opening one tmux session per Git branch using `git worktree`.

This is meant for large repos where you want multiple branches checked out at once without repeatedly recloning the repo.

`fzf` is required and is always used for branch selection.

## Usage

From inside a Git repo in tmux:

1. Press `prefix + G`.
2. The plugin runs `git fetch --prune origin` by default.
3. Pick a branch with `fzf`.
4. The plugin creates or reuses a Git worktree for that branch.
5. The plugin switches to a tmux session rooted at that worktree.

In the `fzf` picker:

- `Enter` opens the selected branch.
- `Ctrl-N` lets you type a new branch name.
- `Esc` cancels and closes the popup.

Fetch output is suppressed so the picker and new-branch prompt stay clean.
If the fetch fails, the plugin treats that as fatal and closes the popup after showing a tmux message.

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
set -g @gwt-auto-fetch "on"
set -g @gwt-fetch-prune "on"
run-shell '~/.config/tmux/local-plugins/tmux-git-worktree-sessions/tmux-git-worktree-sessions.tmux'
```

Options:

- `@gwt-root`: parent directory for generated worktrees.
- `@gwt-open-key`: tmux prefix binding. Defaults to `G`.
- `@gwt-default-base`: base ref used when creating a new branch. Defaults to `HEAD`.
- `@gwt-remote`: remote checked for existing remote branches. Defaults to `origin`.
- `@gwt-auto-fetch`: whether to fetch the configured remote before opening the picker. Defaults to `on`.
- `@gwt-fetch-prune`: whether automatic fetch uses `--prune`. Defaults to `on`.
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
