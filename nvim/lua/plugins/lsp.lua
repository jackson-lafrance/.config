local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup({
  PATH = "append",
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls",
  },
  automatic_enable = {
    exclude = { "ruby_lsp" },
  },
})

local function split_command(command)
  return vim.split(command, "%s+", { trimempty = true })
end

local function ruby_lsp_cmd()
  if vim.env.RUBY_LSP_CMD and vim.env.RUBY_LSP_CMD ~= "" then
    return split_command(vim.env.RUBY_LSP_CMD)
  end

  if vim.fn.executable("ruby-lsp") == 1 then
    return { "ruby-lsp" }
  end

  if vim.fn.executable("bundle") == 1 then
    return { "bundle", "exec", "ruby-lsp" }
  end

  return { "ruby-lsp" }
end

vim.lsp.config("ruby_lsp", {
  cmd = ruby_lsp_cmd(),
})
vim.lsp.enable("ruby_lsp")

map("n", "<leader>m", ":Mason<CR>", { desc = "Opens mason" })
