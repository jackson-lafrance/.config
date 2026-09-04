local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
})

local fzf = require("fzf-lua")

fzf.setup({
  -- Replaces telescope-ui-select: vim.ui.select (code actions, etc.) opens in fzf.
  ui_select = {},
  files = {
    hidden = true,
  },
})

-- Pickers search from Neovim's cwd (start nvim inside the zone/project).
-- The uppercase variants search from the git root: in World that is the whole
-- sparse checkout (~500k files), so use them for cross-zone lookups only.
local function repo_root()
  return vim.fs.root(0, ".git") or vim.uv.cwd()
end

-- Directory of the current buffer; in Oil, the directory being browsed.
local function buffer_dir()
  if vim.bo.filetype == "oil" then
    return require("oil").get_current_dir()
  end
  return vim.fn.expand("%:p:h")
end

map("n", "<leader>ff", fzf.files, { desc = "Find files (cwd)" })
map("n", "<leader>fw", fzf.live_grep, { desc = "Live grep (cwd)" })
map("x", "<leader>fw", fzf.grep_visual, { desc = "Grep selection (cwd)" })
map("n", "<leader>fF", function() fzf.files({ cwd = repo_root() }) end, { desc = "Find files (repo root)" })
map("n", "<leader>fW", function() fzf.live_grep({ cwd = repo_root() }) end, { desc = "Live grep (repo root)" })
map("n", "<leader>fd", function() fzf.files({ cwd = buffer_dir() }) end, { desc = "Find files (this buffer's directory)" })
map("n", "<leader>f.", fzf.grep_cword, { desc = "Grep word under cursor" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume last picker" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fq", fzf.quickfix, { desc = "Quickfix list" })
map("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })

map("n", "<leader>gs", fzf.git_status, { desc = "Git status" })
map("n", "<leader>gb", fzf.git_branches, { desc = "Git branches" })
map("n", "<leader>gc", fzf.git_bcommits, { desc = "Git commits for this file" })
map("n", "<leader>gC", fzf.git_commits, { desc = "Git commits (repo)" })

map("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "Diagnostics (all buffers)" })
map("n", "<leader>sD", fzf.diagnostics_document, { desc = "Diagnostics (this buffer)" })
