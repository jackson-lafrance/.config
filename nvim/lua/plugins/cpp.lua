local map = vim.keymap.set

local homebrew_bin = "/opt/homebrew/bin"
if vim.fn.executable(homebrew_bin .. "/fd") == 1 then
  vim.env.PATH = homebrew_bin .. ":" .. vim.env.PATH
  vim.g.cppassist_fd_binary_name = homebrew_bin .. "/fd"
end

vim.pack.add({
  "https://github.com/Kohirus/cppassist.nvim",
})

require("cppassist").setup()

map("n", "<leader>cd", "<cmd>ImplementInSource<cr>", {
  desc = "Define C++ declaration in source",
})

map("x", "<leader>cd", function()
  require("cppassist").ImplementInSourceInVisualMode()
end, {
  desc = "Define selected C++ declarations in source",
})

map("n", "<leader>co", "<cmd>ImplementOutOfClass<cr>", {
  desc = "Define C++ declaration outside class",
})
