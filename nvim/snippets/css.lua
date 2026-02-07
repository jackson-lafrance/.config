-- CSS snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Visually hidden (accessible)
  s("srhidden", t({
    "position: absolute;",
    "width: 1px;",
    "height: 1px;",
    "padding: 0;",
    "margin: -1px;",
    "overflow: hidden;",
    "clip: rect(0, 0, 0, 0);",
    "white-space: nowrap;",
    "border: 0;",
  })),
}
