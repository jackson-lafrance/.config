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
- `bin/pi-launch` reads the same machine profile without sourcing `.zshrc`.
  Shopify uses the stable TEC Pi executable; personal/arch use Pi from `PATH`.
  Pi keeps one stable agent directory per machine, with no per-launch relinking.
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

# shared Pi launcher for workers; ~/.local/bin must be on their PATH
mkdir -p ~/.local/bin
ln -s ~/.config/bin/pi-launch ~/.local/bin/pi-launch

# tmux plugins (tpm and friends are tracked as submodules/plugins)
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf   # optional; tmux 3.1+ reads XDG
```

Neovim needs no bootstrapping: `vim.pack` installs plugins on first launch and
`nvim/nvim-pack-lock.json` pins them. Vimgentic installs from GitHub at the
commit in `nvim/lua/plugins/ai.lua`; no `~/vimgentic` checkout is needed.

After pulling updates on a machine with plugins already installed, restart
Neovim and synchronize its installed revisions:

```vim
:lua vim.pack.update(nil, { target = "lockfile" })
```

Review the proposed changes and use `:write` to apply them. Restart Neovim again
to load the updated plugins.

Optional dependencies, all degraded gracefully when missing: `rg`, `fzf`, `eza`,
`zsh-syntax-highlighting`.

Neovim tools: `fzf`, `rg`, `fd` for the pickers; `ruby-lsp` installed in each
Ruby you use (`gem install ruby-lsp`); `pi` for Vimgentic.

## Pi launcher

Terminal `pi` is a thin alias to `bin/pi-launch`. Vimgentic uses its absolute
path, and the Sho Pi CI and River CI Watch configs use `pi-launch` from `PATH`.
Worker services need `~/.local/bin` on their `PATH`; they do not need an
interactive zsh session. An explicit `SHO_PI_CI_PI_COMMAND` overrides the Sho
Pi CI config and must also point to this launcher if set.

The launcher reads `zsh/.profile.local.zsh` for machine-local exports. Keep
that file declarative; the launcher does not load TEC initialization, dev.sh,
completion, or other interactive setup. Work launches use
`~/.local/state/tec/profiles/base/current/global/bin/pi`, not whichever internal
Pi executable a parent process prepends to `PATH`. A missing work executable
stops the launch rather than falling back to a personal installation.

The existing `~/.pi/agent` directory remains in use. An explicit
`PI_CODING_AGENT_DIR` still overrides it. The launcher does not copy credentials,
change settings/model links, move sessions, or install extensions. The old
`settings.work.json` / `settings.personal.json` and matching model variants are
not selected automatically. Machine profile selection is not credential isolation.

Inspect the launcher without starting Pi:

```sh
~/.config/bin/pi-launch --launcher-info
```

Diagnostics go only to stderr. They show the profile, executable, agent directory,
and (with `--launcher-info`) resolved settings/model paths and a project-settings
candidate. Pi's project trust decision determines whether that project file loads.
No arguments, keys, headers, or full configuration contents are printed. Pi's
footer shows the active model; RPC clients get it through `get_state`. Settings
defaults alone do not establish the active model after overrides or session resume.

Pair/Inspect/Deliver are unchanged. The launcher does not load
`AGENTS.personal.md`. TEC shell initialization remains inside the Shopify profile.
After a config change, reload zsh with `sz` and restart Neovim. Existing workers
keep their old config until restarted; restarting Sho Pi CI can retry failed agents.

## Neovim

Plugins are added with `vim.pack` in `nvim/lua/plugins/*.lua`. `:PackClean`
deletes plugins on disk that the config no longer adds.

### C / C++

Clangd supplies completion, diagnostics, navigation, and formatting. Install it
with `:MasonInstall clangd` on machines that lack it; Mason enables it
through the existing LSP setup. No separate completion or formatting plugin
is needed.

Compiler settings belong in the project, not in Neovim's global config. Use
`compile_commands.json` from the build when available. For a small C++-only
project without that database, such as Relasaurus, put `compile_flags.txt`
beside `include/` and `src/`:

```text
-xc++
-std=c++20
-Iinclude
```

`-xc++` also makes clangd parse standalone `.h` files as C++, rather than C.
`-Iinclude` adds the project's header directory, so source files can use
`#include "algebra.h"` instead of `#include "../include/algebra.h"`. These flags
configure clangd; they do not change the terminal build. Match the flags to
each project's actual build settings.

Restart Neovim after adding the project settings. `<leader>li` shows the
attached servers. `<leader>lf` formats through clangd and does not need the
standalone `clang-format` executable. Inlay hints stay off unless toggled
for a buffer with `<leader>ci`.

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
| `<leader>ch`  | switch source/header (clangd buffers)            |
| `<leader>ci`  | toggle type/parameter hints (clangd buffers)     |

Completion: Tab / Shift-Tab select suggestions. Enter accepts a selected
suggestion; otherwise it starts a new line with autopairs' brace indentation.
An open completion menu with no selection does not consume the newline.

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

AI (Vimgentic through `bin/pi-launch`). Pi owns auth and routing. The launcher
keeps terminal, editor, and worker entry points on the same machine configuration.

Search, visual rewrites, and chat use `openai/gpt-5.6-luna` at home. An explicit
`DOTFILES_PROFILE=shopify` in Neovim's environment selects `openai/gpt-6-astra`
instead. Their thinking levels remain `low`, `medium`, and `high`, respectively.
Saved model choices from `<leader>9m` override these defaults.

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>9s`  | search: ask a question about the project, answers land in the quickfix list |
| `<leader>9v`  | visual: rewrite the selection with a prompt                |
| `<leader>9e`  | explain the diagnostic at the cursor in an editable chat draft |
| `<leader>9r`  | prompt for a background local review; visual mode includes selected lines |
| `<leader>9R`  | open the completed review report                          |
| `<leader>9t`  | prompt for a background guided code tour                   |
| `<leader>9g`  | start the completed tour in the editor                     |
| `<leader>9j` / `<leader>9k` | next / previous tour stop                     |
| `<leader>9o`  | reopen the last search list                                |
| `<leader>9m`  | pick a model (`pi --list-models`)                          |
| `<leader>9x`  | stop all requests                                          |
| `<leader>9l`  | view Vimgentic logs                                        |

Write paths directly in Vimgentic prompts; Pi reads files itself. Submit with
`:w`. Reviews and tours notify without taking focus. Review reports use Enter
to jump, `]t` / `[t` for next / previous, `gq` for quickfix, and `q` to close.
History's `ctrl-r` restores a review or starts a saved tour after a restart.

`<leader>9g` starts the tour at its first code range. The editor highlights that
range, with its explanation in a panel on the right. Use Left/Right arrows in
normal mode to walk through files and ranges; the panel follows each step.
Escape exits and restores the previous editor controls. The tour adds no
comments to source files. In the panel, `g?` shows the overview and `q` also exits.

Reviews explicitly use the bundled local review skill. Reviews and tours keep
normal Pi tools: no-edit instructions are not a sandbox. Jumps use current
buffers, even when a report refers to index or revision coordinates. Check the
reported evidence against current code. Review and tour models use Pi's default
unless you choose them with `<leader>9m` or set `models.review` / `models.tour`.

## Not tracked

Machine-local state and secrets are deliberately ignored: `zsh/.*.local.zsh`,
`gh/`, `gcloud/`, `containers/`, `dev/`, `graphite/auth`, agent state, and
editor caches. See `.gitignore`.
