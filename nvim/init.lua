--- Local Variables ---
local vim = vim
local opt = vim.opt
local map = vim.keymap.set

--- Vim Settings ---
vim.cmd('hi statusline guibg=NONE')

opt.number = true
opt.relativenumber = true

opt.ignorecase = true
opt.smartcase = true

opt.wrap = false

opt.signcolumn = "yes"

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.termguicolors = true
opt.winborder = 'rounded'

--- Vim Bonus Keybindings ---
vim.g.mapleader = ' '
map('n', '<leader>w', ':update<CR>', { desc = 'Save' })
map('n', '<leader>so', ':update<CR> :so<CR>', { desc = 'Load changes from current file' })
map('n', '<leader>q', ':update<CR> :quit<CR>', { desc = 'Save and quit'})

map('', '<leader>y', '"+y', { desc = 'Copy to clipboard' })
map('', '<leader>d', '"+d', { desc = 'Cut to clipboard' })

map('n', '<leader>a', ':keepjumps normal! ggVG$<cr>', { desc = 'Select all text in the file' })

map('n', '<CR>', '@="m`o<C-V><Esc>``"<CR>', { desc = 'Newline below' })
map('n', '<S-CR>', '@="m`O<C-V><ESC>``"<CR>', { desc = 'Newline above' })

map('n', '<leader>e', ':update<CR>:Oil<CR>', { desc = 'Open file explorer' })
map('n', '<leader>b', '<C-o>', { desc = 'Go back to previous jump' })
map('n', '<leader>ie', 'gg=G<C-o>zz', { desc = 'Indent whole file'})

map({ 'n', 'v', 'x' }, '<leader>vi', '<Cmd>edit $MYVIMRC<CR>', { desc = 'Edit ' .. vim.fn.expand('$MYVIMRC') })
map('n', '<leader>sv', '<Cmd>source $MYVIMRC<CR>', { desc = 'Source Neovim config' })

map('n', '<leader>nh', ':nohlsearch<CR>', { desc = 'Unhighlight current search' })
map({ 'v', 'x' }, '<leader>sw', 'y :/<C-r>"', { desc = 'Search for the current selected text' })

map('n', '<leader>1', ':!', { desc = 'Write a terminal command' })

map('n', '<leader>bb', function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = 'Check current line error' })

map('n', '<leader>zm', ':ZenMode<CR>')

--- Adding Plugins ---
vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },
  { src = "https://github.com/chomosuke/typst-preview.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/folke/zen-mode.nvim"},
  { src = "https://github.com/ThePrimeagen/vim-be-good"},
  { src = "https://github.com/akinsho/toggleterm.nvim" }
})

require("luasnip.loaders.from_vscode").lazy_load()

--- Theme ---
vim.cmd.colorscheme("rose-pine-main")

--- Treesitter ---
require "nvim-treesitter".install { "lua", "typescript", "python", "javascript", "cpp", "c", "java", "html", "css", "typst", "tsx", "ruby", "vim", "embedded_template" }

require "nvim-treesitter".setup({
  highlight = { enable = true },
  indent = { enable = true },
})

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
    borderchars = { "", "", "", "", "", "", "", "" },
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
map('n', '<leader>f', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>lg', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>of', builtin.oldfiles, { desc = 'Prev file viewer' })
map('n', '<leader>cs', builtin.commands, { desc = 'Command viewer' })
map('n', '<leader>ch', builtin.command_history, { desc = 'Command history' })
map('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
map('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
map('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })

--- LSP and Completion ---
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local function setup_lsp(name, config)
  vim.lsp.config(name, vim.tbl_extend('force', { capabilities = capabilities }, config))
  vim.lsp.enable(name)
end

setup_lsp('lua_ls', {})

-- copied the ruby part from the internet
-- it basically checks if there is a rubocop.yml in the current repro and otherwise it just uses my global one
local function get_rubocop_config()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 and git_root then
    local project_config = git_root .. "/.rubocop.yml"
    if vim.fn.filereadable(project_config) == 1 then
      return project_config
    end
  end
  return vim.fn.expand("~/.rubocop.yml")
end

local function format_ruby_with_rubocop()
  local file = vim.fn.expand("%:p")
  local config = get_rubocop_config()
  vim.fn.system("rubocop -a --config " .. vim.fn.shellescape(config) .. " " .. vim.fn.shellescape(file))
end

-- Format on save for Ruby files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.rb",
  callback = function()
    format_ruby_with_rubocop()
    vim.cmd("edit!")
  end,
  desc = "Format Ruby files with Rubocop on save"
})

map('n', '<leader>lf', function()
  if vim.bo.filetype == "ruby" then
    vim.cmd("write")
    format_ruby_with_rubocop()
    vim.cmd("edit!")
  else
    vim.lsp.buf.format()
  end
end, { desc = 'Format current buffer' })

--- Ruby LSP Setup --
setup_lsp('ruby-lsp', {
  cmd = { 'ruby-lsp' },
  filetypes = { 'ruby', 'eruby' },
  root_dir = vim.fs.root(0, { 'Gemfile', '.git' }),
  init_options = {
    formatter = 'standard',
    linters = { 'standard' },
    experimentalFeaturesEnabled = true,
  },
})

setup_lsp('sorbet', {
  cmd = { "srb", "tc", "--lsp" },
  filetypes = { 'ruby' },
  root_dir = function(fname)
    local util = require('lspconfig.util')
    local project_root = util.root_pattern("sorbet/config")(fname)
    if project_root then
      return project_root
    end
    return vim.fn.expand("~/.config/sorbet-default")
  end,
})

--- Typescript LSP ---
vim.filetype.add({
  extension = {
    tsx = "typescriptreact",
  },
})

setup_lsp('typescript-language-server', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
})

--- Autopairs ---
require "nvim-autopairs".setup({
  check_ts = true
})

require 'nvim-ts-autotag'.setup()

--- Typst
require 'typst-preview'.setup()

setup_lsp('tinymist', {
  cmd = { 'tinymist', 'lsp' },
  filetypes = { 'typst' },
  root_markers = { '.git' },
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onType",
    semanticTokens = "disable",
  },
})

map("n", "<leader>p", ":TypstPreview<CR>")
map("n", "<leader>tp", ":write<CR> :!typst compile '%:p' --format=pdf<CR>")
map("n", "<leader>c", "1z=")

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

--- Oil
require "oil".setup()

--- C/C++/Python
setup_lsp('pyright', {})
setup_lsp('clangd', {})


--- Completion
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),

  sources = {
    { name = 'luasnip' },
    { name = 'nvim_lsp'},
    { name = 'buffer' },
  },
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

local Terminal = require("toggleterm.terminal").Terminal
local tmx_term = Terminal:new({
  cmd = "zsh -i -c tmx",
  direction = "float",
  close_on_exit = true,
})

map("n", "<leader>0", function()
  tmx_term:toggle()
end, { desc = "Switch tmux sessions" })

