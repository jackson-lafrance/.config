local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- TODO comment
  s("todo", fmt("TODO({}): {}", {
    f(function() return "jackson-lafrance" end),
    i(1, "description"),
  })),

  -- FIXME comment
  s("fixme", fmt("FIXME: {}", {
    i(1, "description"),
  })),

  -- NOTE comment
  s("note", fmt("NOTE: {}", {
    i(1, "description"),
  })),

  -- Lorem ipsum placeholder text
  s("lorem", {
    t("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
  }),
}
