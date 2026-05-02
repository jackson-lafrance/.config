local map = vim.keymap.set

map('n', '<leader>w', ':update<CR>', { desc = 'Save' })
map({ 'n', 'v', 'x' }, '<leader>r', ":restart<CR>", { desc = "Restart vim" })

map('', '<leader>y', '"+y', { desc = 'Copy to clipboard' })
map('', '<leader>d', '"+d', { desc = 'Cut to clipboard' })
map('', '<leader>pc', '"+p', { desc = 'Paste clipboard' })
map('', '<leader>pp', '"0p', { desc = 'Paste last yanked' })
map('', '<leader>pd', '"1p', { desc = 'Paste last deleted' })

map('n', '<leader>e', ':Oil<CR>', { desc = 'Open file explorer' })
