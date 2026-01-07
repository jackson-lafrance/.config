local vim = vim

vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim",          branch = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/LinArcX/telescope-env.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
})

-- Options
vim.o.winborder = "rounded"
vim.o.tabstop = 2
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.shiftwidth = 2
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.ignorecase = true
vim.o.undofile = true
vim.o.autoindent = true
vim.o.mouse = ""
vim.o.completeopt = "menu,menuone,noselect"

vim.g.mapleader = " "

-- Load plugins
vim.cmd("packadd plenary.nvim")
vim.cmd("packadd telescope.nvim")
vim.cmd("packadd telescope-ui-select.nvim")
vim.cmd("packadd telescope-env.nvim")
vim.cmd("packadd nvim-web-devicons")
vim.cmd("packadd lualine.nvim")
vim.cmd("packadd oil.nvim")
vim.cmd("packadd nvim-lspconfig")
vim.cmd("packadd mason.nvim")
vim.cmd("packadd mason-lspconfig.nvim")
vim.cmd("packadd nvim-treesitter")
vim.cmd("packadd vague.nvim")
vim.cmd("packadd nvim-cmp")
vim.cmd("packadd cmp-nvim-lsp")
vim.cmd("packadd cmp-buffer")
vim.cmd("packadd cmp-path")

-- Keymaps
local builtin = require("telescope.builtin")
local map = vim.keymap.set

map("n", "<leader>q", ":quit<CR>")
map("n", "<leader>w", ":write<CR>")
map("n", "<leader>e", ":Oil<CR>")
map({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
map({ "n", "v", "x" }, "<leader>d", '"+d<CR>')
map("n", "<leader>f", builtin.find_files, { desc = "Find files" })
map("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>sg", function() builtin.find_files({ no_ignore = true }) end, { desc = "Find files (no ignore)" })
map("n", "<leader>ss", builtin.current_buffer_fuzzy_find, { desc = "Buffer search" })
map("n", "<leader>se", "<cmd>Telescope env<cr>", { desc = "Environment variables" })

map("n", "<leader>o", function()
	vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Show diagnostics" })

map("n", "<leader>lf", function()
	if vim.bo.filetype == "ruby" then
		local file = vim.fn.expand("%:p")
		vim.cmd("silent !rubocop -a --config ~/.rubocop.yml " .. vim.fn.shellescape(file))
		vim.cmd("edit!")
	else
		vim.lsp.buf.format()
	end
end, { desc = "Format file" })

map("n", "<leader>c", function()
	local file = vim.fn.expand("%:p")
	local output = vim.fn.expand("%:r")
	vim.cmd("!clang++ -std=c++17 -O2 -o " .. vim.fn.shellescape(output) .. " " .. vim.fn.shellescape(file))
end, { desc = "Compile C++ file" })

-- LSP keymaps (set on attach)
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- Mason setup (DO NOT add ruby_lsp here - use global installation)
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"pyright",
		"ts_ls",
		"clangd",
		-- ruby_lsp excluded - using global gem
	},
})

-- Load the sources explicitly
require("cmp_nvim_lsp")

local cmp = require("cmp")

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "buffer" },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

lspconfig.ruby_lsp.setup({ capabilities = capabilities })
lspconfig.ts_ls.setup({ capabilities = capabilities })
lspconfig.lua_ls.setup({ capabilities = capabilities })
lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.clangd.setup({ capabilities = capabilities })

-- After requiring cmp, add this BEFORE vim.lsp.enable():
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Configure each LSP with capabilities
local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({ capabilities = capabilities })
lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.ts_ls.setup({ capabilities = capabilities })
lspconfig.clangd.setup({ capabilities = capabilities })
lspconfig.ruby_lsp.setup({ capabilities = capabilities })

-- Oil
require("oil").setup()

-- Telescope
local telescope = require("telescope")
telescope.setup({
	defaults = {
		preview = { treesitter = true },
		color_devicons = true,
		sorting_strategy = "ascending",
		path_display = { "smart" },
		borderchars = { "", "", "", "", "", "", "", "" },
		layout_config = {
			height = 0.95,
			width = 0.95,
			prompt_position = "top",
			preview_cutoff = 40,
		},
	},
})
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "env")

-- Lualine
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "vague",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		globalstatus = false,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
})

-- Colorscheme
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
