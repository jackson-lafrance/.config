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

Neovim targets the stable 0.12.x release line. `vim.pack` installs plugins on
first launch and `nvim/nvim-pack-lock.json` pins them. Treesitter parsers are a
deliberate one-time bootstrap: install `tree-sitter-cli`, open Neovim, and run
`:TSInstallConfigured`. Run `:TSUpdate` after updating nvim-treesitter.

Optional dependencies, all degraded gracefully when missing: `rg`, `fzf`, `eza`,
`zsh-syntax-highlighting`.

Neovim tools: `fzf`, `rg`, `fd` for the pickers; `prettierd` or `prettier` for
web formatting; `ruby-lsp` installed in each Ruby you use (`gem install
ruby-lsp`); `pi` for Vimgentic.

## Neovim

Plugins are added with `vim.pack` in `nvim/lua/plugins/*.lua`. The lockfile is
the reproducible baseline; updating it is a separate, reviewed operation.

| Command | Action |
| ------- | ------ |
| `:PackSync` | review restoring on-disk plugins to the committed lockfile |
| `:PackUpdate` | review updates from each plugin's configured source/version |
| `:PackClean` | list inactive plugin checkouts without deleting them |
| `:PackClean!` | delete the previously reviewed inactive checkouts |
| `:TSInstallConfigured` | install the parser set used by this config |
| `:TSUpdate` | rebuild/update installed parsers after a Treesitter update |

Blink, Conform, and Quicker are pinned to release tags in their plugin modules;
the lockfile pins exact commits for every plugin.

### C / C++

Clangd supplies C/C++ language knowledge: completion data, diagnostics,
navigation, and formatting. Blink presents its completion results, and Conform
delegates formatting to clangd when no external formatter is configured.
Install clangd with `:MasonInstall clangd` on machines that lack it; Mason
enables it through the existing LSP setup.

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

Restart Neovim after adding the project settings. Neovim warns once per clangd
project when none of these metadata files exists. `<leader>li` shows the
attached servers. `<leader>lf` reaches clangd through Conform and does not need
the standalone `clang-format` executable. Inlay hints stay off unless toggled
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
| `<leader>fq`  | quickfix list as an fzf picker                  |
| `<leader>q`   | toggle and focus the full enhanced quickfix list |
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

In the full quickfix window, `>` adds two context lines around each result and
`<` collapses them. The result text is editable: `:write` applies changed lines
to the source buffers. Those source buffers remain modified, so inspect and
save them normally rather than having Quicker write project files implicitly.

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
| `<leader>lf`  | format buffer, or the visual selection           |
| `<leader>li`  | LSP health                                      |
| `<leader>m`   | Mason                                           |
| `<leader>ch`  | switch source/header (clangd buffers)            |
| `<leader>ci`  | toggle type/parameter hints (clangd buffers)     |

Completion is provided by Blink. Suggestions begin unselected; Tab / Shift-Tab
cycle them and insert the current selection directly into the buffer. Ordinary
word completion does not require Enter: continue typing to keep the selection.
Enter explicitly commits a selected item, which is useful for an LSP function
snippet whose argument placeholders should remain active; subsequent Tab /
Shift-Tab presses move through those placeholders. With no selected item,
Enter falls through to autopairs' newline and brace indentation. `<C-l>` or
`<C-Space>` opens completion manually, `<C-e>` cancels the current selection,
and `<C-k>` toggles signature help. `<C-n>` / `<C-p>` cycle completion items
when those keys reach Neovim. When signature help contains multiple overloads,
`Option-n` / `Option-p` (`Alt-n` / `Alt-p`) select the next / previous overload.
These avoid Alacritty's `<C-n>` new-tab binding. The menu labels each source.
Buffer-word fallback is available for most filetypes but deliberately disabled
for Ruby, where it previously obscured language-server results.

Formatting is manual-only. `<leader>lf` runs the first available
`prettierd`/`prettier` for web filetypes; install it on a new machine with
`:MasonInstall prettierd`. Other languages fall back to their attached LSP,
such as clangd, lua_ls, or project Ruby LSP. `:ConformInfo` shows exactly which
formatter will run and where its error log lives. Mason's global RuboCop LSP is
excluded so it cannot compete with project Ruby LSP.

Diagnostic signs, underlines, and virtual lines are hidden and do not update
during Insert mode. They return with the latest results on InsertLeave, showing
virtual lines only at the cursor and sorted by severity. `[d` and `]d` move
between diagnostics and open their float; `<leader>bb` opens all messages for
the current line.

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

AI (Vimgentic with pi). `<leader>` is Space. Vimgentic runs the `pi`
executable from Neovim's PATH and uses pi's configured default model unless
its model picker overrides it. The plugin revision is pinned in the config
and lockfile.

Search and review:

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>9s`  | search the project; results open in quickfix                |
| `<leader>9o`  | reopen the last search results                             |
| `<leader>9r`  | start a local review (normal or visual mode)                |
| `<leader>9R`  | open the latest completed review for this project           |

Guided tours:

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>9t`  | request a code tour (normal or visual mode)                 |
| `<leader>9g`  | restore this project's latest tour, or open the tour picker |
| `<leader>9j`  | next tour stop                                             |
| `<leader>9k`  | previous tour stop                                         |

Rewrites and explanations:

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>9v`  | visual: request a replacement; normal: preview it           |
| `<leader>9p`  | draft an explanation or next-change request (normal/visual) |
| `<leader>9e`  | draft an explanation of the diagnostic at the cursor        |

Chat:

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>9c`  | normal: open/focus chat or editor; visual: paste selection   |
| `<leader>9C`  | hide chat without stopping pi                              |
| `<leader>9n`  | start a new chat; confirm before replacing the current chat |
| `<leader>9T`  | same terminal sidebar action as normal-mode `<leader>9c`   |

History and controls:

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>9h`  | open session history                                       |
| `<leader>9m`  | pick a persistent model and thinking level per operation    |
| `<leader>9x`  | abort background requests and interrupt chat                |
| `<leader>9l`  | view Vimgentic logs                                        |

Submit search, review, tour, and rewrite prompts with `:w`. Completed reviews,
tours, and replacements do not take focus; open them with `9R`, `9g`, or
normal-mode `9v` after Space. In a replacement preview, Enter accepts and
`q`/Escape discards. Acceptance changes the buffer; save the file separately.

Pair actions, diagnostic explanations, and selections paste editable chat
drafts without submitting them. Press Enter in pi to submit. Pairing guidance
is enabled for Vimgentic chat sessions. In chat, Escape enters terminal-normal
mode; `i` returns to typing and `q` hides the sidebar. The sidebar's local
`<leader>9x` only interrupts chat; `:VimgenticAbortAll` also stops background
requests.

Normal-mode `9c` reuses the existing chat even after you change directories.
Use `9n` for a fresh chat in the editor's current directory. Replacement stops
work and discards unsent input, so it asks first. Escape cancels the menu
without leaving a pending chat switch. Saved conversations remain in history.

The model picker asks for the operation, model, and thinking level. It shows
only that model's supported levels. Higher thinking can take longer and use
more tokens. `(pi default)` leaves the corresponding choice to Pi. Leave Pi's
input empty before changing a live chat's model.

Tours use Left/Right in normal mode and Escape to exit. `9g` restores a saved
tour after a restart; with no tour for this directory, it opens the tour
picker. A missing file still shows its explanation and allows the next step.
New tours request focused steps with inputs, a walkthrough, decisions and
effects, and the next transition. Use `9t` to regenerate sparse explanations;
saved tours keep their original text.

Review reports use Enter to jump, `]t`/`[t` to navigate, `gq` for quickfix,
and `q` to close. History's Enter opens each session as its original kind:
review, tour, search, or chat. Ctrl-o explicitly resumes any session in chat.
Ctrl-r also opens saved reviews and tours, even after a later chat follow-up.
An empty history still opens so Ctrl-p can show other projects.

Additional commands without shortcuts: `:VimgenticReviewQuickfix` opens review
findings in quickfix, and `:VimgenticTourClose` exits the tour. Type
`:Vimgentic` and press Tab to browse the commands.

## Not tracked

Machine-local state and secrets are deliberately ignored: `zsh/.*.local.zsh`,
`gh/`, `gcloud/`, `containers/`, `dev/`, `graphite/auth`, agent state, and
editor caches. See `.gitignore`.
