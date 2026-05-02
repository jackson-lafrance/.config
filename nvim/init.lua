local vim = vim
local opt = vim.opt
vim.g.mapleader = " "

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
opt.winborder = "rounded"

opt.guicursor = ""
opt.mouse = ""

opt.swapfile = false
opt.undofile = true

vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/stevearc/oil.nvim" },
})

require("plugins")
require("remap")
