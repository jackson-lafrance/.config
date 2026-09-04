local vim = vim
local map = vim.keymap.set

vim.pack.add({
  "https://github.com/ThePrimeagen/99",
})

local _99 = require("99")
local Providers = require("99.providers")

-- 99 provider backed by `pi -p`. pi owns auth and routing: the Shopify AI proxy
-- on the work machine, personal providers at home. 99 asks the agent to write
-- its answer into a temp file, so pi keeps its default tools.
local PiProvider = setmetatable({}, { __index = Providers.BaseProvider })

--- @param query string
--- @param context _99.Prompt
--- @return string[]
function PiProvider._build_command(_, query, context)
  local cmd = { "pi", "-p", "--no-session" }
  if context.model and context.model ~= "" then
    vim.list_extend(cmd, { "--model", context.model })
  end
  vim.list_extend(cmd, { "--", query })
  return cmd
end

function PiProvider._get_provider_name()
  return "PiProvider"
end

--- Empty means "pi's configured default model".
function PiProvider._get_default_model()
  return ""
end

--- Parses `pi --list-models` (a table: provider, model, ...) into provider/model ids.
--- @param callback fun(models: string[]|nil, err: string|nil)
function PiProvider.fetch_models(callback)
  vim.system({ "pi", "--list-models" }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        callback(nil, "pi --list-models failed: " .. (obj.stderr or ""))
        return
      end
      local models = {}
      for i, line in ipairs(vim.split(obj.stdout, "\n", { trimempty = true })) do
        local provider, model = line:match("^(%S+)%s+(%S+)")
        if i > 1 and provider and model then
          table.insert(models, provider .. "/" .. model)
        end
      end
      callback(models, nil)
    end)
  end)
end

_99.setup({
  provider = PiProvider,
  completion = {
    -- `@file` completion runs `git ls-files` on the repo root; in World that is
    -- 1.7M paths. Write the path in the prompt instead: pi reads files itself.
    files = { enabled = false },
  },
})

map("x", "<leader>9v", function() _99.visual() end, { desc = "99: rewrite selection with a prompt" })
map("n", "<leader>9s", function() _99.search() end, { desc = "99: search project, results to quickfix" })
map("n", "<leader>9o", function() _99.open() end, { desc = "99: open last result" })
map("n", "<leader>9x", function() _99.stop_all_requests() end, { desc = "99: stop all requests" })
map("n", "<leader>9l", function() _99.view_logs() end, { desc = "99: view logs" })
map("n", "<leader>9m", function() require("99.extensions.fzf_lua").select_model() end, { desc = "99: pick model" })
