-- React / React Native snippets (TSX)
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

-- Get filename without extension for component name
local function get_component_name()
  local filename = vim.fn.expand("%:t:r")
  if filename == "" or filename == "index" then
    return "Component"
  end
  return filename:gsub("^%l", string.upper)
end

return {
  -- Map over array
  s("map", fmt([[
{{{}.map(({}) => (
  <{} key={{{}}}>
    {}
  </{}>
))}}
]], {
    i(1, "items"),
    i(2, "item"),
    i(3, "div"),
    i(4, "item.id"),
    i(5),
    f(function(args) return args[1][1] end, { 3 }),
  })),
}
