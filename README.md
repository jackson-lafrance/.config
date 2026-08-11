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
- Neovim's World-specific search backends (`git ls-files`, `wg`) activate only
  inside a World zone and only when the tooling exists; everywhere else the
  pickers use ripgrep. See `nvim/lua/lib/project.lua`.

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

## Neovim search keymaps

| Keymap        | Action                                                    |
| ------------- | --------------------------------------------------------- |
| `<leader>ff`  | find files in the project/zone                            |
| `<leader>fw`  | live grep in the project/zone                             |
| `<leader>fF`  | find files from the process cwd                           |
| `<leader>fW`  | live grep from the process cwd                            |
| `<leader>fr`  | jump to the Ruby reference under the cursor/selection      |
| `<leader>fR`  | jump to a Ruby reference from the clipboard or a prompt    |
| `<leader>vp`  | open Pi interactive mode in a Neovim terminal split        |
| `<leader>va`  | paste cursor/selection/current-buffer context into Pi      |
| `<leader>vv`  | paste that context into Pi and start nerd-dictation        |
| `<leader>vx`  | close the Pi terminal split/session                        |
| `:RubyRef …`  | jump to the given Ruby reference                           |

Inside a picker, `<C-h>` toggles hidden files and `<C-g>` toggles noisy
generated files (`*.rbi`, sorbet/tapioca, translation JSON).

### Ruby reference jumping

`<leader>fr` resolves a fully-qualified Ruby reference to its definition:

```
Billing::Admin::Invoices::Resolvers::Profile::LineItems#resolve
Billing::FindInvoicesForShop.perform
app/models/billing/invoice.rb:42
```

That text is what stack traces, CI failures, and review comments use, but it
rarely appears verbatim in the defining file (the file nests `module Billing`,
`module Admin`, …). So the lookup is structural rather than textual: underscore
the constant into a path suffix, match files ending with it (retrying with
shorter suffixes for non-standard autoload roots), fall back to grepping for
`class|module <Name>`, then jump to `def <method>` / `def self.<method>`.

Noisy input is fine — `NoMethodError in Foo::Bar#baz` resolves `Foo::Bar#baz`.
Several matching files open a picker. See `nvim/lua/ruby_reference.lua`.

## Not tracked

Machine-local state and secrets are deliberately ignored: `zsh/.*.local.zsh`,
`gh/`, `gcloud/`, `containers/`, `dev/`, `graphite/auth`, agent state, and
editor caches. See `.gitignore`.
