-- CSS snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Flexbox container
  s("flex", fmt([[
display: flex;
justify-content: {};
align-items: {};
]], {
    c(1, { t("center"), t("flex-start"), t("flex-end"), t("space-between"), t("space-around"), t("space-evenly") }),
    c(2, { t("center"), t("flex-start"), t("flex-end"), t("stretch"), t("baseline") }),
  })),

  -- Flexbox column
  s("flexc", fmt([[
display: flex;
flex-direction: column;
justify-content: {};
align-items: {};
]], {
    c(1, { t("center"), t("flex-start"), t("flex-end"), t("space-between"), t("space-around") }),
    c(2, { t("center"), t("flex-start"), t("flex-end"), t("stretch") }),
  })),

  -- Grid container
  s("grid", fmt([[
display: grid;
grid-template-columns: {};
gap: {};
]], {
    c(1, { t("repeat(3, 1fr)"), t("repeat(auto-fit, minmax(250px, 1fr))"), t("1fr 1fr"), t("1fr 2fr 1fr") }),
    i(2, "1rem"),
  })),

  -- Grid item placement
  s("gcol", fmt("grid-column: {} / {};", {
    i(1, "1"),
    i(2, "3"),
  })),

  s("grow", fmt("grid-row: {} / {};", {
    i(1, "1"),
    i(2, "3"),
  })),

  -- Center everything
  s("center", t({
    "display: flex;",
    "justify-content: center;",
    "align-items: center;",
  })),

  -- Absolute center
  s("abscenter", t({
    "position: absolute;",
    "top: 50%;",
    "left: 50%;",
    "transform: translate(-50%, -50%);",
  })),

  -- Position absolute
  s("abs", fmt([[
position: absolute;
top: {};
left: {};
]], {
    i(1, "0"),
    i(2, "0"),
  })),

  -- Position fixed
  s("fix", fmt([[
position: fixed;
top: {};
left: {};
]], {
    i(1, "0"),
    i(2, "0"),
  })),

  -- Box sizing reset
  s("box", t("box-sizing: border-box;")),

  -- Full width/height
  s("full", t({
    "width: 100%;",
    "height: 100%;",
  })),

  -- Full viewport
  s("fullvh", t({
    "width: 100vw;",
    "height: 100vh;",
  })),

  -- Margin
  s("m", fmt("margin: {};", { i(1, "0") })),
  s("mt", fmt("margin-top: {};", { i(1, "1rem") })),
  s("mr", fmt("margin-right: {};", { i(1, "1rem") })),
  s("mb", fmt("margin-bottom: {};", { i(1, "1rem") })),
  s("ml", fmt("margin-left: {};", { i(1, "1rem") })),
  s("mx", fmt([[
margin-left: {};
margin-right: {};
]], {
    i(1, "auto"),
    f(function(args) return args[1][1] end, { 1 }),
  })),
  s("my", fmt([[
margin-top: {};
margin-bottom: {};
]], {
    i(1, "1rem"),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Padding
  s("p", fmt("padding: {};", { i(1, "1rem") })),
  s("pt", fmt("padding-top: {};", { i(1, "1rem") })),
  s("pr", fmt("padding-right: {};", { i(1, "1rem") })),
  s("pb", fmt("padding-bottom: {};", { i(1, "1rem") })),
  s("pl", fmt("padding-left: {};", { i(1, "1rem") })),
  s("px", fmt([[
padding-left: {};
padding-right: {};
]], {
    i(1, "1rem"),
    f(function(args) return args[1][1] end, { 1 }),
  })),
  s("py", fmt([[
padding-top: {};
padding-bottom: {};
]], {
    i(1, "1rem"),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Border
  s("border", fmt("border: {} {} {};", {
    i(1, "1px"),
    c(2, { t("solid"), t("dashed"), t("dotted"), t("double"), t("none") }),
    i(3, "#000"),
  })),

  -- Border radius
  s("br", fmt("border-radius: {};", { i(1, "0.5rem") })),

  -- Box shadow
  s("shadow", fmt("box-shadow: {} {} {} {} {};", {
    i(1, "0"),
    i(2, "2px"),
    i(3, "4px"),
    i(4, "0"),
    i(5, "rgba(0, 0, 0, 0.1)"),
  })),

  -- Text shadow
  s("tshadow", fmt("text-shadow: {} {} {} {};", {
    i(1, "1px"),
    i(2, "1px"),
    i(3, "2px"),
    i(4, "rgba(0, 0, 0, 0.5)"),
  })),

  -- Font
  s("font", fmt([[
font-family: {};
font-size: {};
font-weight: {};
]], {
    i(1, "sans-serif"),
    i(2, "1rem"),
    c(3, { t("400"), t("500"), t("600"), t("700"), t("bold") }),
  })),

  -- Font size
  s("fs", fmt("font-size: {};", { i(1, "1rem") })),

  -- Font weight
  s("fw", fmt("font-weight: {};", {
    c(1, { t("400"), t("500"), t("600"), t("700"), t("bold") }),
  })),

  -- Line height
  s("lh", fmt("line-height: {};", { i(1, "1.5") })),

  -- Letter spacing
  s("ls", fmt("letter-spacing: {};", { i(1, "0.05em") })),

  -- Text align
  s("ta", fmt("text-align: {};", {
    c(1, { t("center"), t("left"), t("right"), t("justify") }),
  })),

  -- Text decoration
  s("td", fmt("text-decoration: {};", {
    c(1, { t("none"), t("underline"), t("line-through"), t("overline") }),
  })),

  -- Text transform
  s("tt", fmt("text-transform: {};", {
    c(1, { t("uppercase"), t("lowercase"), t("capitalize"), t("none") }),
  })),

  -- Color
  s("c", fmt("color: {};", { i(1, "#000") })),

  -- Background color
  s("bg", fmt("background-color: {};", { i(1, "#fff") })),

  -- Background image
  s("bgi", fmt([[
background-image: url('{}');
background-size: {};
background-position: {};
background-repeat: {};
]], {
    i(1),
    c(2, { t("cover"), t("contain"), t("100% 100%") }),
    c(3, { t("center"), t("top"), t("bottom") }),
    c(4, { t("no-repeat"), t("repeat"), t("repeat-x"), t("repeat-y") }),
  })),

  -- Gradient
  s("gradient", fmt("background: linear-gradient({}, {}, {});", {
    c(1, { t("to right"), t("to bottom"), t("to top"), t("45deg"), t("135deg") }),
    i(2, "#000"),
    i(3, "#fff"),
  })),

  -- Transition
  s("trans", fmt("transition: {} {} {};", {
    c(1, { t("all"), t("transform"), t("opacity"), t("background-color"), t("color") }),
    i(2, "0.3s"),
    c(3, { t("ease"), t("ease-in"), t("ease-out"), t("ease-in-out"), t("linear") }),
  })),

  -- Transform
  s("transform", fmt("transform: {};", {
    c(1, {
      t("translateX(0)"),
      t("translateY(0)"),
      t("scale(1)"),
      t("rotate(0deg)"),
      t("skew(0deg)"),
    }),
  })),

  -- Hover state
  s("hover", fmt([[
&:hover {{
    {}
}}
]], {
    i(1),
  })),

  -- Media query
  s("mq", fmt([[
@media ({}:{}) {{
    {}
}}
]], {
    c(1, { t("min-width"), t("max-width") }),
    c(2, { t("768px"), t("1024px"), t("1200px"), t("480px"), t("640px") }),
    i(3),
  })),

  -- Keyframes
  s("keyframes", fmt([[
@keyframes {} {{
    0% {{
        {}
    }}
    100% {{
        {}
    }}
}}
]], {
    i(1, "animationName"),
    i(2),
    i(3),
  })),

  -- Animation
  s("anim", fmt("animation: {} {} {} {};", {
    i(1, "name"),
    i(2, "1s"),
    c(3, { t("ease"), t("linear"), t("ease-in"), t("ease-out"), t("ease-in-out") }),
    c(4, { t("forwards"), t("infinite"), t("alternate") }),
  })),

  -- Overflow
  s("overflow", fmt("overflow: {};", {
    c(1, { t("hidden"), t("auto"), t("scroll"), t("visible") }),
  })),

  -- Cursor
  s("cursor", fmt("cursor: {};", {
    c(1, { t("pointer"), t("default"), t("not-allowed"), t("grab"), t("text"), t("move") }),
  })),

  -- Z-index
  s("z", fmt("z-index: {};", { i(1, "1") })),

  -- Opacity
  s("op", fmt("opacity: {};", { i(1, "1") })),

  -- Object fit
  s("of", fmt("object-fit: {};", {
    c(1, { t("cover"), t("contain"), t("fill"), t("none"), t("scale-down") }),
  })),

  -- Aspect ratio
  s("ar", fmt("aspect-ratio: {};", {
    c(1, { t("16 / 9"), t("4 / 3"), t("1 / 1"), t("21 / 9") }),
  })),

  -- CSS variable
  s("var", fmt("var(--{});", { i(1, "name") })),

  -- Define CSS variable
  s("defvar", fmt("--{}: {};", {
    i(1, "name"),
    i(2, "value"),
  })),

  -- Clamp
  s("clamp", fmt("clamp({}, {}, {});", {
    i(1, "1rem"),
    i(2, "5vw"),
    i(3, "3rem"),
  })),

  -- Truncate text
  s("truncate", t({
    "overflow: hidden;",
    "text-overflow: ellipsis;",
    "white-space: nowrap;",
  })),

  -- Line clamp (multi-line truncate)
  s("lineclamp", fmt([[
display: -webkit-box;
-webkit-line-clamp: {};
-webkit-box-orient: vertical;
overflow: hidden;
]], {
    i(1, "3"),
  })),

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

  -- Reset button
  s("btnreset", t({
    "background: none;",
    "border: none;",
    "padding: 0;",
    "cursor: pointer;",
  })),

  -- Reset list
  s("listreset", t({
    "list-style: none;",
    "padding: 0;",
    "margin: 0;",
  })),
}
