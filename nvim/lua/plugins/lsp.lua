local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason-lspconfig.nvim",
})

require("mason").setup()

local lspconfig = require("lspconfig")
require("mason-lspconfig").setup({
  handers = {
    function(server_name)
      lspconfig[server_name].setup({})
    end,
  },
})

map("n", "<leader>m", ":Mason<CR>", { desc = "Opens mason" })
map("n", "<leader>lf", function()
  vim.lsp.buf.format()
end, { desc = "Formats the current buffer" })
