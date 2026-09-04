# dotfiles

`~/.config` for every machine: Neovim, zsh, tmux, alacritty, herdr, and the
Linux desktop bits (hypr, quickshell, dunst).

One branch serves every machine. Machine differences live in **profiles**, not
in branches, so `main` can be pulled anywhere.

## Machine profiles

`DOTFILES_PROFILE` selects the profile and is set in `zsh/.profile.local.zsh`,
which is **git-ignored** — machine choices and secrets never get committed.

| Profile    | Machine                  | Effect                                     |
| ---------- | ------------------------ | ------------------------------------------ |
| `personal` | personal macOS (default) | shared config only                         |
| `arch`     | personal Arch/Linux      | shared config only                         |
| `shopify`  | work machine only        | additionally loads `zsh/profiles/shopify.zsh` |

Work tooling is strictly opt-in:

- Only an explicit `DOTFILES_PROFILE=shopify` loads `zsh/profiles/shopify.zsh`.
- An unset value, a missing profile file, or a typo all resolve to `personal`.
- `pi()` picks its agent settings from the profile, never from the hostname, so
  a personal Mac cannot inherit work agent config.
- Neovim has no work-specific code. Ruby servers run inside whatever Ruby
  environment the project root declares: `.shadowenv.d` (Shopify `dev`, World
  zones) or `.ruby-version` (rbenv). See `nvim/lua/plugins/lsp.lua`.

## New machine setup

```sh
git clone https://github.com/jackson-lafrance/.config.git ~/.config

# zsh: pick the profile for this machine, then point the shell at the repo
cp ~/.config/zsh/.profile.local.zsh.example ~/.config/zsh/.profile.local.zsh
$EDITOR ~/.config/zsh/.profile.local.zsh      # personal | arch | shopify
ln -s ~/.config/zsh/.zshrc ~/.zshrc

# tmux plugins (tpm and friends are tracked as submodules/plugins)
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf   # optional; tmux 3.1+ reads XDG
```

Neovim needs no bootstrapping: `vim.pack` installs plugins on first launch and
`nvim/nvim-pack-lock.json` pins them.

Optional dependencies, all degraded gracefully when missing: `rg`, `fzf`, `eza`,
`zsh-syntax-highlighting`.

Neovim tools: `fzf`, `rg`, `fd` for the pickers; `ruby-lsp` installed in each
Ruby you use (`gem install ruby-lsp`); `pi` for the 99 AI provider.

## Neovim

Plugins are added with `vim.pack` in `nvim/lua/plugins/*.lua`. `:PackClean`
deletes plugins on disk that the config no longer adds.

### Ruby LSP and Sorbet

`ruby_lsp` starts for every Ruby buffer; `sorbet` starts too when the root has
`sorbet/config`. Both run inside the project's Ruby environment, chosen per root:

| Root contains     | Command prefix                         | Where               |
| ----------------- | -------------------------------------- | ------------------- |
| `.shadowenv.d`    | `shadowenv exec --dir <root> --`       | Shopify dev, World  |
| `.ruby-version`   | `rbenv exec`                           | rbenv at home       |
| neither           | plain `PATH`                           |                     |

The root is the nearest `.shadowenv.d` (the World zone, even inside nested
gems), otherwise the nearest `Gemfile` or `.git`. In World, run `dev up` in the
tree first; Ruby LSP needs the zone's `.dev/gem`.

Ruby LSP sees `sorbet-static` in the bundle and leaves hover, definition and
completion in `typed: true` files to Sorbet. `RUBY_LSP_BYPASS_TYPECHECKER=1`
makes Ruby LSP serve them itself (faster, no type errors).

### Keymaps

Finder (fzf-lua). Lowercase searches from Neovim's cwd, so start `nvim` inside
the zone or project. Uppercase searches from the git root (in World: the whole
sparse checkout).

