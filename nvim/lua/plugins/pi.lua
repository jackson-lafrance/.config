local vim = vim
local map = vim.keymap.set
local project = require("lib.project")

vim.opt.autoread = true
vim.opt.mouse = "a"

local pi_terminal = {
  bufnr = nil,
  job_id = nil,
  cwd = nil,
}

local function visual_mode()
  local mode = vim.fn.mode()
  return mode == "v" or mode == "V" or mode == "\22"
end

local function current_visual_range()
  if not visual_mode() then
    return nil
  end

  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]
  local mode = vim.fn.mode()

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  return {
    mode = mode,
    start_line = start_line,
    start_col = start_col,
    end_line = end_line,
    end_col = end_col,
  }
end

local function relative_path(path, root)
  if path == nil or path == "" then
    return "[No file]"
  end

  local relpath = project.relative(path, root)

  if relpath ~= "" and relpath ~= path then
    return relpath
  end

  return path
end

local function numbered_lines(bufnr, first_line, last_line)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  first_line = math.max(1, first_line)
  last_line = math.min(line_count, last_line)

  local raw_lines = vim.api.nvim_buf_get_lines(bufnr, first_line - 1, last_line, false)
  local lines = {}

  for index, line in ipairs(raw_lines) do
    lines[#lines + 1] = string.format("%d: %s", first_line + index - 1, line)
  end

  return lines
end

local function selected_text(bufnr, range)
  if not range then
    return {}
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, range.start_line - 1, range.end_line, false)

  if range.mode == "v" and #lines > 0 then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], range.start_col, range.end_col)
    else
      lines[1] = string.sub(lines[1], range.start_col)
      lines[#lines] = string.sub(lines[#lines], 1, range.end_col)
    end
  end

  return lines
end

local function format_diagnostics(bufnr, line)
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line - 1 })

  if #diagnostics == 0 then
    return { "none" }
  end

  local severity_names = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT",
  }

  local lines = {}
  for _, diagnostic in ipairs(diagnostics) do
    lines[#lines + 1] = string.format(
      "- %s: %s",
      severity_names[diagnostic.severity] or tostring(diagnostic.severity),
      diagnostic.message:gsub("\n", " ")
    )
  end

  return lines
end

local function capture_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local col = cursor[2] + 1
  local path = vim.api.nvim_buf_get_name(bufnr)
  local root_start = path ~= "" and vim.fs.dirname(path) or vim.uv.cwd()
  local root = project.root(root_start)
  local range = current_visual_range()
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  return {
    bufnr = bufnr,
    root = root,
    file = relative_path(path, root),
    absolute_file = path ~= "" and path or "[No file]",
    filetype = vim.bo[bufnr].filetype ~= "" and vim.bo[bufnr].filetype or "text",
    modified = vim.bo[bufnr].modified,
    cursor_line = row,
    cursor_col = col,
    current_word = vim.fn.expand("<cword>"),
    selection = range,
    selected_text = selected_text(bufnr, range),
    selected_numbered_lines = range and numbered_lines(bufnr, range.start_line, range.end_line) or {},
    buffer_lines = numbered_lines(bufnr, 1, line_count),
    diagnostics = format_diagnostics(bufnr, row),
  }
end

