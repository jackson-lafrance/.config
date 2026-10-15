vim.pack.add({
  "https://github.com/windwp/nvim-autopairs",
  "https://github.com/windwp/nvim-ts-autotag",
})

require("nvim-autopairs").setup({
  check_ts = true,
  map_cr = true,
})

require "nvim-ts-autotag".setup()
