-- Project/zone detection plus the file-listing and content-search commands that
-- every search feature in this config shares (telescope pickers, Ruby
-- reference jumping).
--
-- There are two backends:
--
--   * Default (any machine, any repo): ripgrep. Walks the filesystem, sees
--     untracked files, needs no extra tooling.
--   * Shopify World zone only: the git index for file names and `wg`
--     (worldgrep) for file contents. World is a ~1.4M file monorepo on a
--     virtual filesystem, so walking it with rg is unusably slow, but both
--     of those tools read prebuilt indexes instead.
--
-- Every World-specific path is gated on `world_zone()` (a `zone.nix` root
-- inside a git worktree) plus an executable check, so on a personal machine
-- this module behaves exactly like a plain ripgrep setup. Nothing here fails
-- or degrades if World tooling is absent.

local M = {}

-- Directories that are never worth searching, on any machine.
M.always_ignored_globs = {
  "!**/.git/**",
  "!**/.files/**",
  "!**/.cache/**",
  "!**/.local/**",
  "!**/node_modules/**",
}

-- Very high-volume generated/type/localization files. Hidden by default and
-- toggled back on per picker with <C-g>.
M.noisy_file_globs = {
  "!**/*.rbi",
  "!**/sorbet/tapioca/**",
  "!**/translations/**/*.json",
  "!**/generated/translations/**",
}

-- Regex equivalents of the glob lists above, for the backends that filter
-- paths with a regex (`rg -v` over the git index, `wg -F`) instead of globs.
M.dotfile_alt = "^\\."
M.noisy_alt = "\\.rbi$|/sorbet/tapioca/|/translations/.*\\.json$|/generated/translations/"

local function add_globs(args, globs)
  for _, glob in ipairs(globs) do
    table.insert(args, "--glob=" .. glob)
  end

  return args
end

-- Appends the shared glob filters to an rg argument list.
function M.add_search_globs(args, include_noisy)
  add_globs(args, M.always_ignored_globs)

  if not include_noisy then
    add_globs(args, M.noisy_file_globs)
  end

  return args
end

-- Single regex alternation matching everything the current toggles exclude, or
-- nil when nothing should be excluded.
function M.exclude_alt(include_hidden, include_noisy)
  local alts = {}

  if not include_hidden then
    table.insert(alts, M.dotfile_alt)
  end

  if not include_noisy then
    table.insert(alts, M.noisy_alt)
  end

  if #alts == 0 then
    return nil
  end

  return table.concat(alts, "|")
end

-- rg argv for listing files. Returned as argv (not a shell string) because
-- telescope only appends `--hidden` for itself when it recognizes argv[1] as
-- rg/fd, so the hidden toggle depends on this staying a bare rg command.
function M.rg_files_command(include_noisy)
  return M.add_search_globs({
    "rg",
    "--files",
    "--color=never",
  }, include_noisy == true)
end

-- Extra rg flags for content search (telescope live_grep appends these).
function M.rg_grep_args(include_hidden, include_noisy)
  local args = M.add_search_globs({
    "--max-columns=500",
    "--max-filesize=1M",
  }, include_noisy == true)

  if include_hidden then
    table.insert(args, "--hidden")
  end

  return args
end

function M.has_worldgrep()
  return vim.fn.executable("wg") == 1
end

-- Git worktree toplevel for dir, or nil when dir is not inside a worktree.
function M.git_toplevel(dir)
  local out = vim.fn.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" })

  if vim.v.shell_error ~= 0 then
    return nil
  end

  local top = vim.trim(out)

  return top ~= "" and top or nil
end

