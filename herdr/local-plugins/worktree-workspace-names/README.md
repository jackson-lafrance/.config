# Worktree workspace names

Herdr's agent cards use their workspace label as the primary name. This local
plugin renames worktree-backed workspaces to the checked-out Git branch, while
leaving ordinary workspaces unchanged.

It syncs when a worktree is created or opened and whenever an agent changes
state. The state hook also repairs names after restoring an older Herdr session.
Detached World trees use the tree directory name because no branch is available.

Link and perform an initial sync with:

```sh
herdr plugin link ~/.config/herdr/local-plugins/worktree-workspace-names
herdr plugin action invoke jl.worktree-workspace-names.sync
```
