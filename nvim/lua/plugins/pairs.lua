vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/windwp/nvim-ts-autotag",
})

require "nvim-autopairs".setup({
  check_ts = true,
  -- autocomplete.lua handles Enter for both completion and pairs.
  map_cr = false,
})

require "nvim-ts-autotag".setup()
