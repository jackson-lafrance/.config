local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup({
  -- Keep Mason useful for tools that only exist there, but never let Mason's
  -- shims shadow tools installed by Homebrew/tec/gems on the normal shell PATH.
  PATH = "append",
})

require("mason-lspconfig").setup({
  automatic_enable = {
    -- Ruby LSP and Shopify's theme LSP should come from the active Shopify/dev
    -- environment, not Mason. Mason's Shopify package is npm-backed, which runs
    -- into Shopify laptop package-manager lockdowns.
    exclude = { "ruby_lsp", "shopify_theme_ls" },
  },
})

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local mason_bin_realpath = vim.uv.fs_realpath(mason_bin) or mason_bin

local function split_command(command)
  return vim.split(command, "%s+", { trimempty = true })
end

local function is_mason_executable(path)
  local realpath = vim.uv.fs_realpath(path) or path
  return realpath:sub(1, #mason_bin_realpath + 1) == mason_bin_realpath .. "/"
end

local function outside_mason_exepath(name)
  for directory in (vim.env.PATH or ""):gmatch("([^:]+)") do
    local candidate = directory .. "/" .. name
    if vim.fn.executable(candidate) == 1 and not is_mason_executable(candidate) then
      return candidate
    end
  end
end

local function resolve_external_command(command)
  local parts = split_command(command)
  if #parts == 0 then
    return parts
  end

  if not parts[1]:find("/", 1, true) then
    parts[1] = outside_mason_exepath(parts[1]) or parts[1]
  end

  return parts
end

local function ruby_lsp_cmd()
  if vim.env.RUBY_LSP_CMD and vim.env.RUBY_LSP_CMD ~= "" then
    return resolve_external_command(vim.env.RUBY_LSP_CMD)
  end

  local ruby_lsp = outside_mason_exepath("ruby-lsp")
  if ruby_lsp then
    return { ruby_lsp }
  end

  local bundle = outside_mason_exepath("bundle")
  if bundle then
    return { bundle, "exec", "ruby-lsp" }
  end

  return { "ruby-lsp" }
end

vim.lsp.config("ruby_lsp", {
  cmd = ruby_lsp_cmd(),
  filetypes = { "ruby", "eruby" },
  root_markers = { "Gemfile", ".git" },
  init_options = {
    formatter = "auto",
  },
})
vim.lsp.enable("ruby_lsp")

vim.api.nvim_create_user_command("RubyLspInfo", function()
  local config = vim.lsp.config.ruby_lsp or {}
  local clients = vim.lsp.get_clients({ name = "ruby_lsp", bufnr = 0 })
  local lines = {
    "ruby_lsp configured cmd: " .. table.concat(config.cmd or {}, " "),
    "current filetype: " .. vim.bo.filetype,
    "attached ruby_lsp clients: " .. #clients,
  }

  for _, client in ipairs(clients) do
    table.insert(lines, "client " .. client.id .. " cmd: " .. table.concat(client.config.cmd or {}, " "))
    table.insert(lines, "client " .. client.id .. " root: " .. (client.config.root_dir or "none"))
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end, { desc = "Show Ruby LSP command and attachment state" })

map("n", "<leader>m", ":Mason<CR>", { desc = "Opens mason" })
map("n", "<leader>lf", function()
  vim.lsp.buf.format()
end, { desc = "Formats the current buffer" })
