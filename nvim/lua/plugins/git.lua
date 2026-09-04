local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/tpope/vim-fugitive",
})

-- gitsigns: hunks in the sign column, hunk navigation, blame.
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function bmap(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    bmap("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next hunk")
    bmap("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Previous hunk")

    bmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk (float)")
    bmap("n", "<leader>to", gs.preview_hunk_inline, "Preview hunk inline")
    bmap("n", "<leader>hs", gs.stage_hunk, "Stage/unstage hunk")
    bmap("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    bmap("x", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
    bmap("x", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
    bmap("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
    bmap("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
    bmap("n", "<leader>hq", function() gs.setqflist("all") end, "All hunks to quickfix")
    bmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    bmap("n", "<leader>hB", gs.blame, "Blame file")
    bmap("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
    bmap("n", "<leader>tw", gs.toggle_word_diff, "Toggle word diff")
    bmap({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
  end,
})

-- fugitive: status, diffs against index/branch, file history.
local function default_branch()
  local ref = vim.fn.systemlist("git symbolic-ref -q --short refs/remotes/origin/HEAD")[1]
  return (vim.v.shell_error == 0 and ref) or "origin/main"
end

map("n", "<leader>gg", ":Git<CR>", { desc = "Git status (fugitive)" })
map("n", "<leader>gd", ":Gdiffsplit<CR>", { desc = "Diff file against index" })
map("n", "<leader>gD", function()
  vim.cmd("Gdiffsplit " .. default_branch())
end, { desc = "Diff file against default branch" })
map("n", "<leader>gR", function()
  -- Every file changed since the merge-base with the default branch, one tab each.
  vim.cmd("Git difftool -y " .. default_branch() .. "...")
end, { desc = "Review branch: all changed files vs default branch" })
map("n", "<leader>gl", ":0Gclog<CR>", { desc = "File history (quickfix)" })
