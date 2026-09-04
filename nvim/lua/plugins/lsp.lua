local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()

require("mason-lspconfig").setup({
  automatic_enable = {
    -- Ruby servers run from the project's own Ruby (shadowenv or rbenv), never
    -- from Mason. Mason stays useful for every other language server.
    exclude = { "ruby_lsp", "sorbet", "shopify_theme_ls" },
  },
})

-- Ruby --------------------------------------------------------------------
--
-- Ruby tools run inside the project's Ruby environment, picked per root:
--   <root>/.shadowenv.d  -> shadowenv exec --dir <root> -- <tool>   (Shopify dev / World zones)
--   <root>/.ruby-version -> rbenv exec <tool>                        (rbenv at home)
--   otherwise            -> <tool> from PATH
--
-- The root is the nearest `.shadowenv.d` (the World zone, even for nested gems),
-- else the nearest Gemfile or .git.

local function ruby_env_prefix(root)
  if vim.fn.executable("shadowenv") == 1 and vim.uv.fs_stat(root .. "/.shadowenv.d") then
    return { "shadowenv", "exec", "--dir", root, "--" }
  end
  if vim.fn.executable("rbenv") == 1 and vim.uv.fs_stat(root .. "/.ruby-version") then
    return { "rbenv", "exec" }
  end
  return {}
end

local function ruby_cmd(root, argv)
  return vim.list_extend(ruby_env_prefix(root), argv)
end

local function ruby_root(bufnr)
  return vim.fs.root(bufnr, ".shadowenv.d") or vim.fs.root(bufnr, { "Gemfile", ".git" })
end

local warned_roots = {}

local function ruby_server_cmd(tool, argv, install_hint)
  return function(dispatchers, config)
    local root = assert(config.root_dir)
    local probe = vim.system(ruby_cmd(root, { "sh", "-c", "command -v " .. tool }), { cwd = root }):wait()
    if probe.code ~= 0 and not warned_roots[root .. tool] then
      warned_roots[root .. tool] = true
      vim.notify(
        string.format("%s is not installed for %s.\nFix: cd %s && %s", tool, root, root, install_hint),
        vim.log.levels.WARN
      )
    end
    return vim.lsp.rpc.start(ruby_cmd(root, argv), dispatchers, { cwd = root })
  end
end

vim.lsp.config("ruby_lsp", {
  cmd = ruby_server_cmd("ruby-lsp", { "ruby-lsp" }, "gem install ruby-lsp"),
  root_dir = function(bufnr, on_dir)
    local root = ruby_root(bufnr)
    if root then
      on_dir(root)
    end
  end,
})

vim.lsp.config("sorbet", {
  cmd = ruby_server_cmd("bundle", { "bundle", "exec", "srb", "tc", "--lsp" }, "bundle install"),
  root_dir = function(bufnr, on_dir)
    local root = ruby_root(bufnr)
    if root and vim.uv.fs_stat(root .. "/sorbet/config") then
      on_dir(root)
    end
  end,
  handlers = {
    -- Sorbet reports long operations (Indexing, SlowPath typechecking) here.
    -- Hover and diagnostics wait until Indexing ends, so say when that is.
    ["sorbet/showOperation"] = function(_, params)
      vim.g.sorbet_status = params.status == "start" and params.description or ""
      if params.operationName == "Indexing" then
        vim.notify("Sorbet: indexing " .. (params.status == "start" and "started" or "done"))
      end
    end,
  },
})

vim.lsp.enable({ "ruby_lsp", "sorbet" })

map("n", "gd", function() require("fzf-lua").lsp_definitions() end, { desc = "LSP definitions" })
map("n", "gtr", function() require("fzf-lua").lsp_references() end, { desc = "LSP references" })
map("n", "gti", function() require("fzf-lua").lsp_implementations() end, { desc = "LSP implementations" })
map("n", "gtt", function() require("fzf-lua").lsp_typedefs() end, { desc = "LSP type definitions" })
map("n", "gO", function() require("fzf-lua").lsp_document_symbols() end, { desc = "LSP document symbols" })
map({ "n", "x" }, "gra", function() require("fzf-lua").lsp_code_actions() end, { desc = "LSP code actions" })
map("n", "<leader>fs", function() require("fzf-lua").lsp_live_workspace_symbols() end, { desc = "LSP workspace symbols" })

map("n", "<leader>m", ":Mason<CR>", { desc = "Opens mason" })
map("n", "<leader>lf", function()
  -- Ruby LSP formats with RuboCop. In Core the first run loads RuboCop's config
  -- and takes several seconds; the default 1s timeout gives up too early.
  vim.lsp.buf.format({ timeout_ms = 15000 })
end, { desc = "Formats the current buffer" })
map("n", "<leader>li", ":checkhealth vim.lsp<CR>", { desc = "LSP status" })
