local vim = vim
local map = vim.keymap.set

vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
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