local function build_context_prompt(context)
  local lines = {
    "Use this Neovim editor context when answering my next question.",
    "Treat <current_buffer> as the authoritative current state of the file, including unsaved Neovim changes.",
    "When editing this file, treat <current_buffer> as the saved baseline even if disk contents differ.",
    "Do not overwrite, remove, or revert unsaved Neovim changes shown in <current_buffer>; preserve them and layer requested edits on top.",
    "If a tool requires exact on-disk text that conflicts with <current_buffer>, ask me to save first or provide a patch instead of applying a risky edit.",
    "If <selection> is present, focus on it specifically, but use the full current buffer for surrounding context.",
    "You may inspect other project files with Pi tools when helpful; do not limit yourself to this file or selection.",
    "",
    "<neovim_context>",
    string.format("project_root: %s", context.root),
    string.format("file: %s", context.file),
    string.format("absolute_file: %s", context.absolute_file),
    string.format("filetype: %s", context.filetype),
    string.format("buffer_modified_in_neovim: %s", context.modified and "true" or "false"),
    string.format("cursor: line %d, column %d", context.cursor_line, context.cursor_col),
  }

  if context.current_word and context.current_word ~= "" then
    lines[#lines + 1] = string.format("word_under_cursor: %s", context.current_word)
  end

  if context.selection then
    lines[#lines + 1] = string.format(
      "selection_range: line %d column %d through line %d column %d",
      context.selection.start_line,
      context.selection.start_col,
      context.selection.end_line,
      context.selection.end_col
    )
    lines[#lines + 1] = "<selection>"
    lines[#lines + 1] = string.format("```%s", context.filetype)
    vim.list_extend(lines, context.selected_text)
    lines[#lines + 1] = "```"
    lines[#lines + 1] = "</selection>"
    lines[#lines + 1] = "selected_line_numbers:"
    vim.list_extend(lines, context.selected_numbered_lines)
  else
    lines[#lines + 1] = "selection_range: none"
  end

  lines[#lines + 1] = "diagnostics_on_cursor_line:"
  vim.list_extend(lines, context.diagnostics)

  lines[#lines + 1] = "<current_buffer>"
  lines[#lines + 1] = string.format("```%s", context.filetype)
  vim.list_extend(lines, context.buffer_lines)
  lines[#lines + 1] = "```"
  lines[#lines + 1] = "</current_buffer>"

  lines[#lines + 1] = "</neovim_context>"
  lines[#lines + 1] = ""
  lines[#lines + 1] = "My question: "

  return table.concat(lines, "\n")
end

local function find_window_for_buffer(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(winid) and vim.api.nvim_win_get_buf(winid) == bufnr then
      return winid
    end
  end

  return nil
end

local pi_job_running

local function window_under_mouse()
  local pos = vim.fn.getmousepos()
  local winid = pos and pos.winid

  if winid and winid ~= 0 and vim.api.nvim_win_is_valid(winid) then
    return winid
  end

  return nil
end

local function vertical_mouse_scroll_lines()
  return tonumber((vim.o.mousescroll or ""):match("ver:(%d+)")) or 5
end

local function restore_window_after_mouse_scroll(winid, was_terminal_mode)
  if vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
  end

  if was_terminal_mode and pi_terminal.bufnr and vim.api.nvim_get_current_buf() == pi_terminal.bufnr and pi_job_running() then
    vim.cmd("startinsert")
  end
end

local function do_scroll_window(winid, direction, original_win, was_terminal_mode)
  local key = direction == "up" and "\25" or "\5" -- Ctrl-y / Ctrl-e.
  local ok, err = pcall(vim.api.nvim_win_call, winid, function()
    vim.cmd("normal! " .. vertical_mouse_scroll_lines() .. key)
  end)

  restore_window_after_mouse_scroll(original_win, was_terminal_mode)

  if not ok then
    vim.notify("Mouse scroll failed: " .. tostring(err), vim.log.levels.WARN)
  end
end

local function scroll_window_under_mouse(direction)
  local winid = window_under_mouse()

  if not winid then
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  local mode = vim.api.nvim_get_mode().mode
  local was_terminal_mode = mode:sub(1, 1) == "t"

  if was_terminal_mode then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
    vim.schedule(function()
      do_scroll_window(winid, direction, current_win, true)
    end)
    return
  end

  do_scroll_window(winid, direction, current_win, false)
end

local function focus_window_under_mouse()
  local winid = window_under_mouse()

  if not winid then
    return
  end

  vim.api.nvim_set_current_win(winid)

  if pi_terminal.bufnr and vim.api.nvim_win_get_buf(winid) == pi_terminal.bufnr and pi_job_running() then
    vim.cmd("startinsert")
  end
end

function pi_job_running()
  return pi_terminal.job_id ~= nil and vim.fn.jobwait({ pi_terminal.job_id }, 0)[1] == -1
end

local reload_timer = nil

local function path_under(path, root)
  if not path or path == "" or not root or root == "" then
    return false
  end

  local normalized_path = vim.fs.normalize(path)
  local normalized_root = vim.fs.normalize(root):gsub("/+$", "")

  return normalized_path == normalized_root or normalized_path:sub(1, #normalized_root + 1) == normalized_root .. "/"
end

local function buffer_belongs_to_pi_session(bufnr)
  if not pi_job_running() then
    return false
  end

  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if vim.bo[bufnr].buftype ~= "" then
    return false
  end

  local path = vim.api.nvim_buf_get_name(bufnr)

  return path_under(path, pi_terminal.cwd)
end

local function check_for_pi_file_edits()
  if not pi_job_running() then
    return
  end

  vim.cmd("silent! checktime")
end

local function start_pi_reload_timer()
  if reload_timer then
    return
  end

  reload_timer = vim.uv.new_timer()

  if not reload_timer then
    return
  end

  reload_timer:start(1000, 1000, function()
    vim.schedule(check_for_pi_file_edits)
  end)
end

local function stop_pi_reload_timer()
  if not reload_timer then
    return
  end

  reload_timer:stop()
  reload_timer:close()
  reload_timer = nil
end

local function pi_command()
  if vim.fn.executable("zsh") == 1 then
    return { "zsh", "-ic", "pi" }
  end

  return { "pi" }
end

local function open_pi_terminal(cwd)
  cwd = cwd or project.root()

  if pi_terminal.bufnr and vim.api.nvim_buf_is_valid(pi_terminal.bufnr) and pi_job_running() then
    local winid = find_window_for_buffer(pi_terminal.bufnr)

    if winid then
      vim.api.nvim_set_current_win(winid)
    else
      vim.cmd("botright vertical 100split")
      vim.api.nvim_win_set_buf(0, pi_terminal.bufnr)
    end

    if pi_terminal.cwd and pi_terminal.cwd ~= cwd then
      vim.notify(
        "Pi is already running in " .. pi_terminal.cwd .. "; close it with <leader>vx to switch roots.",
        vim.log.levels.WARN
      )
    end

    start_pi_reload_timer()
    vim.cmd("startinsert")
    return pi_terminal.job_id
  end

  vim.cmd("botright vertical 100new")
  pi_terminal.bufnr = vim.api.nvim_get_current_buf()
  vim.bo[pi_terminal.bufnr].bufhidden = "hide"
  vim.bo[pi_terminal.bufnr].filetype = "pi"

  pi_terminal.cwd = cwd
  pi_terminal.job_id = vim.fn.termopen(pi_command(), {
    cwd = cwd,
    on_exit = function()
      pi_terminal.job_id = nil
      pi_terminal.cwd = nil
      stop_pi_reload_timer()
    end,
  })

  if pi_terminal.job_id <= 0 then
    vim.notify("Failed to start pi", vim.log.levels.ERROR)
    return nil
  end

  vim.cmd("file Pi")
  start_pi_reload_timer()
  vim.cmd("startinsert")

  return pi_terminal.job_id
end

local function paste_into_pi(text, cwd)
  local job_id = open_pi_terminal(cwd)

  if not job_id then
    return
  end

  local normalized = text:gsub("\r\n", "\n")

  vim.defer_fn(function()
    if not pi_job_running() then
      return
    end

    -- Bracketed paste keeps the multiline context in Pi's editor instead of
    -- submitting each newline as Enter.
    vim.api.nvim_chan_send(job_id, "\27[200~" .. normalized .. "\27[201~")
  end, 750)
end

local function ask_with_current_context()
  local context = capture_context()
  paste_into_pi(build_context_prompt(context), context.root)
end

local function nerd_dictation_cookie()
  return (vim.env.XDG_RUNTIME_DIR or "/tmp") .. "/nerd-dictation-cookie"
end

local function nerd_dictation_running()
  local file = io.open(nerd_dictation_cookie(), "r")
  if not file then
    return false
  end

  local pid = file:read("*a"):match("%d+")
  file:close()

  if not pid then
    return false
  end

  local result = vim.system({ "ps", "-p", pid, "-o", "args=" }, { text = true }):wait()
  return result.code == 0 and result.stdout:find("nerd%-dictation") ~= nil
end

local function toggle_nerd_dictation()
  local cmd = vim.fn.expand("~/.local/bin/voice-dictate-toggle")

  if vim.fn.executable(cmd) ~= 1 then
    vim.notify("Missing nerd-dictation wrapper: " .. cmd, vim.log.levels.ERROR)
    return
  end

  local job_id = vim.fn.jobstart({ cmd }, { detach = true })
  if job_id <= 0 then
    vim.notify("Failed to start nerd-dictation wrapper", vim.log.levels.ERROR)
  end
end

local function voice_ask_with_current_context()
  if nerd_dictation_running() then
    toggle_nerd_dictation()
    return
  end

  ask_with_current_context()
  vim.defer_fn(toggle_nerd_dictation, 1100)
end

local function close_pi_terminal()
  if pi_terminal.job_id and pi_job_running() then
    vim.fn.jobstop(pi_terminal.job_id)
  end

  if pi_terminal.bufnr and vim.api.nvim_buf_is_valid(pi_terminal.bufnr) then
    vim.api.nvim_buf_delete(pi_terminal.bufnr, { force = true })
  end

  pi_terminal.bufnr = nil
  pi_terminal.job_id = nil
  pi_terminal.cwd = nil
  stop_pi_reload_timer()
end

local reload_group = vim.api.nvim_create_augroup("PiAutoReload", { clear = true })

vim.api.nvim_create_autocmd("FileChangedShell", {
  group = reload_group,
  callback = function(event)
    if buffer_belongs_to_pi_session(event.buf) then
      if vim.bo[event.buf].modified then
        -- Never silently discard unsaved Neovim edits. The prompt tells Pi to
        -- preserve the live buffer, but this keeps Neovim from clobbering local
        -- changes if Pi still writes a conflicting on-disk version.
        vim.v.fcs_choice = "ask"
        return
      end

      -- Pi edits are intentional external writes; reload clean loaded buffers so
      -- the Neovim view follows the file state Pi just wrote.
      vim.v.fcs_choice = "reload"
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = reload_group,
  callback = function(event)
    if buffer_belongs_to_pi_session(event.buf) then
      vim.notify("Reloaded " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(event.buf), ":~:."), vim.log.levels.INFO)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained", "TermLeave" }, {
  group = reload_group,
  callback = check_for_pi_file_edits,
})

vim.api.nvim_create_autocmd("WinEnter", {
  group = reload_group,
  callback = function()
    if pi_terminal.bufnr and vim.api.nvim_get_current_buf() == pi_terminal.bufnr and pi_job_running() then
      vim.cmd("startinsert")
    end
  end,
})

vim.api.nvim_create_user_command("Pi", function()
  open_pi_terminal()
end, { desc = "Open Pi interactive mode" })

vim.api.nvim_create_user_command("PiAskHere", function()
  ask_with_current_context()
end, { desc = "Paste current Neovim context into Pi" })

vim.api.nvim_create_user_command("PiVoiceAsk", function()
  voice_ask_with_current_context()
end, { desc = "Paste current Neovim context into Pi and start dictation" })

vim.api.nvim_create_user_command("PiClose", function()
  close_pi_terminal()
end, { desc = "Close Pi terminal" })

map({ "n", "v" }, "<leader>va", function()
  ask_with_current_context()
end, { desc = "Ask Pi with cursor/selection context" })

map({ "n", "v" }, "<leader>vv", function()
  voice_ask_with_current_context()
end, { desc = "Voice ask Pi with cursor/selection context" })

map("n", "<leader>vp", function()
  open_pi_terminal()
end, { desc = "Open Pi interactive mode" })

map("n", "<leader>vx", function()
  close_pi_terminal()
end, { desc = "Close Pi terminal" })

map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

map({ "n", "i", "t" }, "<ScrollWheelUp>", function()
  scroll_window_under_mouse("up")
end, { desc = "Scroll window under mouse up" })

map({ "n", "i", "t" }, "<ScrollWheelDown>", function()
  scroll_window_under_mouse("down")
end, { desc = "Scroll window under mouse down" })

map("t", "<LeftMouse>", function()
  focus_window_under_mouse()
end, { desc = "Focus clicked window from terminal mode" })

map("n", "<Left>", "<C-w>h", { desc = "Move to left window" })
map("n", "<Down>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<Up>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<Right>", "<C-w>l", { desc = "Move to right window" })
