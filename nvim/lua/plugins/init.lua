local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/rose-pine/neovim",
  "https://github.com/nvim-tree/nvim-web-devicons",

  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/stevearc/oil.nvim",
})

require("rose-pine").setup({
  styles = {
    transparency = true,
  },
})
vim.cmd("colorscheme rose-pine-main")

local treesitter = require("nvim-treesitter")
local configured_parsers = {
  "bash", "c", "cpp", "css", "diff", "embedded_template", "git_rebase", "gitcommit",
  "graphql", "html", "javascript", "json", "lua", "markdown", "markdown_inline",
  "python", "query", "regex", "ruby", "rust", "sql", "tsx", "typescript", "typst",
  "vim", "vimdoc", "yaml",
}

treesitter.setup()

vim.api.nvim_create_user_command("TSInstallConfigured", function()
  if vim.fn.executable("tree-sitter") == 0 then
    vim.notify(
      "tree-sitter-cli is required. Install it, then run :TSInstallConfigured again.",
      vim.log.levels.ERROR,
      { title = "Treesitter parsers" }
    )
    return
  end

  treesitter.install(configured_parsers)
end, {
  desc = "Install the Treesitter parsers used by this config",
  force = true,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("my.treesitter", {}),
  callback = function(args)
    -- Errors when no parser exists for the filetype; regex syntax stays on then.
    pcall(vim.treesitter.start, args.buf)
  end,
})

require("oil").setup()
map("n", "<leader>e", ":Oil<CR>", { desc = "Open file explorer" })

require("plugins.pairs")
require("plugins.completion")
require("plugins.lsp")
require("plugins.format")
require("plugins.finder")
require("plugins.quickfix")
require("plugins.git")
require("plugins.ai")

-- Package operations are intentionally separate: update from upstream, restore
-- the committed lockfile, and delete inactive checkouts are different actions.
vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, {
  desc = "Review plugin updates from their configured sources",
  force = true,
})

vim.api.nvim_create_user_command("PackSync", function()
  vim.pack.update(nil, { target = "lockfile" })
end, {
  desc = "Review restoring plugins to nvim-pack-lock.json",
  force = true,
})

vim.api.nvim_create_user_command("PackClean", function(args)
  local stale = {}
  for _, plug in ipairs(vim.pack.get()) do
    if not plug.active then
      table.insert(stale, plug.spec.name)
    end
  end
  table.sort(stale)

  if #stale == 0 then
    vim.notify("PackClean: nothing to remove")
    return
  end

  if not args.bang then
    vim.notify(
      string.format(
        "Inactive plugins (%d):\n%s\n\nReview this list, then run :PackClean! to delete them.",
        #stale,
        table.concat(stale, ", ")
      ),
      vim.log.levels.WARN,
      { title = "PackClean preview" }
    )
    return
  end

  vim.pack.del(stale)
  vim.notify("PackClean: removed " .. table.concat(stale, ", "))
end, {
  bang = true,
  desc = "Preview inactive plugins; add ! to delete them",
  force = true,
})
