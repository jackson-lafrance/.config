local vim = vim
vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

local function pum()
  return vim.fn.pumvisible() == 1
end

vim.keymap.set("i", "<C-l>", function()
  vim.lsp.completion.get()
end, { desc = "trigger completion" })

vim.keymap.set("i", "<CR>", function()
  return pum() and vim.fn.complete_info({ "selected" }).selected ~= 1 and "<C-y>" or "<CR>"
end, { expr = true, desc = "accept completion" })

vim.keymap.set("i", "<Tab>", function()
  return pum() and "<C-n>" or "<Tab>"
end, { expr = true, desc = "next completion item" })

vim.keymap.set("i", "<S-Tab>", function()
  return pum() and "<C-p>" or "<S-Tab>"
end, { expr = true, desc = "previous completion item" })

vim.keymap.set("i", "<C-c>", function()
  return pum() and "<C-e>" or "<C-c>"
end, { expr = true, desc = "cancel completion" })
