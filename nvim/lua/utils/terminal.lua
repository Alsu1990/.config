local M = {}

-- Generic floating window creator
local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * (opts.width_ratio or 0.8))
  local height = opts.height or math.floor(vim.o.lines * (opts.height_ratio or 0.8))

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- unlisted scratch buffer
  end

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = opts.border or "rounded",
    title = opts.title and (" " .. opts.title .. " ") or nil,
    title_pos = opts.title and "center" or nil,
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)
  return { buf = buf, win = win }
end

-- Terminal factory that manages independent state per command
local function create_terminal_toggle(cmd, title, custom_opts)
  local state = { buf = -1, win = -1 }
  custom_opts = custom_opts or {}

  return function()
    -- Hide if already open
    if vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_hide(state.win)
      return
    end

    -- Open window
    local opts = vim.tbl_extend("force", {
      buf = state.buf,
      title = title,
    }, custom_opts)

    state = create_floating_window(opts)

    -- If new buffer, spawn command
    if vim.bo[state.buf].buftype ~= "terminal" then
      vim.fn.jobstart(cmd, {
        term = true,
        on_exit = function()
          -- Automatically close the window if the process exits (e.g. quitting lazygit)
          if vim.api.nvim_win_is_valid(state.win) then
            vim.api.nvim_win_close(state.win, true)
          end
          if vim.api.nvim_buf_is_valid(state.buf) then
            vim.api.nvim_buf_delete(state.buf, { force = true })
          end
          state.buf = -1
          state.win = -1
        end,
      })
    end

    vim.cmd("startinsert")
  end
end

-- 1. Standard Floating Shell
M.toggle_terminal =
  create_terminal_toggle(os.getenv("SHELL") or "bash", "Terminal", { width_ratio = 0.8, height_ratio = 0.8 })

-- 2. Dedicated LazyGit (larger 90% window for viewing diffs)
M.toggle_lazygit = create_terminal_toggle("lazygit", "LazyGit", { width_ratio = 0.9, height_ratio = 0.9 })

return M
