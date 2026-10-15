local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()

vim.lsp.config("clangd", {
  cmd = { "clangd", "--log=error" },
})

require("mason-lspconfig").setup({
  automatic_enable = {
    exclude = { "rubocop", "ruby_lsp", "sorbet", "shopify_theme_ls" },
  },
})

local warned_clangd_roots = {}
local clangd_metadata = { ".clangd", "compile_commands.json", "compile_flags.txt" }

local function has_clangd_metadata(root)
  for _, filename in ipairs(clangd_metadata) do
    if vim.uv.fs_stat(vim.fs.joinpath(root, filename)) then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.clangd", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "clangd" then
      return
    end

    local root = client.root_dir
    if root and not warned_clangd_roots[root] and not has_clangd_metadata(root) then
      warned_clangd_roots[root] = true
      vim.notify(
        string.format(
          "clangd is using fallback compiler flags for %s.\nAdd compile_commands.json, compile_flags.txt, or .clangd for accurate completion and diagnostics.",
          vim.fn.fnamemodify(root, ":~")
        ),
        vim.log.levels.WARN,
        { title = "clangd project metadata" }
      )
    end

    map("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", {
      buffer = args.buf,
      desc = "Switch C/C++ source/header",
    })

    if client:supports_method("textDocument/inlayHint") then
      map("n", "<leader>ci", function()
        local filter = { bufnr = args.buf }
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
      end, { buffer = args.buf, desc = "Toggle C/C++ inlay hints" })
    end
  end,
})

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
  init_options = {
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
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
map("n", "grr", function() require("fzf-lua").lsp_references() end, { desc = "LSP references" })
map("n", "gri", function() require("fzf-lua").lsp_implementations() end, { desc = "LSP implementations" })
map("n", "grt", function() require("fzf-lua").lsp_typedefs() end, { desc = "LSP type definitions" })
map("n", "gO", function() require("fzf-lua").lsp_document_symbols() end, { desc = "LSP document symbols" })
map({ "n", "x" }, "gra", function() require("fzf-lua").lsp_code_actions() end, { desc = "LSP code actions" })
map("n", "<leader>fs", function() require("fzf-lua").lsp_live_workspace_symbols() end, { desc = "LSP workspace symbols" })

map("n", "<leader>m", ":Mason<CR>", { desc = "Opens mason" })
map("n", "<leader>li", ":checkhealth vim.lsp<CR>", { desc = "LSP status" })
