-- C snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- Main function
  s("mainc", fmt([[
int main(int argc, char *argv[]) {{
    {}
    return 0;
}}
]], {
    i(1),
  })),

  -- Main simple
  s("main", fmt([[
int main(void) {{
    {}
    return 0;
}}
]], {
    i(1),
  })),

  -- Include
  s("inc", fmt("#include <{}>", { i(1, "stdio.h") })),

  -- Include local
  s("incl", fmt('#include "{}"', { i(1, "header.h") })),

  -- Common includes
  s("incs", t({
    "#include <stdio.h>",
    "#include <stdlib.h>",
    "#include <string.h>",
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

  -- Function declaration
  s("fnd", fmt("{} {}({});", {
    i(1, "void"),
    i(2, "name"),
    i(3),
  })),

  -- Struct
  s("struct", fmt([[
typedef struct {{
    {}
}} {};
]], {
    i(2),
    i(1, "Name"),
  })),

  -- Enum
  s("enum", fmt([[
typedef enum {{
    {}
}} {};
]], {
    i(2),
    i(1, "Name"),
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

  -- While loop
  s("while", fmt([[
while ({}) {{
    {}
}}
]], {
    i(1, "condition"),
    i(2),
  })),

  -- Do-while loop
  s("do", fmt([[
do {{
    {}
}} while ({});
]], {
    i(1),
    i(2, "condition"),
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

  -- Printf
  s("pr", fmt('printf("{}\\n"{});', {
    i(1, "%s"),
    i(2),
  })),

  -- Printf with variable
  s("prf", fmt('printf("{}: %{}\\n", {});', {
    i(1, "var"),
    c(2, { t("d"), t("s"), t("f"), t("c"), t("p"), t("ld"), t("lu") }),
    i(3, "var"),
  })),

  -- Scanf
  s("sc", fmt('scanf("%{}", &{});', {
    c(1, { t("d"), t("s"), t("f"), t("c"), t("ld") }),
    i(2, "var"),
  })),

  -- Malloc
  s("mal", fmt("{} *{} = ({} *)malloc({} * sizeof({}));", {
    i(1, "int"),
    i(2, "ptr"),
    f(function(args) return args[1][1] end, { 1 }),
    i(3, "n"),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Calloc
  s("cal", fmt("{} *{} = ({} *)calloc({}, sizeof({}));", {
    i(1, "int"),
    i(2, "ptr"),
    f(function(args) return args[1][1] end, { 1 }),
    i(3, "n"),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Free
  s("free", fmt([[
free({});
{} = NULL;
]], {
    i(1, "ptr"),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Header guard
  s("guard", fmt([[
#ifndef {}_H
#define {}_H

{}

#endif /* {}_H */
]], {
    i(1, "NAME"),
    f(function(args) return args[1][1] end, { 1 }),
    i(2),
    f(function(args) return args[1][1] end, { 1 }),
  })),

  -- Define
  s("def", fmt("#define {} {}", {
    i(1, "NAME"),
    i(2, "value"),
  })),

  -- Ternary
  s("tern", fmt("{} ? {} : {}", {
    i(1, "condition"),
    i(2, "true"),
    i(3, "false"),
  })),

  -- Null check
  s("null", fmt([[
if ({} == NULL) {{
    {}
    return {};
}}
]], {
    i(1, "ptr"),
    i(2, 'fprintf(stderr, "Memory allocation failed\\n")'),
    i(3, "1"),
  })),

  -- File open
  s("fopen", fmt([[
FILE *{} = fopen("{}", "{}");
if ({} == NULL) {{
    perror("Error opening file");
    return 1;
}}
]], {
    i(1, "fp"),
    i(2, "filename"),
    c(3, { t("r"), t("w"), t("a"), t("rb"), t("wb") }),
    f(function(args) return args[1][1] end, { 1 }),
  })),
}
