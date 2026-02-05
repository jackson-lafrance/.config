local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Require module
  s("req", fmt('local {} = require("{}")', {
    i(1, "module"),
    i(2, "module"),
  })),

  -- Local function
  s("lf", fmt([[
local {} = function({})
  {}
end
]], {
    i(1, "name"),
    i(2),
    i(3),
  })),

  -- Function
  s("fn", fmt([[
function {}({})
  {}
end
]], {
    i(1, "name"),
    i(2),
    i(3),
  })),

  -- If statement
  s("if", fmt([[
if {} then
  {}
end
]], {
    i(1, "condition"),
    i(2),
  })),

  -- For loop (numeric)
  s("for", fmt([[
for {} = {}, {} do
  {}
end
]], {
    i(1, "i"),
    i(2, "1"),
    i(3, "10"),
    i(4),
  })),

  -- For loop (pairs/ipairs)
  s("forp", fmt([[
for {}, {} in {}({}) do
  {}
end
]], {
    i(1, "k"),
    i(2, "v"),
    c(3, { t("pairs"), t("ipairs") }),
    i(4, "table"),
    i(5),
  })),

  -- Neovim keymap
  s("map", fmt('map("{}", "{}", {}, {{ desc = "{}" }})', {
    c(1, { t("n"), t("i"), t("v"), t("x") }),
    i(2, "lhs"),
    i(3, "rhs"),
    i(4, "description"),
  })),

  -- Neovim autocmd
  s("autocmd", fmt([[
vim.api.nvim_create_autocmd("{}", {{
  pattern = "{}",
  callback = function()
    {}
  end,
}})
]], {
    i(1, "Event"),
    i(2, "*"),
    i(3),
  })),

  -- Print/debug
  s("pp", fmt('vim.print({})', { i(1) })),
}
