local vim = vim
local map = vim.keymap.set

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/aznhe21/actions-preview.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
})

local builtin = require "telescope.builtin"
require "telescope".setup({
  defaults = {
    file_ignore_patterns = {
      "%.cache/.*",
      "%.local/.*",
      "%.git/.*",
      "node_modules/.*",
    },
  },
  pickers = {
    find_files = {
      hidden = true,
    }
  }
})
require "telescope".load_extension("ui-select")

require("actions-preview").setup()

map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fw', builtin.live_grep, { desc = 'Telescope live grep' })

map('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
map('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })
