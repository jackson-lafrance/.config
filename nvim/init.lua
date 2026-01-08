--- Local Variables ---
local vim = vim
local opt = vim.opt
local map = vim.keymap.set

--- Vim Settings ---

vim.cmd(':hi statusline guibg=NONE')

opt.number = true
opt.relativenumber = true

opt.ignorecase = true
opt.smartcase = true

opt.wrap = false

vim.opt.signcolumn = "yes"

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.termguicolors = true
opt.winborder = 'rounded'

--- Vim Bonus Keybindings ---
vim.g.mapleader = ' '
map('n', '<leader>w', ':write<CR>', { desc = 'Save' })
map('n', '<leader>so', ':update<CR> :so<CR>', { desc = 'Load changes from current file' })

map('', '<leader>y', '"+y', { desc = 'Copy to clipboard' })
map('', '<leader>d', '"+d', { desc = 'Cut to clipboard' })

map('n', '<leader>a', ':keepjumps normal! ggVG$<cr>', { desc = 'Select all text in the file' })

map('n', '<CR>', '@="m`o<C-V><Esc>``"<CR>', { desc = 'Newline below' })
map('n', '<S-CR>', '@="m`O<C-V><ESC>``"<CR>', { desc = 'Newline above' })

map('n', '<leader>e', ':Lexplore<CR>', { desc = 'Open file explorer' })
map('n', '<leader>b', '<C-o>', { desc = 'Go back to previous jump' })

map({ 'n', 'v', 'x' }, '<leader>vi', '<Cmd>edit $MYVIMRC<CR>', { desc = 'Edit ' .. vim.fn.expand('$MYVIMRC') })

map('n', '<leader>nh', ':nohlsearch<CR>', { desc = 'Unhighlight current search' })
map('n', '<leader>ss', ':/', { desc = 'Search' })
map({ 'v', 'x' }, '<leader>sw', 'y :/<C-r>"', { desc = 'Search for the current selected text' })


--- Adding Plugins ---
vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

--- Theme ---
vim.cmd.colorscheme("rose-pine-main")

--- Treesitter ---
require "nvim-treesitter".install { "lua", "typescript", "python", "javascript", "cpp", "c", "java", "html", "css" }

--- Telescope Setup ---
require "telescope".setup({
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
      }
    }
  },
  defaults = {
    preview = { treesitter = true },
    color_devicons = true,
    sorting_strategy = "ascending",
    borderchars = {
      "", -- top
      "", -- right
      "", -- bottom
      "", -- left
      "", -- top-left
      "", -- top-right
      "", -- bottom-right
      "", -- bottom-left
    },
    path_displays = { "smart" },
    layout_config = {
      height = 100,
      width = 400,
      prompt_position = "top",
      preview_cutoff = 40,
    }
  }
})

require "telescope".load_extension("ui-select")
local builtin = require("telescope.builtin")

--- Telescope Keybinds ---
map({ 'n' }, '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
map({ 'n' }, '<leader>g', builtin.live_grep, { desc = 'Telescope live grep' })
map({ 'n' }, '<leader>of', builtin.oldfiles, { desc = 'Prev file viewer' })
map({ 'n' }, '<leader>cs', builtin.commands, { desc = 'Command viewer' })
map({ 'n' }, '<leader>ch', builtin.command_history, { desc = 'Command history' })
map({ 'n' }, '<leader>gs', builtin.git_status, { desc = 'Git status' })
map({ 'n' }, '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
map({ 'n' }, '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
map({ 'n' }, '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })

--- LSP Setup ---
vim.lsp.enable({ "lua_ls" })
map({ 'n' }, '<leader>lf', vim.lsp.buf.format, { desc = 'Format current buffer' })
