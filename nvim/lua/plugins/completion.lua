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
