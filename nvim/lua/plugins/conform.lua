local vim = vim
local map = vim.keymap.set

local conform = require("conform")

local function find_gemfile(ctx)
  return vim.fs.find("Gemfile", { path = ctx.dirname, upward = true })[1]
end

conform.setup({
  formatters_by_ft = {
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    lua = { "stylua" },
    ruby = { "bundle_rubocop", "rubocop", stop_after_first = true },
  },
  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 3000,
  },
  formatters = {
    bundle_rubocop = {
      command = "bundle",
      args = {
        "exec",
        "rubocop",
        "--server",
        "-a",
        "-f",
        "quiet",
        "--stderr",
        "--stdin",
        "$FILENAME",
      },
      cwd = function(_, ctx)
        local gemfile = find_gemfile(ctx)
        return gemfile and vim.fs.dirname(gemfile) or nil
      end,
      condition = function(_, ctx)
        return vim.fn.executable("bundle") == 1 and find_gemfile(ctx) ~= nil
      end,
      exit_codes = { 0, 1 },
    },
  },
})

map("n", "<leader>lf", function()
  conform.format()
end, { desc = "Format current buffer" })