| Keymap        | Action                                          |
| ------------- | ----------------------------------------------- |
| `<leader>ff`  | find files                                      |
| `<leader>fw`  | live grep (visual: grep the selection)          |
| `<leader>fF`  | find files from the git root                    |
| `<leader>fW`  | live grep from the git root                     |
| `<leader>fd`  | find files from this buffer's directory (Oil: the browsed directory) |
| `<leader>f.`  | grep the word under the cursor                  |
| `<leader>fr`  | resume the last picker                          |
| `<leader>fb`  | buffers                                         |
| `<leader>fo`  | recent files                                    |
| `<leader>fq`  | quickfix list (picker; `:copen` shows full text) |
| `<leader>fs`  | LSP workspace symbols (live)                    |
| `<leader>fh`  | help tags                                       |
| `<leader>fk`  | keymaps                                         |
| `<leader>sd`  | diagnostics, all buffers                        |
| `<leader>sD`  | diagnostics, this buffer                        |

The picker prompt shows the directory it searches. Opening files or browsing
with Oil never changes Neovim's cwd; press `` ` `` in Oil to `:cd` there.

Inside a picker: `alt-h` toggles hidden files, `alt-i` toggles ignored files,
`alt-a` selects all, `alt-q` sends the selection to the quickfix list,
`ctrl-s`/`ctrl-v`/`ctrl-t` open in a split/vsplit/tab.

LSP. Neovim defaults stay: `K` hover, `grn` rename, `[d`/`]d` diagnostics,
`<C-]>` definition via tags, `<C-s>` signature help in insert mode.

| Keymap        | Action                                          |
| ------------- | ----------------------------------------------- |
| `gd`          | definitions                                     |
| `grr`         | references                                      |
| `gri`         | implementations                                 |
| `grt`         | type definitions                                |
| `gO`          | document symbols                                |
| `gra`         | code actions (with diff preview)                |
| `<leader>bb`  | diagnostics for the current line                |
| `<leader>lf`  | format buffer                                   |
| `<leader>li`  | LSP health                                      |
| `<leader>m`   | Mason                                           |

Git (gitsigns + fugitive + fzf-lua).

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `]c` / `[c`   | next / previous hunk (in a diff window: next/prev change) |
| `<leader>hp`  | preview hunk in a float                                   |
| `<leader>to`  | preview hunk inline                                       |
| `<leader>hs`  | stage or unstage hunk (visual: the selection)             |
| `<leader>hr`  | reset hunk (visual: the selection)                        |
| `<leader>hS`  | stage buffer                                              |
| `<leader>hR`  | reset buffer                                              |
| `<leader>hq`  | all hunks in all buffers to the quickfix list             |
| `<leader>hb`  | blame the current line                                    |
| `<leader>hB`  | blame the whole file                                      |
| `<leader>tb`  | toggle inline blame for the current line                  |
| `<leader>tw`  | toggle word diff                                          |
| `ih`          | text object: the hunk                                     |
| `<leader>gg`  | fugitive status (`:Git`)                                  |
| `<leader>gd`  | diff this file against the index                          |
| `<leader>gD`  | diff this file against the default branch                 |
| `<leader>gR`  | review: every changed file since the default branch, one tab each |
| `<leader>gl`  | this file's history in the quickfix list (`:0Gclog`)      |
| `<leader>gs`  | git status picker (stage/unstage with left/right)         |
| `<leader>gb`  | git branches picker                                       |
| `<leader>gc`  | commits that touched this file                            |
| `<leader>gC`  | commits in the repo                                       |

PR review without checking out: `gh pr diff <n> | nvim -R -c 'set ft=diff'`.
With a checkout: `gh pr checkout <n>`, then `<leader>gR`.

AI (99 with a pi provider). pi does auth and routing, so the Shopify AI proxy
is used on the work machine and personal providers at home.

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>9s`  | search: ask a question about the project, answers land in the quickfix list |
| `<leader>9v`  | visual: rewrite the selection with a prompt                |
| `<leader>9o`  | open the last result again                                 |
| `<leader>9m`  | pick a model (`pi --list-models`)                          |
| `<leader>9x`  | stop all requests                                          |
| `<leader>9l`  | view 99 logs                                               |

`@file` completion in the 99 prompt is off (it scans the git root, 1.7M paths
in World). Write the path in the prompt; pi reads files itself.

## Not tracked

Machine-local state and secrets are deliberately ignored: `zsh/.*.local.zsh`,
`gh/`, `gcloud/`, `containers/`, `dev/`, `graphite/auth`, agent state, and
editor caches. See `.gitignore`.
