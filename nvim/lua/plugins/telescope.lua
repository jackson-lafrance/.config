local vim = vim
local map = vim.keymap.set
local project = require("lib.project")

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/aznhe21/actions-preview.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
})

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local actions_layout = require("telescope.actions.layout")

-- Search backends, glob/regex filters, and zone detection live in lib/project
-- so the Ruby reference jumper shares them. Only picker wiring stays here.
local function find_files_command(opts)
  local include_noisy = type(opts) == "table" and opts.include_noisy == true

  return project.rg_files_command(include_noisy)
end

local function prompt_title(base, include_hidden, include_noisy)
  local suffixes = {}

  if include_hidden then
    table.insert(suffixes, "+hidden")
  end

  if include_noisy then
    table.insert(suffixes, "+noisy")
  end

  if #suffixes == 0 then
    return base
  end

  return base .. " (" .. table.concat(suffixes, ", ") .. ")"
end

local function make_toggle_attach(reopen, state)
  return function(prompt_bufnr, map_picker)
    local function reopen_with(overrides)
      local prompt = action_state.get_current_line()

      actions.close(prompt_bufnr)
      vim.schedule(function()
        reopen(prompt, overrides)
      end)
    end

    local function toggle_hidden()
      reopen_with({ hidden = not state.hidden, include_hidden = not state.hidden })
    end

    local function toggle_noisy()
      reopen_with({ include_noisy = not state.include_noisy })
    end

    map_picker({ "i", "n" }, "<C-h>", toggle_hidden)
    map_picker({ "i", "n" }, "<M-h>", toggle_hidden)
    map_picker({ "i", "n" }, "<C-g>", toggle_noisy)
    map_picker({ "i", "n" }, "<M-g>", toggle_noisy)

    return true
  end
end

local function find_files(opts)
  opts = vim.tbl_extend("force", {
    cwd = project.root(),
    hidden = false,
  }, opts or {})

  local include_hidden = opts.hidden == true
  local include_noisy = opts.include_noisy == true

  -- Inside a World zone this reads the git index; everywhere else it is rg.
  opts.find_command = project.list_files_command(opts.cwd, include_hidden, include_noisy)
  opts.prompt_title = prompt_title("Find Files", include_hidden, include_noisy)
  opts.attach_mappings = make_toggle_attach(function(prompt, overrides)
    find_files(vim.tbl_extend("force", opts, overrides, {
      default_text = prompt,
    }))
  end, { hidden = include_hidden, include_noisy = include_noisy })

  builtin.find_files(opts)
end

local function live_grep(opts)
  opts = vim.tbl_extend("force", {
    cwd = project.root(),
    include_hidden = false,
  }, opts or {})

  local include_hidden = opts.include_hidden == true
  local include_noisy = opts.include_noisy == true

  -- Inside a World zone, search the prebuilt worldgrep index (~0.5s vs ~5s for
  -- rg on the same query); everywhere else use rg directly.
  local zone = project.world_zone(opts.cwd)

  if zone and project.has_worldgrep() then
    -- Paths come back relative to the worktree toplevel, so telescope has to
    -- resolve them from there.
    opts.cwd = zone.toplevel
    opts.vimgrep_arguments = project.worldgrep_vimgrep_arguments(zone, include_hidden, include_noisy)
    -- additional_args would append rg-style flags to the wg command; avoid it.
    opts.additional_args = function() return {} end
    opts.use_regex = true -- wg takes a regexp, telescope won't add -F/--fixed-strings
  else
    opts.additional_args = function()
      return project.rg_grep_args(include_hidden, include_noisy)
    end
  end

  opts.prompt_title = prompt_title("Live Grep", include_hidden, include_noisy)
  opts.attach_mappings = make_toggle_attach(function(prompt, overrides)
    live_grep(vim.tbl_extend("force", opts, overrides, {
      default_text = prompt,
    }))
  end, { hidden = include_hidden, include_noisy = include_noisy })

  builtin.live_grep(opts)
end

telescope.setup({
  defaults = {
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top",
      preview_cutoff = 40,
    },
    preview = {
      hide_on_startup = true,
      timeout = 100,
      filesize_limit = 1,
      highlight_limit = 0.5,
      treesitter = false,
    },
    mappings = {
      i = {
        ["<C-p>"] = actions_layout.toggle_preview,
      },
      n = {
        ["<C-p>"] = actions_layout.toggle_preview,
      },
    },
  },
  pickers = {
    find_files = {
      hidden = false,
      find_command = find_files_command,
    },
    live_grep = {
      additional_args = function()
        return project.rg_grep_args(false, false)
      end,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

pcall(telescope.load_extension, "fzf")
telescope.load_extension("ui-select")

require("actions-preview").setup({
  backend = { "telescope" },
  extensions = { "env" },
  telescope = vim.tbl_extend(
    "force",
    require("telescope.themes").get_dropdown(),
    {}
  ),
})

map("n", "<leader>ff", find_files, { desc = "Telescope find files in project/zone" })
map("n", "<leader>fw", live_grep, { desc = "Telescope live grep in project/zone" })

map("n", "<leader>fF", function()
  find_files({ cwd = vim.uv.cwd() })
end, { desc = "Telescope find files from cwd" })

map("n", "<leader>fW", function()
  live_grep({ cwd = vim.uv.cwd() })
end, { desc = "Telescope live grep from cwd" })

map("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
map("n", "<leader>gls", function()
  builtin.git_status({
    preview = {
      hide_on_startup = false,
    },
  })
end, { desc = "Git status with preview" })
map("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
map("n", "<leader>sd", builtin.diagnostics, { desc = "Diagnostics" })
