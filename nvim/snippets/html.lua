-- HTML snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- HTML5 boilerplate
  s("html5", fmt([[
<!DOCTYPE html>
<html lang="{}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{}</title>
    {}
</head>
<body>
    {}
</body>
</html>
]], {
    i(1, "en"),
    i(2, "Document"),
    i(3),
    i(4),
  })),

  -- Div
  s("div", fmt([[
<div class="{}">
    {}
</div>
]], {
    i(1),
    i(2),
  })),

  -- Div with id
  s("divi", fmt([[
<div id="{}">
    {}
</div>
]], {
    i(1),
    i(2),
  })),

  -- Span
  s("span", fmt('<span class="{}">{}</span>', {
    i(1),
    i(2),
  })),

  -- Paragraph
  s("p", fmt('<p class="{}">{}</p>', {
    i(1),
    i(2),
  })),

  -- Link
  s("a", fmt('<a href="{}"{}>{}</a>', {
    i(1, "#"),
    c(2, { t(""), t(' target="_blank" rel="noopener noreferrer"') }),
    i(3, "Link"),
  })),

  -- Image
  s("img", fmt('<img src="{}" alt="{}"{} />', {
    i(1),
    i(2),
    c(3, { t(""), t(' loading="lazy"') }),
  })),

  -- Button
  s("btn", fmt('<button type="{}" class="{}">{}</button>', {
    c(1, { t("button"), t("submit"), t("reset") }),
    i(2),
    i(3, "Button"),
  })),

  -- Input
  s("input", fmt('<input type="{}" name="{}" id="{}" placeholder="{}"{} />', {
    c(1, { t("text"), t("email"), t("password"), t("number"), t("tel"), t("url"), t("search"), t("date") }),
    i(2, "name"),
    i(3, "id"),
    i(4),
    i(5),
  })),

  -- Label
  s("label", fmt('<label for="{}">{}</label>', {
    i(1, "id"),
    i(2, "Label"),
  })),

  -- Form
  s("form", fmt([[
<form action="{}" method="{}">
    {}
    <button type="submit">{}</button>
</form>
]], {
    i(1, "#"),
    c(2, { t("POST"), t("GET") }),
    i(3),
    i(4, "Submit"),
  })),

  -- Select
  s("select", fmt([[
<select name="{}" id="{}">
    <option value="">{}</option>
    <option value="{}">{}</option>
</select>
]], {
    i(1, "name"),
    i(2, "id"),
    i(3, "Select an option"),
    i(4, "value"),
    i(5, "Option"),
  })),

  -- Textarea
  s("textarea", fmt('<textarea name="{}" id="{}" cols="{}" rows="{}" placeholder="{}"></textarea>', {
    i(1, "name"),
    i(2, "id"),
    i(3, "30"),
    i(4, "10"),
    i(5),
  })),

  -- Unordered list
  s("ul", fmt([[
<ul class="{}">
    <li>{}</li>
</ul>
]], {
    i(1),
    i(2),
  })),

  -- Ordered list
  s("ol", fmt([[
<ol class="{}">
    <li>{}</li>
</ol>
]], {
    i(1),
    i(2),
  })),

  -- List item
  s("li", fmt("<li>{}</li>", { i(1) })),

  -- Table
  s("table", fmt([[
<table>
    <thead>
        <tr>
            <th>{}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>{}</td>
        </tr>
    </tbody>
</table>
]], {
    i(1, "Header"),
    i(2, "Data"),
  })),

  -- Section
  s("section", fmt([[
<section class="{}">
    {}
</section>
]], {
    i(1),
    i(2),
  })),

  -- Article
  s("article", fmt([[
<article class="{}">
    {}
</article>
]], {
    i(1),
    i(2),
  })),

  -- Header
  s("header", fmt([[
<header class="{}">
    {}
</header>
]], {
    i(1),
    i(2),
  })),

  -- Footer
  s("footer", fmt([[
<footer class="{}">
    {}
</footer>
]], {
    i(1),
    i(2),
  })),

  -- Nav
  s("nav", fmt([[
<nav class="{}">
    <ul>
        <li><a href="{}">{}</a></li>
    </ul>
</nav>
]], {
    i(1),
    i(2, "#"),
    i(3, "Link"),
  })),

  -- Main
  s("main", fmt([[
<main class="{}">
    {}
</main>
]], {
    i(1),
    i(2),
  })),

  -- Aside
  s("aside", fmt([[
<aside class="{}">
    {}
</aside>
]], {
    i(1),
    i(2),
  })),

  -- Headings
  s("h1", fmt('<h1 class="{}">{}</h1>', { i(1), i(2, "Heading") })),
  s("h2", fmt('<h2 class="{}">{}</h2>', { i(1), i(2, "Heading") })),
  s("h3", fmt('<h3 class="{}">{}</h3>', { i(1), i(2, "Heading") })),

  -- Script tag
  s("script", fmt('<script src="{}"></script>', { i(1) })),

  -- Script inline
  s("scripti", fmt([[
<script>
    {}
</script>
]], {
    i(1),
  })),

  -- Link CSS
  s("link", fmt('<link rel="stylesheet" href="{}">', { i(1, "styles.css") })),

  -- Meta tags
  s("meta", fmt('<meta name="{}" content="{}">', {
    c(1, { t("description"), t("keywords"), t("author"), t("robots") }),
    i(2),
  })),

  -- Comment
  s("comment", fmt("<!-- {} -->", { i(1) })),

  -- Video
  s("video", fmt([[
<video src="{}" controls{}>
    Your browser does not support the video tag.
</video>
]], {
    i(1),
    c(2, { t(""), t(" autoplay"), t(" autoplay muted loop") }),
  })),

  -- Audio
  s("audio", fmt([[
<audio src="{}" controls>
    Your browser does not support the audio tag.
</audio>
]], {
    i(1),
  })),

  -- Iframe
  s("iframe", fmt('<iframe src="{}" width="{}" height="{}" frameborder="0"></iframe>', {
    i(1),
    i(2, "560"),
    i(3, "315"),
  })),

  -- Picture (responsive images)
  s("picture", fmt([[
<picture>
    <source srcset="{}" media="(min-width: {})">
    <img src="{}" alt="{}">
</picture>
]], {
    i(1),
    i(2, "768px"),
    i(3),
    i(4),
  })),
}
