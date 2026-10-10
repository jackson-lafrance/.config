local opt = vim.opt
vim.g.mapleader = " "

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

opt.ignorecase = true
opt.smartcase = true

opt.wrap = false

-- Quickfix and location-list entries can be long; wrap them only in those windows.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.termguicolors = true
opt.winborder = "rounded"

opt.guicursor = ""
opt.mouse = "a"

opt.swapfile = false
opt.undofile = true

-- Diffs: side by side, aligned by line content, better hunk boundaries.
opt.diffopt:append({ "vertical", "linematch:60", "algorithm:histogram" })

require("plugins")
require("remap")
require("autocomplete")
