local vim = vim
local map = vim.keymap.set

local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    lua = { "stylua" },
    ruby = { "rubocop" },
  },
  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 3000,
  },
})

map("n", "<leader>lf", function()
  conform.format()
end, { desc = "Format current buffer" })
