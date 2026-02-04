--- Local Variables ---
local vim = vim
local opt = vim.opt
local map = vim.keymap.set

vim.g.mapleader = ' '
--- Vim Commands ---
vim.cmd('hi statusline guibg=NONE')
vim.cmd([[set mouse=]])
vim.cmd([[set noswapfile]])
vim.cmd([[hi @lsp.type.number gui=italic]])

--- Vim Settings ---
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

opt.ignorecase = true
opt.smartcase = true

opt.wrap = false
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.termguicolors = true
opt.winborder = 'rounded'
opt.guicursor = ''

vim.opt.undofile = true

--- Adding Plugins ---
vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/stevearc/oil.nvim" },

  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },

  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/aznhe21/actions-preview.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },

  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },

  { src = "https://github.com/chomosuke/typst-preview.nvim" },

  { src = "https://github.com/akinsho/toggleterm.nvim" },

  { src = "https://github.com/tpope/vim-rails" },
})

--- Theme ---
vim.cmd("colorscheme rose-pine-main")

--- Theme, Ty Treesitter and Oil ---
require "nvim-treesitter".setup({
  auto_install = true
})

require "oil".setup()

--- LSP Setup ---
require "mason".setup()
require "mason-lspconfig".setup({
  automatic_installation = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

vim.cmd [[set completeopt+=menuone,noselect,popup]]

vim.lsp.enable({
  "rust_analyzer",
  "tinymist",
  "bashls",
  "pyright",
  "lua_ls",
  "clangd",
  "ts_ls",
  "eslint",
})

--- Formatter Setup ---
require("conform").setup({
  formatters_by_ft = {
    python = { "black" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
    sh = { "beautysh" },
    bash = { "beautysh" },
    zsh = { "beautysh" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
})

--- Telescope Setup ---
require "telescope".setup({
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

require("actions-preview").setup {
  backend = { "telescope" },
  extensions = { "env" },
  telescope = vim.tbl_extend(
    "force",
    require("telescope.themes").get_dropdown(), {}
  )
}

require "telescope".load_extension("ui-select")
local builtin = require("telescope.builtin")

--- Auto setup ---
require "nvim-autopairs".setup({
  check_ts = true
})

require "nvim-ts-autotag".setup()

--- Typst
require 'typst-preview'.setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function()
    vim.opt_local.wrapmargin = 10
    vim.opt_local.formatoptions:append('t')
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
  end,
  desc = "Typst filetype commands"
})

--- ToggleTerm (floating terminal) ---
require("toggleterm").setup({
  size = 15,
  open_mapping = nil,
  shade_terminals = true,
  start_in_insert = true,
  persist_size = true,
  direction = "horizontal",
  float_opts = {
    border = "rounded",
    width = 20,
    height = 5,
  },
})

local Terminal = require "toggleterm.terminal".Terminal

local tmx_term = Terminal:new({
  cmd = "zsh -i -c tmx",
  direction = "float",
  close_on_exit = true,
})

--- Vim  Keybindings ---
map('n', '<leader>w', ':update<CR>', { desc = 'Save' })
map({ 'n', 'v', 'x' }, '<leader>r', ":restart<CR>", { desc = "Restart vim" })

map('', '<leader>y', '"+y', { desc = 'Copy to clipboard' })
map('', '<leader>d', '"+d', { desc = 'Cut to clipboard' })

map('n', '<leader>a', 'ggVG$<cr>', { desc = 'Select all text in the file' })

map('n', '<CR>', '@="m`o<C-V><Esc>``"<CR>', { desc = 'Newline below' })

map('n', '<leader>e', ':Oil<CR>', { desc = 'Open file explorer' })

map('n', '<leader>ie', 'gg=G<C-o>zz', { desc = 'Indent whole file' })

map({ 'n', 'v', 'x' }, '<leader>vi', '<Cmd>edit $MYVIMRC<CR>', { desc = 'Edit ' .. vim.fn.expand('$MYVIMRC') })
map('n', '<leader>so', ':source $MYVIMRC<CR>', { desc = 'Source Neovim config' })

map('n', '<leader>nh', ':nohlsearch<CR>', { desc = 'Unhighlight current search' })

map('n', '<leader>bb', function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = 'Check current line error' })

map('n', '<leader>lf', function() require("conform").format() end, { desc = 'Format buffer' })

--- Terminal Keybinds ---
map("n", "<leader>0", function()
  tmx_term:toggle()
end, { desc = "Switch tmux sessions" })
map("n", "<leader>9", ":ToggleTerm<CR>")

--- Typst Keybinds ---
map("n", "<leader>p", ":TypstPreview<CR>")
map("n", "<leader>tp", ":write<CR> :!typst compile '%:p' --format=pdf<CR>")
map("n", "<leader>c", "1z=")

--- Telescope Keybinds ---
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fw', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>ch', builtin.command_history, { desc = 'Command history' })
map('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
map('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
map('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })
