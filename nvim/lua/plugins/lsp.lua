local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()

vim.lsp.config("clangd", {
  cmd = { "clangd", "--log=error", "--function-arg-placeholders=true" },
  init_options = {
    fallbackFlags = {
      "-std=c++11",
      "-Wall",
      "-Wextra",
    },
  },
})

require("mason-lspconfig").setup({
  automatic_enable = {
    exclude = { "rubocop", "ruby_lsp", "sorbet", "shopify_theme_ls" },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("my.clangd", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "clangd" then
      return
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

local function ruby_tool_available(root, tool, probe_argv, install_argv)
  local ok, probe = pcall(function()
    return vim.system(ruby_cmd(root, probe_argv), { cwd = root, text = true }):wait(5000)
  end)
  local key = root .. tool
  if ok and probe.code == 0 then
    warned_roots[key] = nil
    return true
  end
  if not warned_roots[key] then
    warned_roots[key] = true
    local detail = ok and vim.trim(probe.stderr or "") or tostring(probe)
    local install = table.concat(vim.tbl_map(vim.fn.shellescape, ruby_cmd(root, install_argv)), " ")
    vim.notify(
      string.format("%s is unavailable for %s.\n%s\nInstall: cd %s && %s", tool, root, detail, vim.fn.shellescape(root), install),
      vim.log.levels.WARN
    )
  end
  return false
end

local function ruby_server_cmd(argv)
  return function(dispatchers, config)
    local root = assert(config.root_dir)
    return vim.lsp.rpc.start(ruby_cmd(root, argv), dispatchers, { cwd = root })
  end
end

-- Resolve the gem through the project's Ruby, not a PATH wrapper that can
-- replace Ruby and GEM_HOME (such as Homebrew's ruby-lsp executable).
local ruby_lsp_executable = "Gem.bin_path('ruby-lsp', 'ruby-lsp')"

vim.lsp.config("ruby_lsp", {
  cmd = ruby_server_cmd({ "ruby", "-e", "load " .. ruby_lsp_executable }),
  init_options = {
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
  root_dir = function(bufnr, on_dir)
    local root = ruby_root(bufnr)
    if root and ruby_tool_available(root, "ruby-lsp", {
      "ruby", "-e", ruby_lsp_executable,
    }, { "gem", "install", "ruby-lsp", "ruby-lsp-rails" }) then
      on_dir(root)
    end
  end,
})

vim.lsp.config("sorbet", {
  cmd = ruby_server_cmd({ "bundle", "exec", "srb", "tc", "--lsp" }),
  root_dir = function(bufnr, on_dir)
    local root = ruby_root(bufnr)
    if root and vim.uv.fs_stat(root .. "/sorbet/config") and ruby_tool_available(root, "bundle", {
      "sh", "-c", "command -v bundle",
    }, { "bundle", "install" }) then
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
