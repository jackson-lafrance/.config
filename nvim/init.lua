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
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },

  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/aznhe21/actions-preview.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },

  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },

  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/saadparwaiz1/cmp_luasnip" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },

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
vim.cmd("packadd! nvim-lspconfig") -- so lsp/*.lua configs (cmd, filetypes) are on rtp
require "mason".setup()
require "mason-lspconfig".setup({
  automatic_installation = { exclude = { "ruby_lsp" } },
  ensure_installed = {
    "bashls",
    "clangd",
    "eslint",
    "lua_ls",
    "pyright",
    "rust_analyzer",
    "sqlls",
    "tinymist",
    "ts_ls",
  },
  handlers = {
    function(server_name)
      require("lspconfig")[server_name].setup({})
    end,
  },
})

-- Register config for each server so vim.lsp.enable() can find them (required in Neovim 0.11+).
-- nvim-lspconfig provides cmd/filetypes via lsp/name.lua; we only need to register so enable() works.
local lsp_servers = {
  "rust_analyzer",
  "tinymist",
  "bashls",
  "pyright",
  "lua_ls",
  "clangd",
  "ts_ls",
  "eslint",
  "ruby_lsp",
  "sqlls",
}
for _, name in ipairs(lsp_servers) do
  vim.lsp.config(name, {})
end

-- ruby_lsp: filetypes, root, and disable semantic tokens to avoid NO_RESULT_CALLBACK_FOUND errors
vim.lsp.config("ruby_lsp", {
  cmd = { vim.fn.expand("~/.local/bin/ruby-lsp-wrapper") },
  filetypes = { "ruby", "eruby", "erb" },
  root_markers = { "Gemfile", ".git" },
  capabilities = {
    textDocument = { semanticTokens = vim.NIL },
    workspace = { semanticTokens = vim.NIL },
  },
})

vim.lsp.enable(lsp_servers)

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
    ruby = { "rubocop" },
    sql = { "sql_formatter" },
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

--- LuaSnip ---
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

--- Cmp setup ---
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  completion = {
    preselect = cmp.PreselectMode.None,
  },

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  mapping = cmp.mapping.preset.insert({
    ['<Down>'] = cmp.mapping(function(fallback) fallback() end, { 'i', 's' }),
    ['<Up>'] = cmp.mapping(function(fallback) fallback() end, { 'i', 's' }),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        local entry = cmp.get_selected_entry()
        if entry then
          cmp.confirm({ select = true })
        else
          fallback()
        end
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),

  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        buffer = "[Buf]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end,
  },
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

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

-- Terminal: Escape to normal mode (scroll with j/k), mouse to scroll, q to close buffer
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.mouse = "a"
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = 0, desc = "Terminal: normal mode (scroll with j/k)" })
    vim.keymap.set("n", "q", "<Cmd>bdelete!<CR>", { buffer = 0, desc = "Close terminal buffer" })
  end,
  desc = "Terminal: scroll + close",
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

--- Rails: project root + run command in terminal (must be defined before keymaps that use them) ---
vim.cmd("silent! packadd vim-rails")

local function rails_root()
  local br = vim.b.rails_root
  if br and br ~= "" then
    return br
  end
  local dir = vim.fn.expand("%:p:h")
  local tried = {}
  for _ = 1, 30 do
    if dir == "" or dir == "." or tried[dir] then
      break
    end
    tried[dir] = true
    if vim.fn.filereadable(dir .. "/Gemfile") == 1 then
      return dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return ""
end

local function is_rspec_project(root)
  return vim.fn.isdirectory(root .. "/spec") == 1
end

local function run_in_rails_terminal(cmd)
  local root = rails_root()
  if root == "" then
    vim.notify("Not in a Rails/Ruby project (no Gemfile found)", vim.log.levels.WARN)
    return
  end
  local Terminal = require("toggleterm.terminal").Terminal
  local full_cmd = "cd " .. vim.fn.shellescape(root) .. " && (" .. cmd .. "); exec $SHELL -i"
  local term = Terminal:new({
    cmd = full_cmd,
    direction = "horizontal",
    close_on_exit = false,
  })
  term:toggle()
end

map("n", "<leader>lf", function()
  local ft = vim.bo.filetype
  if ft == "ruby" or ft == "erb" then
    local root = rails_root()
    if root == "" then
      vim.notify("Not in a Rails/Ruby project (no Gemfile found)", vim.log.levels.WARN)
      return
    end
    local file = vim.fn.shellescape(vim.fn.expand("%:p"))
    run_in_rails_terminal("bundle exec rubocop -a " .. file)
  else
    require("conform").format()
  end
end, { desc = "Format buffer (RuboCop in terminal for Ruby/ERB)" })

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
map('n', '<leader>fc', builtin.command_history, { desc = 'Command history' })
map('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
map('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
map('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })

--- Rails test keybinds (in test/spec files) ---
map("n", "<leader>tf", function()
  local root = rails_root()
  if root == "" then
    vim.notify("Not in a Rails project", vim.log.levels.WARN)
    return
  end
  local file = vim.fn.expand("%:p")
  if not file:match("_test%.rb$") and not file:match("_spec%.rb$") then
    vim.notify("Not a test file (expect _test.rb or _spec.rb)", vim.log.levels.WARN)
    return
  end
  local cmd = file:match("_spec%.rb$") and "bundle exec rspec " .. vim.fn.shellescape(file)
    or "bundle exec rails test " .. vim.fn.shellescape(file)
  run_in_rails_terminal(cmd)
end, { desc = "Rails: run current test file" })

map("n", "<leader>ts", function()
  local root = rails_root()
  if root == "" then
    vim.notify("Not in a Rails project", vim.log.levels.WARN)
    return
  end
  local cmd = is_rspec_project(root) and "bundle exec rspec" or "bundle exec rails test"
  run_in_rails_terminal(cmd)
end, { desc = "Rails: run whole test suite" })
