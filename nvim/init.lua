--- Vim Settings ---
local vim = vim
local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

opt.wrap = false

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.termguicolors = true

--- Vim Bonus Keybindings ---
local map = vim.keymap.set
vim.g.mapleader = ' '
map('n', '<leader>w', ':write<CR>', {desc = 'Save'})
map('n', '<leader>so', ':update<CR> :so<CR>', {desc = 'Load changes from current file'})

map('', '<leader>y', '"+y', {desc = 'Copy to clipboard'})
map('', '<leader>d', '"+d', {desc = 'Cut to clipboard'})

map('n', '<leader>a', ':keepjumps normal! ggVG$<cr>')

map('n', '<CR>', '@="m`o<C-V><Esc>``"<CR>', {desc = 'Newline below'})
map('n', '<S-CR>', '@="m`O<C-V><ESC>``"<CR>', {desc = 'Newline above'})

map('n', '<leader>e', ':Lexplore<CR>', {desc = 'Open file explorer'})
map('n', '<leader>b', '<C-o>', {desc = 'Go back to previous jump'})

--- Adding Plugins ---
vim.pack.add({
  {src = "https://github.com/rose-pine/neovim"},
})

--- Theme ---
vim.cmd.colorscheme("rose-pine-main")


--- :

