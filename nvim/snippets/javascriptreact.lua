-- React / React Native snippets (JSX) - inherits from TSX
-- This file loads the TSX snippets since they work the same
return require("luasnip.loaders.from_lua").load_file(vim.fn.stdpath("config") .. "/snippets/typescriptreact.lua") or {}
