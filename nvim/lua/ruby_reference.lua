-- Jump to a Ruby definition from a fully-qualified reference, e.g.
--
--   Billing::Admin::Invoices::Resolvers::Profile::LineItems#resolve
--
-- That form is how Rails code, stack traces, CI failures, Slack threads, and PR
-- comments identify a location, but it is not something a plain file/text search
-- handles well: the text `Billing::Admin::...::LineItems` usually does not
-- appear verbatim in the file that defines it (the file nests `module Billing`,
-- `module Admin`, ... instead).
--
-- Zeitwerk/classic autoloading makes the mapping mechanical, so this resolves it
-- structurally instead of textually:
--
--   1. underscore each constant segment  -> billing/admin/.../line_items.rb
--   2. find files whose path ends with that suffix, retrying with progressively
--      shorter suffixes so non-standard autoload roots still resolve
--   3. failing that, grep for `class|module <LastSegment>` (constants defined
--      inline, or in a differently named file)
--   4. open the file and jump to `def <method>` / `def self.<method>`
--
-- Also accepts `path/to/file.rb:123` so backtrace lines work with the same key.
--
-- File listing/searching goes through lib/project, so this uses the World
-- indexes on a Shopify machine and plain ripgrep everywhere else.

local vim = vim
local map = vim.keymap.set
local project = require("lib.project")

local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Ruby reference" })
end

-- ActiveSupport::Inflector#underscore for a single constant segment, minus
-- custom acronym inflections: consecutive capitals stay together
-- (HTTPServer -> http_server), otherwise each capital starts a word
-- (LineItems -> line_items, JsonApi -> json_api).
local function underscore(segment)
  local out = segment:gsub("([A-Z]+)([A-Z][a-z])", "%1_%2")
  out = out:gsub("([a-z%d])([A-Z])", "%1_%2")
  out = out:gsub("%-", "_")

  return out:lower()
end

-- Path fragment matching one constant segment.
--
-- An app can register acronym inflections (`inflect.acronym "GraphQL"`), which
-- changes the file name from the default `graph_ql` to `graphql`. That only ever
-- affects segments with two or more consecutive capitals, so those get an
-- alternation instead of a single spelling.
local function segment_pattern(segment)
  local snake = underscore(segment)
  local squashed = snake:gsub("_", "")

  if squashed ~= snake and segment:find("%u%u") then
    return "(" .. snake .. "|" .. squashed .. ")"
  end

  return snake
end

local function constant_segments(const)
  local segments = {}

  for segment in const:gmatch("[^:]+") do
    table.insert(segments, segment)
  end

  return segments
end

-- Scores a possible constant so noisy input picks the interesting reference:
-- `NoMethodError in Billing::Invoices::LineItem#total` must resolve the second
-- constant, not `NoMethodError`.
local function score(const, method)
  local points = #const / 100 -- tie-break on length only

  if const:find("::") then
    points = points + 2
  end

  if method then
    points = points + 1
  end

  return points
end

