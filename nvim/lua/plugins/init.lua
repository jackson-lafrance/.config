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

-- Treesitter (main branch): parsers are installed here, highlighting must be
-- started per buffer. `install` is async and a no-op for installed parsers.
local treesitter = require("nvim-treesitter")
treesitter.setup()
treesitter.install({
  "bash", "c", "cpp", "css", "diff", "embedded_template", "git_rebase", "gitcommit",
  "graphql", "html", "javascript", "json", "lua", "markdown", "markdown_inline",
  "python", "query", "regex", "ruby", "rust", "sql", "tsx", "typescript", "typst",
  "vim", "vimdoc", "yaml",
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

require("plugins.lsp")
require("plugins.finder")
require("plugins.git")
require("plugins.ai")
require("plugins.pairs")

-- Remove plugins that are on disk but no longer added by this config.
vim.api.nvim_create_user_command("PackClean", function()
  local stale = {}
  for _, plug in ipairs(vim.pack.get()) do
    if not plug.active then
      table.insert(stale, plug.spec.name)
    end
  end
  if #stale == 0 then
    vim.notify("PackClean: nothing to remove")
    return
  end
  vim.pack.del(stale)
  vim.notify("PackClean: removed " .. table.concat(stale, ", "))
end, { desc = "Delete vim.pack plugins not used by this config" })
