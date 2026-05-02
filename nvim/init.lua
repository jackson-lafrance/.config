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

require("plugins")
require("remap")