-- Extracts the first/best Ruby reference from arbitrary text.
--
-- Returns one of:
--   { kind = "path",  path = "app/models/x.rb", lnum = 12 }
--   { kind = "const", const = "Foo::Bar", method = "call"|nil,
--     method_kind = "instance"|"class"|nil }
function M.parse(input)
  local text = vim.trim(input or "")

  if text == "" then
    return nil
  end

  -- Backtrace/grep style `path.rb:123` first: it is unambiguous.
  local path, lnum = text:match("([%w%._%-/]+%.rb):(%d+)")

  if path then
    return { kind = "path", path = path, lnum = tonumber(lnum) }
  end

  local best, best_score = nil, -1
  local index = 1

  while true do
    -- `[%w_:]*` stops at `#` and at `.`, so the separator is always just past
    -- the end of the match.
    local first, last = text:find("%u[%w_:]*", index)

    if not first then
      break
    end

    local const = text:sub(first, last):gsub(":+$", "")
    local rest = text:sub(first + #const)
    local separator, method = rest:match("^([#%.])([%a_][%w_]*[?!=]?)")
    local candidate_score = score(const, method)

    if candidate_score > best_score then
      best_score = candidate_score
      best = {
        kind = "const",
        const = const,
        method = method,
        method_kind = separator == "." and "class" or (separator == "#" and "instance" or nil),
      }
    end

    index = last + 1
  end

  return best
end

-- Path-suffix regexes for a constant, most specific first.
--
-- `Billing::Admin::Invoices::Resolvers::Profile::LineItems` becomes
--   (^|/)billing/admin/invoices/resolvers/profile/line_items\.rb$
--   (^|/)admin/invoices/resolvers/profile/line_items\.rb$
--   ...
--   (^|/)line_items\.rb$
--
-- Dropping leading segments handles autoload roots that do not include the
-- whole namespace as directories (engines, component layouts where the path
-- above the namespace differs, single-file namespaces).
local function suffix_patterns(const)
  local segments = constant_segments(const)
  local patterns = {}

  for _, segment in ipairs(segments) do
    table.insert(patterns, segment_pattern(segment))
  end

  local regexes = {}

  for i = 1, #patterns do
    local suffix = table.concat(patterns, "/", i)
    table.insert(regexes, "(^|/)" .. suffix .. "\\.rb$")
  end

  return regexes
end

-- Files that could define const, most specific suffix that matched anything.
-- Stops at the first suffix with hits, so the usual case is a single search.
local function file_candidates(dir, const)
  for _, regex in ipairs(suffix_patterns(const)) do
    local paths = project.find_paths(dir, regex)

    if #paths > 0 then
      return paths
    end
  end

  return {}
end

-- Constants defined inline or in an unconventional file, found by definition
-- text instead of by path.
local function definition_candidates(dir, const)
  local segments = constant_segments(const)
  local last = segments[#segments]

  if not last then
    return {}
  end

  local results = project.grep(dir, "(class|module)\\s+" .. last .. "\\b", { limit = 50 })
  local candidates = {}
  local seen = {}

  for _, result in ipairs(results) do
    if not seen[result.path] then
      seen[result.path] = true
      table.insert(candidates, { path = result.path, lnum = result.lnum })
    end
  end

  return candidates
end

-- Method name and kind defined on a `def` line, or nil.
local function def_on_line(line)
  local body = line:match("^%s*def%s+(.+)$")

  if not body then
    return nil
  end

  local class_method = body:match("^self%s*%.%s*([%a_][%w_]*[?!=]?)")

  if class_method then
    return class_method, "class"
  end

  local instance_method = body:match("^([%a_][%w_]*[?!=]?)")

  if instance_method then
    return instance_method, "instance"
  end

  return nil
end

-- class/module line for name, e.g. `class LineItems < Base` or the compact
-- `module Billing::Admin::Invoices`.
local function declares(line, name)
  local declared = line:match("^%s*class%s+([%w_:]+)") or line:match("^%s*module%s+([%w_:]+)")

  return declared ~= nil and declared:match("([%w_]+)$") == name
end

-- Best line to land on, plus a note when it is not the requested method.
--
-- Preference order: the method with the requested receiver kind, the same
-- method with the other kind (`#` vs `.` is easy to get wrong, and
-- `class << self` blocks define class methods with instance-method syntax),
-- then the class/module declaration, then the top of the file.
local function target_line(lines, ref)
  local exact, other, declaration

  local segments = constant_segments(ref.const)
  local last = segments[#segments]

  for i, line in ipairs(lines) do
    if ref.method then
      local name, kind = def_on_line(line)

      if name == ref.method then
        if kind == ref.method_kind then
          exact = exact or i
        else
          other = other or i
        end
      end
    end

    if not declaration and last and declares(line, last) then
      declaration = i
    end
  end

  if exact then
    return exact
  end

  if other then
    return other, "found def " .. ref.method .. " with the other receiver kind"
  end

  if ref.method and declaration then
    return declaration, "no def " .. ref.method .. " in this file; jumped to the declaration"
  end

  if ref.method then
    return 1, "no def " .. ref.method .. " in this file"
  end

  return declaration or 1
end

-- A jump must never land in a special window (a picker prompt, a terminal, an
-- Oil listing): those either refuse to be replaced (a modified prompt buffer
-- with bufhidden=wipe raises E37) or would be hijacked. Prefer the current
-- window, then any normal file window, then a new split.
local function target_window()
  if vim.bo.buftype == "" then
    return vim.api.nvim_get_current_win()
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
      return win
    end
  end

  vim.cmd("botright split")

  return vim.api.nvim_get_current_win()
end

-- bufadd + nvim_win_set_buf rather than `:edit`, because `:edit` refuses to
-- abandon a modified buffer and needs the path escaped.
local function open(path)
  local bufnr = vim.fn.bufadd(path)

  vim.fn.bufload(bufnr)
  vim.bo[bufnr].buflisted = true
  vim.api.nvim_win_set_buf(0, bufnr)
end

local function jump(path, ref, fallback_lnum)
  vim.api.nvim_set_current_win(target_window())
  vim.cmd("normal! m'") -- keep the pre-jump position in the jumplist
  open(path)

  local lnum, note

  if ref.kind == "path" then
    lnum = ref.lnum
  else
    lnum, note = target_line(vim.api.nvim_buf_get_lines(0, 0, -1, false), ref)

    if note and fallback_lnum then
      lnum = fallback_lnum
    end
  end

  lnum = math.max(1, math.min(lnum or 1, vim.api.nvim_buf_line_count(0)))
  vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  vim.cmd("normal! zz")

  if note then
    notify(note, vim.log.levels.WARN)
  end
end

-- One candidate jumps straight there; several go through vim.ui.select, which
-- telescope-ui-select renders as a picker.
local function choose(candidates, dir, ref)
  if #candidates == 1 then
    jump(candidates[1].path, ref, candidates[1].lnum)
    return
  end

  vim.ui.select(candidates, {
    prompt = ref.const .. (ref.method and ("#" .. ref.method) or ""),
    format_item = function(candidate)
      return project.relative(candidate.path, dir)
    end,
  }, function(candidate)
    if candidate then
      jump(candidate.path, ref, candidate.lnum)
    end
  end)
end

-- Resolves text to a location and jumps there.
function M.goto_reference(text)
  local ref = M.parse(text)

  if not ref then
    notify("no Ruby reference in: " .. vim.trim(text or ""), vim.log.levels.WARN)
    return
  end

  local dir = project.root()

  if ref.kind == "path" then
    local path = vim.fn.filereadable(ref.path) == 1 and ref.path or vim.fs.joinpath(dir, ref.path)

    if vim.fn.filereadable(path) == 1 then
      jump(path, ref)
      return
    end

    -- Not a real path from here (e.g. a backtrace from another machine): fall
    -- back to matching the tail of the path.
    local matches = project.find_paths(dir, "(^|/)" .. vim.fn.fnamemodify(ref.path, ":t") .. "$")

    if #matches == 0 then
      notify("file not found: " .. ref.path, vim.log.levels.WARN)
      return
    end

    choose(
      vim.tbl_map(function(match)
        return { path = match, lnum = ref.lnum }
      end, matches),
      dir,
      ref
    )
    return
  end

  local candidates = vim.tbl_map(function(path)
    return { path = path }
  end, file_candidates(dir, ref.const))

  if #candidates == 0 then
    candidates = definition_candidates(dir, ref.const)
  end

  if #candidates == 0 then
    notify(
      ("no file for %s (looked for %s)"):format(
        ref.const,
        table.concat(
          vim.tbl_map(underscore, constant_segments(ref.const)),
          "/"
        ) .. ".rb"
      ),
      vim.log.levels.WARN
    )
    return
  end

  choose(candidates, dir, ref)
end

-- Charwise text of the current visual selection, without clobbering registers.
local function visual_selection()
  local mode = vim.fn.mode()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })

  return table.concat(lines, "")
end

local function prompt(default)
  vim.ui.input({ prompt = "Ruby reference: ", default = default or "" }, function(text)
    if text and vim.trim(text) ~= "" then
      M.goto_reference(text)
    end
  end)
end

vim.api.nvim_create_user_command("RubyRef", function(cmd)
  if vim.trim(cmd.args) ~= "" then
    M.goto_reference(cmd.args)
  else
    prompt(vim.fn.getreg("+"))
  end
end, { nargs = "*", desc = "Jump to a Ruby constant/method reference" })

-- Cursor first: <leader>fr on a reference in code or in a test failure jumps
-- without a prompt. Only ask when there is nothing usable under the cursor.
map("n", "<leader>fr", function()
  local word = vim.fn.expand("<cWORD>")

  if M.parse(word) then
    M.goto_reference(word)
  else
    prompt(vim.fn.getreg("+"))
  end
end, { desc = "Jump to Ruby reference under cursor" })

map("x", "<leader>fr", function()
  local selection = visual_selection()

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  vim.schedule(function()
    M.goto_reference(selection)
  end)
end, { desc = "Jump to selected Ruby reference" })

-- For text that lives outside the editor (Slack, CI logs, a PR review).
map("n", "<leader>fR", function()
  prompt(vim.fn.getreg("+"))
end, { desc = "Jump to Ruby reference from clipboard/prompt" })

return M
