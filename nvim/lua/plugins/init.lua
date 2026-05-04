local vim = vim
local map = vim.keymap.set

vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/stevearc/oil.nvim" },
})

require("rose-pine").setup({
  styles = {
    transparency = true,
  },
})
vim.cmd("colorscheme rose-pine-main")

require("oil").setup()
map("n", "<leader>e", ":Oil<CR>", { desc = "Open file explorer" })

require("nvim-treesitter").setup()
require("plugins.lsp")
require("plugins.telescope")
require("plugins.pairs")