-- path relative to base, or path unchanged when it is not under base.
function M.relative(path, base)
  if base == nil or base == "" or path == base then
    return ""
  end

  if path:sub(1, #base) ~= base then
    return path
  end

  return (path:sub(#base + 1):gsub("^/+", ""))
end

-- Describes dir as a World zone, or returns nil for every other repo layout.
--
-- Requires all three:
--   * a `zone.nix` ancestor (the zone root, e.g. <src>/areas/<area>/<zone>)
--   * dir is inside a git worktree
--   * dir is a strict subdirectory of the worktree toplevel
--
-- The last check matters: World worktrees share one index, so
-- `git ls-files -- .` from the toplevel enumerates all 1.4M files (~17s)
-- instead of just the zone (~0.2s).
function M.world_zone(dir)
  local zone_root = vim.fs.root(dir, { "zone.nix" })

  if not zone_root then
    return nil
  end

  local toplevel = M.git_toplevel(dir)

  if not toplevel or dir == toplevel then
    return nil
  end

  local sub_rel = M.relative(dir, zone_root)

  return {
    dir = dir,
    root = zone_root,
    toplevel = toplevel,
    -- wg names zones `//areas/<area>/<zone>`, so this is what `-z` matches.
    zone_rel = M.relative(zone_root, toplevel),
    -- Set only when searching below the zone root, for `wg -f`.
    sub_rel = sub_rel ~= "" and sub_rel or nil,
  }
end

-- Search root for the file being edited: prefer the World zone, then the git
-- repo, then the process cwd.
function M.root(start)
  if not start then
    local current_file = vim.api.nvim_buf_get_name(0)
    start = current_file ~= "" and vim.fs.dirname(current_file) or vim.uv.cwd()
  end

  return vim.fs.root(start, { "zone.nix" })
    or vim.fs.root(start, { ".git" })
    or vim.uv.cwd()
end

-- Shell fragment that filters a stream of paths down to the current toggles.
local function path_filter(include_hidden, include_noisy)
  local excludes = M.exclude_alt(include_hidden, include_noisy)

  if not excludes then
    return "cat"
  end

  return "rg -v " .. vim.fn.shellescape(excludes)
end

-- Shell script printing every candidate file path in dir, one per line,
-- relative to dir. The `cd` keeps output relative for both backends so callers
-- can join paths without caring which backend ran.
--
-- The git branch must pipe inside a single script: separate commands would
-- stream the unfiltered git output straight to stdout and hand the filter an
-- empty stdin.
function M.list_files_script(dir, include_hidden, include_noisy)
  local quoted = vim.fn.shellescape(dir)
  local zone = M.world_zone(dir)

  if zone then
    return "cd " .. quoted .. " 2>/dev/null && git ls-files --cached -- . 2>/dev/null | "
      .. path_filter(include_hidden, include_noisy)
  end

  local args = M.rg_files_command(include_noisy)

  if include_hidden then
    table.insert(args, "--hidden")
  end

  local parts = {}

  for _, arg in ipairs(args) do
    table.insert(parts, vim.fn.shellescape(arg))
  end

  return "cd " .. quoted .. " 2>/dev/null && " .. table.concat(parts, " ") .. " 2>/dev/null"
end

-- argv for telescope's find_files `find_command`.
function M.list_files_command(dir, include_hidden, include_noisy)
  if M.world_zone(dir) then
    return { "sh", "-c", M.list_files_script(dir, include_hidden, include_noisy) }
  end

  -- Bare rg argv so telescope can append --hidden itself.
  return M.rg_files_command(include_noisy)
end

-- Absolute paths under dir whose dir-relative path matches the rg regex.
-- Synchronous: intended for one-shot lookups, not for live pickers.
function M.find_paths(dir, regex, opts)
  opts = opts or {}

  local script = M.list_files_script(dir, opts.include_hidden, opts.include_noisy)
    .. " | rg -e "
    .. vim.fn.shellescape(regex)

  local lines = vim.fn.systemlist({ "sh", "-c", script })

  -- rg exits 1 with no matches, >1 on real errors.
  if vim.v.shell_error ~= 0 then
    return {}
  end

  local paths = {}

  for _, line in ipairs(lines) do
    local rel = vim.trim(line)

    if rel ~= "" then
      table.insert(paths, vim.fs.joinpath(dir, rel))
    end
  end

  return paths
end

-- wg prints `//areas/<zone>/<path>:<line>:<text>`: zone-prefixed, no column.
local function worldgrep_argv(zone, pattern, include_hidden, include_noisy, extra)
  local argv = { "wg", "-n", "-z", "^//" .. zone.zone_rel .. "$" }

  if zone.sub_rel then
    table.insert(argv, "-f")
    table.insert(argv, "^" .. zone.sub_rel .. "/")
  end

  local excludes = M.exclude_alt(include_hidden, include_noisy)

  if excludes then
    table.insert(argv, "-F")
    table.insert(argv, excludes)
  end

  for _, arg in ipairs(extra or {}) do
    table.insert(argv, arg)
  end

  table.insert(argv, "--")
  table.insert(argv, pattern)

  return argv
end

-- Rewrites wg output into telescope's expected `file:line:col:text` form:
-- strips the `//` so paths resolve against the worktree toplevel, and inserts
-- a synthetic column. BSD sed needs -E for capture groups.
local worldgrep_sed = "s|^//||; s/^([^:]*):([0-9]*):/\\1:\\2:1:/"

-- vimgrep_arguments for telescope live_grep inside a World zone. Telescope
-- appends `-- <prompt>`, so the prompt lands in "$1".
function M.worldgrep_vimgrep_arguments(zone, include_hidden, include_noisy)
  local argv = worldgrep_argv(zone, "$1", include_hidden, include_noisy)
  local parts = {}

  for _, arg in ipairs(argv) do
    -- "$1" must stay unquoted-expandable, so quote it as "$1" not '$1'.
    table.insert(parts, arg == "$1" and "\"$1\"" or vim.fn.shellescape(arg))
  end

  local script = table.concat(parts, " ")
    .. " 2>/dev/null | sed -E "
    .. vim.fn.shellescape(worldgrep_sed)

  return { "sh", "-c", script }
end

-- One-shot content search returning { path = absolute, lnum = number, text }.
-- Uses the World index when available, plain rg everywhere else.
function M.grep(dir, pattern, opts)
  opts = opts or {}

  local limit = opts.limit or 100
  local zone = M.world_zone(dir)
  local argv, base

  if zone and M.has_worldgrep() then
    argv = worldgrep_argv(zone, pattern, opts.include_hidden, opts.include_noisy)
    base = zone.toplevel
  else
    argv = M.add_search_globs({
      "rg",
      "--line-number",
      "--no-heading",
      "--color=never",
    }, opts.include_noisy == true)

    if opts.include_hidden then
      table.insert(argv, "--hidden")
    end

    vim.list_extend(argv, { "-e", pattern, "--", dir })
    base = nil
  end

  local parts = {}

  for _, arg in ipairs(argv) do
    table.insert(parts, vim.fn.shellescape(arg))
  end

  -- 2>/dev/null: wg writes index-age warnings to stderr, and vim's system()
  -- can fold stderr into the captured output.
  local lines = vim.fn.systemlist({ "sh", "-c", table.concat(parts, " ") .. " 2>/dev/null" })

  if vim.v.shell_error ~= 0 then
    return {}
  end

  local results = {}

  for _, line in ipairs(lines) do
    local path, lnum, text = line:match("^(.-):(%d+):(.*)$")

    if path then
      if base then
        path = vim.fs.joinpath(base, (path:gsub("^//", "")))
      end

      table.insert(results, { path = path, lnum = tonumber(lnum), text = text })

      if #results >= limit then
        break
      end
    end
  end

  return results
end

return M
