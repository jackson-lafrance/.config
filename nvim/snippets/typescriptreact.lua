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
  -- Functional component
  s("rfc", fmt([[
export default function {}({}) {{
  return (
    <div>
      {}
    </div>
  )
}}
]], {
    f(get_component_name),
    i(1),
    i(2, "Content"),
  })),

  -- Functional component with props interface
  s("rfcp", fmt([[
interface {}Props {{
  {}
}}

export default function {}({{ {} }}: {}Props) {{
  return (
    <div>
      {}
    </div>
  )
}}
]], {
    f(get_component_name),
    i(1, "children?: React.ReactNode"),
    f(get_component_name),
    i(2),
    f(get_component_name),
    i(3, "Content"),
  })),

  -- Arrow function component
  s("rafc", fmt([[
const {} = ({}) => {{
  return (
    <div>
      {}
    </div>
  )
}}

export default {}
]], {
    f(get_component_name),
    i(1),
    i(2, "Content"),
    f(get_component_name),
  })),

  -- useState hook
  s("us", fmt("const [{}, set{}] = useState{}({})", {
    i(1, "state"),
    f(function(args) return args[1][1]:gsub("^%l", string.upper) end, { 1 }),
    c(2, { t(""), t("<>") }),
    i(3, "initialValue"),
  })),

  -- useEffect hook
  s("ue", fmt([[
useEffect(() => {{
  {}
}}, [{}])
]], {
    i(1),
    i(2),
  })),

  -- useRef hook
  s("ur", fmt("const {} = useRef{}({})", {
    i(1, "ref"),
    c(2, { t(""), t("<>") }),
    i(3, "null"),
  })),

  -- useMemo hook
  s("um", fmt([[
const {} = useMemo(() => {{
  return {}
}}, [{}])
]], {
    i(1, "value"),
    i(2),
    i(3),
  })),

  -- useCallback hook
  s("uc", fmt([[
const {} = useCallback(({}) => {{
  {}
}}, [{}])
]], {
    i(1, "callback"),
    i(2),
    i(3),
    i(4),
  })),

  -- useContext hook
  s("uct", fmt("const {} = useContext({})", {
    i(1, "value"),
    i(2, "Context"),
  })),

  -- React Native View
  s("rnv", fmt([[
<View style={{{}}}>
  {}
</View>
]], {
    i(1, "styles.container"),
    i(2),
  })),

  -- React Native Text
  s("rnt", fmt([[
<Text style={{{}}}>
  {}
</Text>
]], {
    i(1, "styles.text"),
    i(2, "Text"),
  })),

  -- React Native TouchableOpacity
  s("rnto", fmt([[
<TouchableOpacity onPress={{{}}} style={{{}}}>
  {}
</TouchableOpacity>
]], {
    i(1, "() => {}"),
    i(2, "styles.button"),
    i(3),
  })),

  -- React Native StyleSheet
  s("rnss", fmt([[
const styles = StyleSheet.create({{
  {}: {{
    {}
  }},
}})
]], {
    i(1, "container"),
    i(2, "flex: 1"),
  })),

  -- React Native Screen component
  s("rnscreen", fmt([[
import {{ View, Text, StyleSheet }} from 'react-native'

export default function {}() {{
  return (
    <View style={{styles.container}}>
      <Text>{}</Text>
    </View>
  )
}}

const styles = StyleSheet.create({{
  container: {{
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  }},
}})
]], {
    f(get_component_name),
    i(1, "Screen"),
  })),

  -- Import React
  s("imr", t("import React from 'react'")),

  -- Import React hooks
  s("imrh", fmt("import {{ {} }} from 'react'", {
    i(1, "useState, useEffect"),
  })),

  -- Import React Native
  s("imrn", fmt("import {{ {} }} from 'react-native'", {
    i(1, "View, Text, StyleSheet"),
  })),

  -- className
  s("cn", fmt('className="{}"', { i(1) })),

  -- Conditional rendering
  s("cond", fmt("{{{}  && (\n  {}\n)}}", {
    i(1, "condition"),
    i(2, "<div />"),
  })),

  -- Ternary in JSX
  s("tern", fmt("{{{}  ? {} : {}}}", {
    i(1, "condition"),
    i(2, "<div />"),
    i(3, "null"),
  })),

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
