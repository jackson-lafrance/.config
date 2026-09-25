local vim = vim
local map = vim.keymap.set

vim.pack.add({
  {
    src = "https://github.com/jackson-lafrance/vimgentic",
    version = "b4a1eb7a8ad4afa8139b7b390435fd4aacf9f6b0",
  },
})

-- Keep pi's configured default model unless the model picker overrides it.
local vimgentic = require("vimgentic").setup({
  pi = {
    command = "pi",
  },
  chat = {
    width = 0.45,
  },
  pairing = {
    enabled = true,
  },
})

map("n", "<leader>9s", vimgentic.search, { desc = "Vimgentic: search project" })
map({ "n", "x" }, "<leader>9r", vimgentic.review, { desc = "Vimgentic: local review" })
map("n", "<leader>9R", vimgentic.review_open, { desc = "Vimgentic: open review report" })
map({ "n", "x" }, "<leader>9t", vimgentic.tour, { desc = "Vimgentic: guided code tour" })
map("n", "<leader>9g", vimgentic.tour_open, { desc = "Vimgentic: reopen saved tour" })
map("n", "<leader>9j", vimgentic.tour_next, { desc = "Vimgentic: next tour stop" })
map("n", "<leader>9k", vimgentic.tour_prev, { desc = "Vimgentic: previous tour stop" })
map("x", "<leader>9v", vimgentic.visual, { desc = "Vimgentic: request replacement" })
map("n", "<leader>9v", vimgentic.visual_preview, { desc = "Vimgentic: preview replacement" })
map({ "n", "x" }, "<leader>9p", vimgentic.pair, { desc = "Vimgentic: pair actions" })
map("n", "<leader>9e", vimgentic.explain_error, { desc = "Vimgentic: explain diagnostic" })
map("n", "<leader>9c", vimgentic.chat_toggle, { desc = "Vimgentic: focus terminal or editor" })
map("x", "<leader>9c", vimgentic.chat_selection, { desc = "Vimgentic: send selection to terminal" })
map("n", "<leader>9C", vimgentic.chat_close, { desc = "Vimgentic: hide terminal" })
map("n", "<leader>9n", vimgentic.chat_new, { desc = "Vimgentic: start new chat" })
map("n", "<leader>9h", vimgentic.history, { desc = "Vimgentic: session history" })
map("n", "<leader>9o", vimgentic.reopen, { desc = "Vimgentic: reopen last search" })
map("n", "<leader>9x", vimgentic.abort_all, { desc = "Vimgentic: abort all requests" })
map("n", "<leader>9m", vimgentic.pick_model, { desc = "Vimgentic: pick model and thinking level" })
map("n", "<leader>9l", vimgentic.logs, { desc = "Vimgentic: logs" })
map("n", "<leader>9T", vimgentic.terminal, { desc = "Vimgentic: terminal sidebar" })
