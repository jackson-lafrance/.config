local vim = vim
local map = vim.keymap.set

vim.pack.add({
  {
    src = "https://github.com/stevearc/quicker.nvim",
    version = "v1.5.1",
  },
})

local quicker = require("quicker")

quicker.setup({
  opts = {
    wrap = true,
    linebreak = true,
  },
  keys = {
    {
      ">",
      function()
        quicker.expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        quicker.collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
  edit = {
    enabled = true,
    -- :write in quickfix applies edits to source buffers, but leaves those
    -- buffers modified so saving project files remains a deliberate action.
    autosave = false,
  },
})

map("n", "<leader>q", function()
  quicker.toggle({ focus = true })
end, { desc = "Toggle quickfix" })
