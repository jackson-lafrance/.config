-- JavaScript snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Async function
  s("afn", fmt([[
async function {}({}) {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3),
  })),

  -- Arrow async function
  s("aafn", fmt([[
const {} = async ({}) => {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3),
  })),

  -- Arrow function
  s("af", fmt("const {} = ({}) => {}", {
    i(1, "name"),
    i(2),
    i(3, "{}"),
  })),

  -- Function
  s("fn", fmt([[
function {}({}) {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3),
  })),

  -- Export function
  s("efn", fmt([[
export function {}({}) {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3),
  })),

  -- Export default function
  s("edfn", fmt([[
export default function {}({}) {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3),
  })),

  -- Try-catch
  s("try", fmt([[
try {{
  {}
}} catch (error) {{
  {}
}}
]], {
    i(1),
    i(2, "console.error(error)"),
  })),

  -- For of loop
  s("forof", fmt([[
for (const {} of {}) {{
  {}
}}
]], {
    i(1, "item"),
    i(2, "items"),
    i(3),
  })),

  -- For in loop
  s("forin", fmt([[
for (const {} in {}) {{
  {}
}}
]], {
    i(1, "key"),
    i(2, "object"),
    i(3),
  })),

  -- For loop
  s("for", fmt([[
for (let {} = 0; {} < {}.length; {}++) {{
  {}
}}
]], {
    i(1, "i"),
    f(function(args) return args[1][1] end, { 1 }),
    i(2, "arr"),
    f(function(args) return args[1][1] end, { 1 }),
    i(3),
  })),

  -- If statement
  s("if", fmt([[
if ({}) {{
  {}
}}
]], {
    i(1, "condition"),
    i(2),
  })),

  -- If-else
  s("ife", fmt([[
if ({}) {{
  {}
}} else {{
  {}
}}
]], {
    i(1, "condition"),
    i(2),
    i(3),
  })),

  -- Console log
  s("cl", fmt("console.log({})", { i(1) })),

  -- Console log with label
  s("cll", fmt("console.log('{}:', {})", {
    i(1, "label"),
    i(2),
  })),

  -- Console error
  s("ce", fmt("console.error({})", { i(1) })),

  -- Import
  s("imp", fmt("import {{ {} }} from '{}'", {
    i(2, "module"),
    i(1, "package"),
  })),

  -- Import default
  s("impd", fmt("import {} from '{}'", {
    i(2, "module"),
    i(1, "package"),
  })),

  -- Require
  s("req", fmt("const {} = require('{}')", {
    i(1, "module"),
    i(2, "package"),
  })),

  -- Export
  s("exp", fmt("export {{ {} }}", { i(1) })),

  -- Export const
  s("exc", fmt("export const {} = {}", {
    i(1, "name"),
    i(2),
  })),

  -- Module exports
  s("mexp", fmt("module.exports = {{ {} }}", { i(1) })),

  -- Destructure
  s("des", fmt("const {{ {} }} = {}", {
    i(2),
    i(1, "object"),
  })),

  -- Promise
  s("prom", fmt([[
new Promise((resolve, reject) => {{
  {}
}})
]], {
    i(1),
  })),

  -- Fetch
  s("fetch", fmt([[
const response = await fetch('{}', {{
  method: '{}',
  headers: {{
    'Content-Type': 'application/json',
  }},
  {}
}})
const data = await response.json()
]], {
    i(1, "/api/endpoint"),
    c(2, { t("GET"), t("POST"), t("PUT"), t("DELETE"), t("PATCH") }),
    i(3),
  })),

  -- Class
  s("class", fmt([[
class {} {{
  constructor({}) {{
    {}
  }}

  {}
}}
]], {
    i(1, "Name"),
    i(2),
    i(3),
    i(4),
  })),

  -- setTimeout
  s("st", fmt([[
setTimeout(() => {{
  {}
}}, {})
]], {
    i(2),
    i(1, "1000"),
  })),

  -- setInterval
  s("si", fmt([[
setInterval(() => {{
  {}
}}, {})
]], {
    i(2),
    i(1, "1000"),
  })),

  -- Array map
  s("map", fmt("{}.map(({}) => {})", {
    i(1, "arr"),
    i(2, "item"),
    i(3),
  })),

  -- Array filter
  s("filter", fmt("{}.filter(({}) => {})", {
    i(1, "arr"),
    i(2, "item"),
    i(3),
  })),

  -- Array reduce
  s("reduce", fmt("{}.reduce((acc, {}) => {}, {})", {
    i(1, "arr"),
    i(2, "item"),
    i(3, "acc"),
    i(4, "[]"),
  })),
}
