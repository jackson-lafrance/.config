local vim = vim

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

vim.g.mapleader = " "

vim.cmd("packadd plenary.nvim")
vim.cmd("packadd telescope.nvim")
vim.cmd("packadd telescope-ui-select.nvim")
vim.cmd("packadd telescope-env.nvim")
vim.cmd("packadd nvim-web-devicons")
vim.cmd("packadd lualine.nvim")
vim.cmd("packadd oil.nvim")
vim.cmd("packadd nvim-lspconfig")
vim.cmd("packadd mason.nvim")
vim.cmd("packadd nvim-treesitter")
vim.cmd("packadd vague.nvim")

local builtin = require("telescope.builtin")
local function git_files() builtin.find_files({ no_ignore = true }) end

local map = vim.keymap.set
map('n', '<leader>o', ':update<CR> :source<CR>')
map('n', '<leader>q', ':quit<CR>')
map('n', '<leader>w', ':write<CR>')
map('n', '<leader>lf', vim.lsp.buf.format)
map('n', '<leader>e', ':Oil<CR>')
map({ 'n', 'v', 'x' }, '<leader>y', '"+y<CR>')
map({ 'n', 'v', 'x' }, '<leader>d', '"+d<CR>')
map({ "n" }, "<leader>se", "<cmd>Telescope env<cr>")
map({ "n" }, "<leader>f", builtin.find_files, { desc = "Telescope live grep" })
map({ "n" }, "<leader>g", builtin.live_grep)
map({ "n" }, "<leader>sg", git_files)
map({ "n" }, "<leader>ss", builtin.current_buffer_fuzzy_find)
map("n", "<leader>o", function()
	vim.diagnostic.open_float(nil, { focus = false })
end, { desc = "Show diagnostics for current line" })
vim.keymap.set("n", "<leader>c", function()
	local file = vim.fn.expand("%:p")            -- full path to file
	local output = vim.fn.expand("%:r")          -- path without extension
	local file_escaped = vim.fn.shellescape(file) -- escape spaces/quotes
	local out_escaped = vim.fn.shellescape(output)

	vim.cmd("!clang++ -std=c++17 -O2 -o " .. out_escaped .. " " .. file_escaped)
end, { desc = "Compile current C++ file" })

vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim",          branch = "0.1.8" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/LinArcX/telescope-env.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
})

vim.lsp.config.ruby_lsp = {
  cmd = { "/Users/jacksonlafranceshopify/.gem/ruby/dev-stable/bin/ruby-lsp" },
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
}

vim.lsp.enable({ "lua_ls", "pyright", "ts_ls", "clangd", "ruby_lsp" })

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

require "oil".setup()
require "mason".setup()

local telescope = require("telescope")

telescope.setup({
	defaults = {
		preview = { treesitter = true },
		color_devicons = true,
		sorting_strategy = "ascending",

		-- no invalid keys, avoids recursive config load
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

-- load ui-select safely (no crash if not installed)
pcall(function()
	telescope.load_extension("ui-select")
end)

-- actions-preview with telescope backend
pcall(function()
	require("actions-preview").setup({
		backend = { "telescope" },
		telescope = require("telescope.themes").get_dropdown(),
	})
end)

require('lualine').setup {
	options = {
		icons_enabled = true,
		theme = 'vague',
		component_separators = { left = '', right = '' },
		section_separators = { left = '', right = '' },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
			refresh_time = 16, -- ~60fps
			events = {
				'WinEnter',
				'BufEnter',
				'BufWritePost',
				'SessionLoadPost',
				'FileChangedShellPost',
				'VimResized',
				'Filetype',
				'CursorMoved',
				'CursorMovedI',
				'ModeChanged',
			},
		}
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diff', 'diagnostics' },
		lualine_c = { 'filename' },
		lualine_x = { 'encoding', 'fileformat', 'filetype' },
		lualine_y = { 'progress' },
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
	inactive_winbar = {},
	extensions = {}
}

vim.cmd([[set mouse=]])
vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
vim.cmd [[set completeopt+=menuone,noselect,popup]]
