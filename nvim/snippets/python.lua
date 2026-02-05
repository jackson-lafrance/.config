-- Python snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Function
  s("def", fmt([[
def {}({}):
    {}
]], {
    i(1, "name"),
    i(2),
    i(3, "pass"),
  })),

  -- Async function
  s("adef", fmt([[
async def {}({}):
    {}
]], {
    i(1, "name"),
    i(2),
    i(3, "pass"),
  })),

  -- Function with docstring
  s("defd", fmt([[
def {}({}):
    """{}"""
    {}
]], {
    i(1, "name"),
    i(2),
    i(3, "Description"),
    i(4, "pass"),
  })),

  -- Function with type hints
  s("deft", fmt([[
def {}({}) -> {}:
    {}
]], {
    i(1, "name"),
    i(2),
    i(3, "None"),
    i(4, "pass"),
  })),

  -- Class
  s("class", fmt([[
class {}:
    def __init__(self{}):
        {}
]], {
    i(1, "Name"),
    i(2),
    i(3, "pass"),
  })),

  -- Class with inheritance
  s("classi", fmt([[
class {}({}):
    def __init__(self{}):
        super().__init__()
        {}
]], {
    i(1, "Name"),
    i(2, "Base"),
    i(3),
    i(4, "pass"),
  })),

  -- Dataclass
  s("dc", fmt([[
@dataclass
class {}:
    {}: {}
]], {
    i(1, "Name"),
    i(2, "field"),
    i(3, "str"),
  })),

  -- If statement
  s("if", fmt([[
if {}:
    {}
]], {
    i(1, "condition"),
    i(2, "pass"),
  })),

  -- If-else
  s("ife", fmt([[
if {}:
    {}
else:
    {}
]], {
    i(1, "condition"),
    i(2, "pass"),
    i(3, "pass"),
  })),

  -- If-elif-else
  s("ifei", fmt([[
if {}:
    {}
elif {}:
    {}
else:
    {}
]], {
    i(1, "condition"),
    i(2, "pass"),
    i(3, "condition"),
    i(4, "pass"),
    i(5, "pass"),
  })),

  -- For loop
  s("for", fmt([[
for {} in {}:
    {}
]], {
    i(1, "item"),
    i(2, "items"),
    i(3, "pass"),
  })),

  -- For enumerate
  s("fore", fmt([[
for {}, {} in enumerate({}):
    {}
]], {
    i(1, "i"),
    i(2, "item"),
    i(3, "items"),
    i(4, "pass"),
  })),

  -- While loop
  s("while", fmt([[
while {}:
    {}
]], {
    i(1, "condition"),
    i(2, "pass"),
  })),

  -- Try-except
  s("try", fmt([[
try:
    {}
except {} as e:
    {}
]], {
    i(1, "pass"),
    i(2, "Exception"),
    i(3, "raise"),
  })),

  -- Try-except-finally
  s("tryf", fmt([[
try:
    {}
except {} as e:
    {}
finally:
    {}
]], {
    i(1, "pass"),
    i(2, "Exception"),
    i(3, "raise"),
    i(4, "pass"),
  })),

  -- With statement
  s("with", fmt([[
with {} as {}:
    {}
]], {
    i(1, "open('file.txt')"),
    i(2, "f"),
    i(3, "pass"),
  })),

  -- Context manager with open
  s("witho", fmt([[
with open('{}', '{}') as {}:
    {}
]], {
    i(1, "filename"),
    c(2, { t("r"), t("w"), t("a"), t("rb"), t("wb") }),
    i(3, "f"),
    i(4, "pass"),
  })),

  -- List comprehension
  s("lc", fmt("[{} for {} in {}]", {
    i(3, "x"),
    i(1, "x"),
    i(2, "items"),
  })),

  -- Dict comprehension
  s("dc", fmt("{{{}: {} for {} in {}}}", {
    i(3, "k"),
    i(4, "v"),
    i(1, "k, v"),
    i(2, "items"),
  })),

  -- Lambda
  s("lam", fmt("lambda {}: {}", {
    i(1, "x"),
    i(2, "x"),
  })),

  -- Print
  s("pr", fmt("print({})", { i(1) })),

  -- Print f-string
  s("prf", fmt('print(f"{}")', { i(1) })),

  -- Main block
  s("main", fmt([[
if __name__ == "__main__":
    {}
]], {
    i(1, "main()"),
  })),

  -- Import
  s("imp", fmt("import {}", { i(1, "module") })),

  -- From import
  s("from", fmt("from {} import {}", {
    i(1, "module"),
    i(2, "name"),
  })),

  -- Type hints
  s("hint", fmt("{}: {} = {}", {
    i(1, "name"),
    i(2, "type"),
    i(3),
  })),

  -- Assert
  s("ass", fmt("assert {}, '{}'", {
    i(1, "condition"),
    i(2, "message"),
  })),

  -- Decorator
  s("dec", fmt([[
def {}(func):
    def wrapper(*args, **kwargs):
        {}
        return func(*args, **kwargs)
    return wrapper
]], {
    i(1, "decorator"),
    i(2),
  })),

  -- Property
  s("prop", fmt([[
@property
def {}(self):
    return self._{}

@{}.setter
def {}(self, value):
    self._{} = value
]], {
    i(1, "name"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Pytest test function
  s("test", fmt([[
def test_{}():
    {}
    assert {}
]], {
    i(1, "name"),
    i(2),
    i(3, "True"),
  })),
}
