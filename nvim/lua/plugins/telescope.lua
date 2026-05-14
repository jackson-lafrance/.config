local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/aznhe21/actions-preview.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
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
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top",
      preview_cutoff = 40,
    }
  },
  pickers = {
    find_files = {
      hidden = true,
    }
  }
})


require("actions-preview").setup {
  backend = { "telescope" },
  extensions = { "env" },
  telescope = vim.tbl_extend(
    "force",
    require("telescope.themes").get_dropdown(), {}
  )
}

require "telescope".load_extension("ui-select")


map('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<leader>fw', builtin.live_grep, { desc = 'Telescope live grep' })

map('n', '<leader>gs', builtin.git_status, { desc = 'Git status' })
map('n', '<leader>gb', builtin.git_branches, { desc = 'Git branches' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Diagnostics' })
