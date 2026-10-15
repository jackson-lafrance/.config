local opt = vim.opt
vim.g.mapleader = " "

opt.number = true
opt.relativenumber = true
-- Keep Git signs visible beside diagnostics without shifting the text.
opt.signcolumn = "yes:2"

opt.ignorecase = true
opt.smartcase = true

opt.wrap = false
opt.scrolloff = 5

opt.splitbelow = true
opt.splitright = true
opt.confirm = true
opt.inccommand = "split"

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.termguicolors = true
opt.winborder = "rounded"

opt.guicursor = ""
opt.mouse = "a"

opt.undofile = true

opt.diffopt:append({ "vertical", "linematch:60", "algorithm:histogram" })

local diagnostics_suppressed = {}
local function diagnostics_visible(_, bufnr)
  return not diagnostics_suppressed[bufnr]
end

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  signs = diagnostics_visible,
  underline = diagnostics_visible,
  virtual_text = false,
  virtual_lines = function(_, bufnr)
    return diagnostics_suppressed[bufnr] and false or { current_line = true }
  end,
  float = {
    border = "rounded",
    source = true,
  },
  jump = {
    float = true,
  },
})

local diagnostics_group = vim.api.nvim_create_augroup("my.diagnostics", {})
vim.api.nvim_create_autocmd("InsertEnter", {
  group = diagnostics_group,
  callback = function(args)
    diagnostics_suppressed[args.buf] = true
    vim.diagnostic.enable(false, { bufnr = args.buf })
    vim.diagnostic.hide(nil, args.buf)
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = diagnostics_group,
  callback = function(args)
    diagnostics_suppressed[args.buf] = nil
    vim.diagnostic.enable(true, { bufnr = args.buf })
  end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
  group = diagnostics_group,
  callback = function(args)
    diagnostics_suppressed[args.buf] = nil
  end,
})

require("plugins")
require("remap")
