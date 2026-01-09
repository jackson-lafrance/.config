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
opt.autoindent = true

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
map({ 'v', 'x' }, '<leader>sw', 'y :/<C-r>"', { desc = 'Search for the current selected text' })

map({ 'n' }, '<leader>1', ':!', { desc = 'Write a terminal command' })

map({ 'n' }, '<leader>bb', function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = 'Check current line error' })

--- Adding Plugins ---
vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
})

--- Theme ---
vim.cmd.colorscheme("rose-pine-main")

--- Treesitter ---
require "nvim-treesitter".install { "lua", "typescript", "python", "javascript", "cpp", "c", "java", "html", "css", "typescript", "tsx" }
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

--- LSP and Completion ---
local capabilities = require('cmp_nvim_lsp').default_capabilities()
vim.lsp.config('lua_ls', {
  capabilities = capabilities
})
vim.lsp.enable('lua_ls')

-- copied the ruby part from the internet
-- it basically checks if there is a rubocop.yml in the current repro and otherwise it just uses my global one
map({ 'n' }, '<leader>lf', function()
  if vim.bo.filetype == "ruby" then
    local file = vim.fn.expand("%:p")
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

    local config = get_rubocop_config()
    vim.cmd("write")
    vim.cmd(" !rubocop --config " .. vim.fn.shellescape(config) .. " " .. vim.fn.shellescape(file))
    vim.cmd("edit!")
  else
    vim.lsp.buf.format()
  end
end, { desc = 'Format current buffer' })

local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

--- Ruby LSP Setup --
vim.lsp.config('ruby-lsp', {
  cmd = { 'ruby-lsp' },
  capabilities = capabilities,
  filetypes = { 'ruby' },
  root_dir = vim.fs.root(0, { 'Gemfile', '.git' }),
  init_options = {
    formatter = 'standard',
    linters = { 'standard' },
    experimentalFeaturesEnabled = true,
  },
})

vim.lsp.enable('ruby-lsp')

vim.lsp.config('sorbet', {
  cmd = { "srb", "tc", "--lsp" },
  capabilities = capabilities,
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

vim.lsp.enable('sorbet')

--- Typescript LSP ---
vim.lsp.config('typescript-language-server',
  {
    cmd = { 'typescript-language-server', '--stdio' },
    capabilities = capabilities,
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
  })

vim.lsp.enable('typescript-language-server')

--- Autopairs ---
require "nvim-autopairs".setup({
  check_ts = true
})
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "env")

require 'cmp'.event:on('confirm_done',
  require 'nvim-autopairs.completion.cmp'.on_confirm_done())

require 'nvim-ts-autotag'.setup()

--- Lualine
require 'lualine'.setup({
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {},
    lualine_x = { 'filename', 'filetype' },
    lualine_y = {
      {
        'lsp_status',
        icon = '❤',
        symbols = {
          spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
          done = '☺',
          separator = ' ',
        },
        ignore_lsp = {},
        show_name = true,
      }
    },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  extensions = {}
})
