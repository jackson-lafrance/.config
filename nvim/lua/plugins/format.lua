local vim = vim
local map = vim.keymap.set

vim.pack.add({
  {
    src = "https://github.com/stevearc/conform.nvim",
    version = "v9.1.0",
  },
})

local conform = require("conform")
local prettier = { "prettierd", "prettier", stop_after_first = true }

conform.setup({
  formatters_by_ft = {
    css = prettier,
    graphql = prettier,
    html = prettier,
    javascript = prettier,
    javascriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    less = prettier,
    markdown = prettier,
    scss = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    vue = prettier,
    yaml = prettier,
  },
  default_format_opts = {
    -- Web files use Prettier. Every other filetype uses one attached LSP,
    -- such as clangd, lua_ls, or the project-aware Ruby LSP.
    lsp_format = "fallback",
    timeout_ms = 15000,
  },
  notify_on_error = true,
  notify_no_formatters = true,
})

map({ "n", "x" }, "<leader>lf", function()
  conform.format()
end, { desc = "Format buffer or selection" })
