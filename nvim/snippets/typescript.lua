-- TypeScript snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Interface
  s("int", fmt([[
interface {} {{
  {}
}}
]], {
    i(1, "Name"),
    i(2),
  })),

  -- Type alias
  s("type", fmt("type {} = {}", {
    i(1, "Name"),
    i(2, "{}"),
  })),

  -- Async function
  s("afn", fmt([[
async function {}({}): Promise<{}> {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3, "void"),
    i(4),
  })),

  -- Arrow async function
  s("aafn", fmt([[
const {} = async ({}): Promise<{}> => {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3, "void"),
    i(4),
  })),

  -- Arrow function
  s("af", fmt("const {} = ({}) => {}", {
    i(1, "name"),
    i(2),
    i(3, "{}"),
  })),

  -- Function with types
  s("fn", fmt([[
function {}({}): {} {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3, "void"),
    i(4),
  })),

  -- Export function
  s("efn", fmt([[
export function {}({}): {} {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3, "void"),
    i(4),
  })),

  -- Export default function
  s("edfn", fmt([[
export default function {}({}): {} {{
  {}
}}
]], {
    i(1, "name"),
    i(2),
    i(3, "void"),
    i(4),
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

  -- Try-catch-finally
  s("tryf", fmt([[
try {{
  {}
}} catch (error) {{
  {}
}} finally {{
  {}
}}
]], {
    i(1),
    i(2, "console.error(error)"),
    i(3),
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

  -- Export
  s("exp", fmt("export {{ {} }}", { i(1) })),

  -- Export const
  s("exc", fmt("export const {} = {}", {
    i(1, "name"),
    i(2),
  })),

  -- Destructure
  s("des", fmt("const {{ {} }} = {}", {
    i(2),
    i(1, "object"),
  })),

  -- Promise
  s("prom", fmt([[
new Promise<{}>((resolve, reject) => {{
  {}
}})
]], {
    i(1, "void"),
    i(2),
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

  -- Enum
  s("enum", fmt([[
enum {} {{
  {}
}}
]], {
    i(1, "Name"),
    i(2),
  })),
}
