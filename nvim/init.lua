--- Local Variables ---
local vim = vim
local opt = vim.opt
local map = vim.keymap.set
vim.g.mapleader = ' '
--- Vim Commands ---
vim.cmd('hi statusline guibg=NONE')
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
opt.mouse = ""

opt.swapfile = false
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
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/onsails/lspkind-nvim" },

  { src = "https://github.com/chomosuke/typst-preview.nvim" },

  { src = "https://github.com/akinsho/toggleterm.nvim" },
  { src = "https://github.com/chentoast/marks.nvim" },
  { src = "https://github.com/nvim-mini/mini.diff" },

  { src = "https://github.com/tpope/vim-rails" },
})

--- Theme ---
vim.cmd("colorscheme rose-pine-main")

--- Theme, Ty Treesitter and Oil ---
require "nvim-treesitter".setup({
  auto_install = true
})

require 'marks'.setup()
require 'mini.diff'.setup()
require "oil".setup()

--- LSP Setup ---
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lsp_servers = {
  "rust_analyzer", "tinymist", "bashls", "pyright", "lua_ls",
  "clangd", "ts_ls", "eslint", "ruby_lsp", "sqlls",
}

require "mason".setup()
require "mason-lspconfig".setup({
  automatic_installation = { exclude = { "ruby_lsp" } },
  ensure_installed = vim.tbl_filter(function(s) return s ~= "ruby_lsp" end, lsp_servers),
})

vim.lsp.config('*', {
  capabilities = capabilities,
})

-- ruby_lsp: filetypes, root, and disable semantic tokens to avoid NO_RESULT_CALLBACK_FOUND errors
vim.lsp.config("ruby_lsp", {
  cmd = { vim.fn.expand("~/.local/bin/ruby-lsp-wrapper") },
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
  init_options = {
    formatter = "auto",
    pendingMigrationsCheck = false,
  },
  capabilities = vim.tbl_deep_extend("force", capabilities, {
    textDocument = { semanticTokens = vim.NIL },
    workspace = { semanticTokens = vim.NIL },
  }),
})

vim.lsp.enable(lsp_servers)

--- Formatter Setup ---
require("conform").setup({
  formatters = {
    erb_format = {
      command = "erb-format",
      args = { "--stdin-filename", "$FILENAME" },
      stdin = true,
      env = {
        GEM_PATH = vim.fn.expand("~/.local/share/nvim/mason/packages/erb-formatter"),
        GEM_HOME = vim.fn.expand("~/.local/share/nvim/mason/packages/erb-formatter"),
      },
    },
  },
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
    eruby = { "erb_format" },
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

--- LuaSnip (kept for LSP snippet expansion only) ---
local luasnip = require("luasnip")

-- Clear snippet jump state when leaving insert mode so Tab doesn't teleport back
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
        and not luasnip.session.jump_active then
      luasnip.unlink_current()
    end
  end,
})

--- Cmp setup ---
local cmp = require("cmp")
local lspkind = require("lspkind")
local compare = cmp.config.compare

cmp.setup({
  preselect = cmp.PreselectMode.None,

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  completion = {
    completeopt = "menu,menuone,noselect",
    keyword_length = 1,
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
          cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })
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
    { name = 'nvim_lsp',                priority = 1000, max_item_count = 30 },
    { name = 'nvim_lsp_signature_help', priority = 900 },
    { name = 'luasnip',                 priority = 750,  keyword_length = 2 },
    { name = 'path',                    priority = 500 },
  }, {
    { name = 'buffer', keyword_length = 3, priority = 100, max_item_count = 5 },
  }),

  sorting = {
    priority_weight = 2,
    comparators = {
      compare.offset,
      compare.exact,
      compare.score,
      compare.recently_used,
      compare.locality,
      compare.kind,
      compare.sort_text,
      compare.length,
      compare.order,
    },
  },

  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = "...",
      menu = {
        nvim_lsp = "[LSP]",
        luasnip = "[Snip]",
        buffer = "[Buf]",
        path = "[Path]",
      },
    }),
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
map('', '<leader>pc', '"+p', { desc = 'Paste clipboard' })
map('', '<leader>pp', '"0p', { desc = 'Paste last yanked' })
map('', '<leader>pd', '"1p', { desc = 'Paste last deleted' })

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

map("n", "<leader>lf", function()
  if vim.bo.filetype == "ruby" or vim.bo.filetype == "erb" then
    local gemfile = vim.fn.findfile("Gemfile", ".;")
    local root = vim.fn.fnamemodify(gemfile, ":p:h")
    vim.cmd("update")
    vim.cmd("!cd " .. vim.fn.shellescape(root) .. " && bundle exec rubocop -a " .. vim.fn.expand("%:p"))
    vim.cmd("edit")
  else
    require("conform").format()
  end
end, { desc = "Format buffer" })

--- Terminal Keybinds ---
map("n", "<leader>0", function()
  tmx_term:toggle()
end, { desc = "Switch tmux sessions" })
map("n", "<leader>9", ":ToggleTerm<CR>")

--- Typst Keybinds ---
map("n", "<leader>tp", ":TypstPreview<CR>")
map("n", "<leader>tc", ":write<CR> :!typst compile '%:p' --format=pdf<CR>")
map("n", "<leader>c", "1z=")

--- Telescope Keybinds ---
map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fw', builtin.live_grep, { desc = 'Telescope live grep' })
map('n', '<leader>fc', builtin.command_history, { desc = 'Command history' })
map('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
map('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
map('n', '<leader>gc', builtin.git_commits, { desc = 'Git commits' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })

map('n', '<leader>to', require('mini.diff').toggle_overlay, { desc = 'Toggle MiniDiff overlay' })

--- Rails test keybinds (in test/spec files) ---
local function run_test(cmd)
  vim.cmd("botright 15split | term " .. cmd)
end

map("n", "<leader>tf", function() run_test("dev test " .. vim.fn.expand("%:.")) end)
map("n", "<leader>tl", function() run_test("dev test " .. vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")) end)
map("n", "<leader>ts", function() run_test("dev test") end)
