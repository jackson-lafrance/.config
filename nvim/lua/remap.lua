local map = vim.keymap.set

map('n', '<leader>w', ':update<CR>', { desc = 'Save' })
map('n', '<leader>r', ":restart<CR>", { desc = "Restart vim" })

map('', '<leader>y', '"+y', { desc = 'Copy to clipboard' })
map('', '<leader>d', '"+d', { desc = 'Cut to clipboard' })
map('', '<leader>pc', '"+p', { desc = 'Paste clipboard' })
map('', '<leader>pp', '"0p', { desc = 'Paste last yanked' })
map('', '<leader>pd', '"1p', { desc = 'Paste last deleted' })

map('n', '<leader>vi', ':edit $MYVIMRC<CR>', { desc = "Edit Vim Config" })
map('n', '<leader>so', ':so $MYVIMRC<CR>', { desc = "Shoutout Vim Config" })

map('n', '<leader>bb', function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { desc = 'Check current line error' })
