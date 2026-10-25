local vim = vim

vim.pack.add({
  {
    src = "https://github.com/saghen/blink.cmp",
    version = "v1.10.2",
  },
})

local blink = require("blink.cmp")

local function cycle_signature(direction)
  local trigger = require("blink.cmp.signature.trigger")
  local context = trigger.context
  local signature_help = context and context.active_signature_help
  local signatures = signature_help and signature_help.signatures

  if not signatures or #signatures < 2 then
    return false
  end

  vim.schedule(function()
    if trigger.context ~= context then
      return
    end

    local current = trigger.context.active_signature_help
    if not current or not current.signatures or #current.signatures < 2 then
      return
    end

    current = vim.deepcopy(current)
    current.activeSignature = ((current.activeSignature or 0) + direction) % #current.signatures
    trigger.set_active_signature_help(current)
    require("blink.cmp.signature.window").open_with_signature_help(context, current)
  end)
  return true
end

local function expand_cpp_member_definition(ctx, items)
  if vim.bo[ctx.bufnr].filetype ~= "cpp" then
    return items
  end

  local filename = vim.api.nvim_buf_get_name(ctx.bufnr)
  if not (filename:match("%.cc$") or filename:match("%.cpp$") or filename:match("%.cxx$")) then
    return items
  end

  local before_cursor = ctx.line:sub(1, ctx.cursor[2])
  local qualifier = before_cursor:match("^%s*(.-)::[~%w_]*$")
  if not qualifier or qualifier:match("^%s*return%s") then
    return items
  end

  local has_return_type = qualifier:find("%s") ~= nil
  local class_name = qualifier:match("([%w_]+)%s*$")
  local kinds = require("blink.cmp.types").CompletionItemKind

  for _, item in ipairs(items) do
    local label = item.label:match("^%s*(.-)%s*$")
    local label_detail = type(item.labelDetails) == "table" and item.labelDetails.detail or nil
    local signature = label

    if label_detail and label_detail:match("^%s*%(") and not label:find("%b()") then
      signature = label .. label_detail
    end

    local is_method = item.kind == kinds.Method or item.kind == kinds.Function
    local is_constructor = item.kind == kinds.Constructor
      and class_name
      and signature:match("^" .. vim.pesc(class_name) .. "%s*%(")

    if item.client_name == "clangd" and signature:find("%b()") and (has_return_type and is_method or is_constructor) then
      item.insertText = signature
      item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText
      if item.textEdit then
        item.textEdit.newText = signature
      end
    end
  end

  return items
end

blink.setup({
  keymap = {
    preset = "none",
    ["<C-l>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = {
      function(cmp)
        if cmp.is_visible() then
          return cmp.select_next({ auto_insert = true })
        end
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = {
      function(cmp)
        if cmp.is_visible() then
          return cmp.select_prev({ auto_insert = true })
        end
      end,
      "snippet_backward",
      "fallback",
    },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<M-n>"] = {
      function() return cycle_signature(1) end,
      "fallback",
    },
    ["<M-p>"] = {
      function() return cycle_signature(-1) end,
      "fallback",
    },
    ["<C-e>"] = { "cancel", "fallback" },
    ["<C-c>"] = { "cancel", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    list = {
      selection = {
        preselect = false,
        auto_insert = true,
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
    menu = {
      draw = {
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "source_name" },
        },
      },
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    per_filetype = {
      ruby = { "lsp", "path", "snippets" },
    },
    providers = {
      lsp = {
        transform_items = expand_cpp_member_definition,
      },
    },
  },
  fuzzy = {
    implementation = "lua",
  },
  signature = {
    enabled = true,
  },
  cmdline = {
    enabled = false,
  },
})

vim.lsp.config("*", {
  capabilities = blink.get_lsp_capabilities(),
})
