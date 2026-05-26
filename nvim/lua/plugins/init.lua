local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/rose-pine/neovim",
  "https://github.com/nvim-tree/nvim-web-devicons",

  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/nvim-mini/mini.diff",
  "https://github.com/stevearc/conform.nvim",
})

require("rose-pine").setup({
  styles = {
    transparency = true,
  },
})
vim.cmd("colorscheme rose-pine-main")

require("nvim-treesitter").setup()

require("oil").setup()
map("n", "<leader>e", ":Oil<CR>", { desc = "Open file explorer" })

require 'mini.diff'.setup()
map('n', '<leader>to', require('mini.diff').toggle_overlay, { desc = 'Toggle MiniDiff overlay' })

require("plugins.lsp")
require("plugins.conform")
require("plugins.telescope")
require("plugins.pairs")
