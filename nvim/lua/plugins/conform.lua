local vim = vim
local map = vim.keymap.set

local conform = require("conform")

local bundle_rubocop_cache = {}

local function find_gemfile(ctx)
  return vim.fs.find("Gemfile", { path = ctx.dirname, upward = true })[1]
end

local function bundle_has_rubocop(ctx)
  local gemfile = find_gemfile(ctx)
  if vim.fn.executable("bundle") ~= 1 or gemfile == nil then
    return false
  end

  local root = vim.fs.dirname(gemfile)
  if bundle_rubocop_cache[root] ~= nil then
    return bundle_rubocop_cache[root]
  end

  local result = vim.system({ "bundle", "exec", "ruby", "-e", "gem 'rubocop'" }, { cwd = root }):wait()
  bundle_rubocop_cache[root] = result.code == 0

  return bundle_rubocop_cache[root]
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
        return bundle_has_rubocop(ctx)
      end,
      exit_codes = { 0, 1 },
    },
  },
})

map("n", "<leader>lf", function()
  conform.format()
end, { desc = "Format current buffer" })
