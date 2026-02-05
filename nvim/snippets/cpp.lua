-- C++ snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Main function
  s("main", fmt([[
int main(int argc, char* argv[]) {{
    {}
    return 0;
}}
]], {
    i(1),
  })),

  -- Main simple
  s("mains", fmt([[
int main() {{
    {}
    return 0;
}}
]], {
    i(1),
  })),

  -- Include
  s("inc", fmt("#include <{}>", { i(1, "iostream") })),

  -- Include local
  s("incl", fmt('#include "{}"', { i(1, "header.hpp") })),

  -- Common includes
  s("incs", t({
    "#include <iostream>",
    "#include <string>",
    "#include <vector>",
    "#include <memory>",
  })),

  -- Using namespace std
  s("uns", t("using namespace std;")),

  -- Class
  s("class", fmt([[
class {} {{
public:
    {}();
    ~{}();

private:
    {}
}};
]], {
    i(1, "Name"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    i(2),
  })),

  -- Class with inheritance
  s("classi", fmt([[
class {} : public {} {{
public:
    {}();
    ~{}() override;

private:
    {}
}};
]], {
    i(1, "Derived"),
    i(2, "Base"),
    f(function(args) return args[1][1] end, { 1 }),
    f(function(args) return args[1][1] end, { 1 }),
    i(3),
  })),

  -- Struct
  s("struct", fmt([[
struct {} {{
    {}
}};
]], {
    i(1, "Name"),
    i(2),
  })),

  -- Function
  s("fn", fmt([[
{} {}({}) {{
    {}
}}
]], {
    i(1, "void"),
    i(2, "name"),
    i(3),
    i(4),
  })),

  -- Method implementation
  s("method", fmt([[
{} {}::{}({}) {{
    {}
}}
]], {
    i(1, "void"),
    i(2, "ClassName"),
    i(3, "method"),
    i(4),
    i(5),
  })),

  -- Template function
  s("tfn", fmt([[
template <typename {}>
{} {}({}) {{
    {}
}}
]], {
    i(1, "T"),
    i(2, "T"),
    i(3, "name"),
    i(4),
    i(5),
  })),

  -- Template class
  s("tclass", fmt([[
template <typename {}>
class {} {{
public:
    {}
private:
    {}
}};
]], {
    i(1, "T"),
    i(2, "Name"),
    i(3),
    i(4),
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

  -- For loop
  s("for", fmt([[
for (int {} = 0; {} < {}; {}++) {{
    {}
}}
]], {
    i(1, "i"),
    f(function(args) return args[1][1] end, { 1 }),
    i(2, "n"),
    f(function(args) return args[1][1] end, { 1 }),
    i(3),
  })),

  -- Range-based for
  s("forr", fmt([[
for (const auto& {} : {}) {{
    {}
}}
]], {
    i(1, "item"),
    i(2, "container"),
    i(3),
  })),

  -- Range-based for (non-const)
  s("forrm", fmt([[
for (auto& {} : {}) {{
    {}
}}
]], {
    i(1, "item"),
    i(2, "container"),
    i(3),
  })),

  -- While loop
  s("while", fmt([[
while ({}) {{
    {}
}}
]], {
    i(1, "condition"),
    i(2),
  })),

  -- Switch
  s("switch", fmt([[
switch ({}) {{
    case {}:
        {}
        break;
    default:
        {}
        break;
}}
]], {
    i(1, "var"),
    i(2, "value"),
    i(3),
    i(4),
  })),

  -- Try-catch
  s("try", fmt([[
try {{
    {}
}} catch (const {}& e) {{
    {}
}}
]], {
    i(1),
    i(2, "std::exception"),
    i(3, "std::cerr << e.what() << std::endl"),
  })),

  -- Cout
  s("cout", fmt('std::cout << {} << std::endl;', { i(1) })),

  -- Cin
  s("cin", fmt('std::cin >> {};', { i(1) })),

  -- Cerr
  s("cerr", fmt('std::cerr << {} << std::endl;', { i(1) })),

  -- Vector
  s("vec", fmt("std::vector<{}> {}{};", {
    i(1, "int"),
    i(2, "v"),
    i(3),
  })),

  -- String
  s("str", fmt('std::string {} = "{}";', {
    i(1, "s"),
    i(2),
  })),

  -- Unique pointer
  s("uptr", fmt("std::unique_ptr<{}> {} = std::make_unique<{}>();", {
    i(1, "Type"),
    i(2, "ptr"),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Shared pointer
  s("sptr", fmt("std::shared_ptr<{}> {} = std::make_shared<{}>();", {
    i(1, "Type"),
    i(2, "ptr"),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Lambda
  s("lam", fmt("[{}]({}) {{ {} }}", {
    i(1),
    i(2),
    i(3),
  })),

  -- Auto
  s("auto", fmt("auto {} = {};", {
    i(1, "var"),
    i(2),
  })),

  -- Const auto ref
  s("car", fmt("const auto& {} = {};", {
    i(1, "var"),
    i(2),
  })),

  -- Namespace
  s("ns", fmt([[
namespace {} {{

{}

}} // namespace {}
]], {
    i(1, "name"),
    i(2),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Header guard
  s("guard", fmt([[
#ifndef {}_HPP
#define {}_HPP

{}

#endif // {}_HPP
]], {
    i(1, "NAME"),
    f(function(args) return args[1][1] end, { 1 }),
    i(2),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Pragma once
  s("pragma", t("#pragma once")),

  -- Constructor
  s("ctor", fmt([[
{}({}) {{
    {}
}}
]], {
    i(1, "ClassName"),
    i(2),
    i(3),
  })),

  -- Destructor
  s("dtor", fmt([[
~{}() {{
    {}
}}
]], {
    i(1, "ClassName"),
    i(2),
  })),

  -- Enum class
  s("enumc", fmt([[
enum class {} {{
    {}
}};
]], {
    i(1, "Name"),
    i(2),
  })),
}
