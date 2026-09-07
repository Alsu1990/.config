local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Core UI & Presets (Early) ==================================================

-- General baseline presets
now(function()
  require("mini.basics").setup({
    options = { basic = false },
    mappings = {
      windows = true,
      move_with_alt = true,
    },
  })
end)

-- Icons
now(function()
  local ext3_blocklist = { scm = true, txt = true, yml = true }
  local ext4_blocklist = { json = true, yaml = true }
  require("mini.icons").setup({
    use_file_extension = function(ext, _)
      return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
    end,
  })

  later(MiniIcons.mock_nvim_web_devicons)
  later(MiniIcons.tweak_lsp_kind)
end)

-- Notifications
now(function()
  require("mini.notify").setup()

  vim.notify = MiniNotify.make_notify()

  pcall(function()
    require("vim._core.ui2").enable({
      enable = true,
      msg = {
        targets = {
          ["default"] = "msg",
          ["echo"] = "msg",
          ["echomsg"] = "msg",
          ["lua_print"] = "msg",
          ["undo"] = "msg",

          ["search_cmd"] = "cmd",
          ["search_count"] = "cmd",
          ["confirm"] = "cmd",
        },
        msg = {
          timeout = 3500,
          height = 0.40,
        },
      },
    })
  end)
end)

-- Sessions
now(function()
  require("mini.sessions").setup()
end)

-- Start screen
now(function()
  require("mini.starter").setup()
end)

-- Statusline
now(function()
  local statusline = require("mini.statusline")

  -- Helper to get active attached LSP server names for current buffer
  local function get_lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end
    local names = {}
    for _, client in ipairs(clients) do
      if client.name ~= "copilot" then
        table.insert(names, client.name)
      end
    end
    if #names == 0 then return "" end
    return "󰒋 " .. table.concat(names, ",")
  end

  -- Helper to get current Treesitter enclosing code scope (function, method, class, module)
  local function get_code_scope()
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then return "" end
    while node do
      local t = node:type()
      if t:find("function") or t:find("method") or t:find("class") or t:find("struct") or t:find("module") or t:find("task") then
        local r = node:range()
        local line = vim.api.nvim_buf_get_lines(0, r, r + 1, false)[1] or ""
        line = vim.trim(line)
        local name = line:match("([%w_.:]+)%s*=%s*function")
          or line:match("function%s+([%w_.:]+)")
          or line:match("def%s+([%w_.:]+)")
          or line:match("class%s+([%w_.:]+)")
          or line:match("struct%s+([%w_.:]+)")
          or line:match("module%s+([%w_.:]+)")
          or line:match("task%s+([%w_.:]+)")
        if name then
          return "󰊕 " .. name
        end
      end
      node = node:parent()
    end
    return ""
  end

  -- Helper for active macro recording indicator
  local function get_macro()
    local reg = vim.fn.reg_recording()
    return reg ~= "" and ("󰑋 @" .. reg) or ""
  end

  -- Helper to get filename relative to cwd (instead of full absolute path)
  local function get_filename()
    if vim.bo.buftype == "terminal" then
      return "%t"
    end
    if statusline.is_truncated(60) then
      return "%t%m%r"
    end
    return "%f%m%r"
  end

  statusline.setup({
    content = {
      active = function()
        local mode, mode_hl = statusline.section_mode({ trunc_width = 60 })
        local git           = statusline.section_git({ trunc_width = 40 })
        local diff          = statusline.section_diff({ trunc_width = 75 })
        local diagnostics   = statusline.section_diagnostics({
          trunc_width = 75,
          icon = "",
          signs = {
            ERROR = " ",
            WARN  = " ",
            INFO  = " ",
            HINT  = " ",
          },
        })
        if diagnostics ~= "" then
          diagnostics = vim.trim(diagnostics)
        end
        local filename      = get_filename()
        local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
        local location      = statusline.section_location({ trunc_width = 75 })
        local search        = statusline.section_searchcount({ trunc_width = 75 })
        local macro         = get_macro()
        local lsp           = get_lsp_status()
        local scope         = get_code_scope()

        return statusline.combine_groups({
          { hl = mode_hl,                  strings = { mode } },
          { hl = "MiniStatuslineDevinfo",  strings = { git, diff, diagnostics } },
          "%<", -- Mark general truncate point
          { hl = "MiniStatuslineFilename", strings = { filename } },
          { hl = "Comment",                strings = { scope } },
          "%=", -- End left alignment
          { hl = "DiagnosticWarn",         strings = { macro } },
          { hl = "MiniStatuslineDevinfo",  strings = { lsp } },
          { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
          { hl = mode_hl,                  strings = { search, location } },
        })
      end,
    },
  })
end)

-- Tabline
now(function()
  require("mini.tabline").setup()
end)

-- File Explorer & Utilities (On file open or startup) =========================

-- Miller-columns explorer
now_if_args(function()
  require("mini.files").setup({ windows = { preview = true } })

  local add_marks = function()
    MiniFiles.set_bookmark("c", vim.fn.stdpath("config"), { desc = "Config" })
    local vimpack_plugins = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    MiniFiles.set_bookmark("p", vimpack_plugins, { desc = "Plugins" })
    MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
  end
  Config.new_autocmd("User", "MiniFilesExplorerOpen", add_marks, "Add bookmarks")
end)

-- Miscellaneous helpers
now_if_args(function()
  require("mini.misc").setup()

  local launch_cwd = vim.fn.getcwd()
  MiniMisc.setup_auto_root(vim.g.auto_root, function()
    return launch_cwd
  end)

  MiniMisc.setup_restore_cursor()

  if #vim.api.nvim_list_uis() > 0 then
    MiniMisc.setup_termbg_sync()
  end
end)

-- Deferred Modules ===========================================================

later(function()
  require("mini.extra").setup()
end)

-- Enhanced textobjects
later(function()
  local ai = require("mini.ai")
  ai.setup({
    custom_textobjects = {
      B = MiniExtra.gen_ai_spec.buffer(),
      F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    },
    search_method = "cover",
  })
end)

later(function()
  require("mini.align").setup()
end)

later(function()
  require("mini.bracketed").setup()
end)

later(function()
  require("mini.bufremove").setup()
end)

-- Key clue menu
later(function()
  local miniclue = require("mini.clue")
  -- stylua: ignore
  -- Standard Vim text objects + mini.ai default aliases (f, a, q)
  local text_objects = {
    ['w'] = 'Word',          ['W'] = 'WORD',
    ['s'] = 'Sentence',      ['p'] = 'Paragraph',
    ['['] = 'Square [',      [']'] = 'Square ]',
    ['('] = 'Parentheses',   [')'] = 'Parentheses',   ['b'] = 'Parentheses (b)',
    ['{'] = 'Braces',        ['}'] = 'Braces',        ['B'] = 'Braces (B)',
    ['<'] = 'Angle <',       ['>'] = 'Angle >',       ['t'] = 'Tag',
    ['\''] = 'Single Quote', ['"'] = 'Double Quote',  ['`'] = 'Backtick',
    -- mini.ai specific defaults
    ['f'] = 'Function call', ['a'] = 'Argument',      ['q'] = 'Quote',
  }
-- Native Operators (What you do)
  local operators = {
    { mode = 'n', keys = 'c', desc = 'Change' },
    { mode = 'n', keys = 'd', desc = 'Delete' },
    { mode = 'n', keys = 'y', desc = 'Yank (Copy)' },
    { mode = 'n', keys = 'v', desc = 'Visual Mode' },
  }

  -- Native Motion Prefixes (Where you look/move)
  local motions = {
    ['f'] = 'Find next character', ['F'] = 'Find prev character',
    ['t'] = 'Till next character', ['T'] = 'Till prev character',
    ['['] = 'Previous...',         [']'] = 'Next...',
  }

  -- Generate clue dictionary
  local generated_clues = {
    Config.leader_group_clues,
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers({ show_contents = true }),
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.windows({ submode_resize = true }),
    miniclue.gen_clues.z(),
  }

  -- Inject Native Operators
  for _, op in ipairs(operators) do
    table.insert(generated_clues, op)
  end

  -- Inject Motion tooltips
  for key, desc in pairs(motions) do
    table.insert(generated_clues, { mode = 'n', keys = key, desc = desc })
    table.insert(generated_clues, { mode = 'x', keys = key, desc = desc })
  end

  -- Inject Text Objects (both 'i'nner and 'a'round variants)
  for key, desc in pairs(text_objects) do
    for _, mode in ipairs({ 'o', 'x' }) do
      table.insert(generated_clues, { mode = mode, keys = 'i' .. key, desc = 'Inner ' .. desc })
      table.insert(generated_clues, { mode = mode, keys = 'a' .. key, desc = 'Around ' .. desc })
    end
  end

  miniclue.setup({
    window = {
      delay = 150,
      config = function(bufnr)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local max_len = 0
        for _, line in ipairs(lines) do
          max_len = math.max(max_len, vim.fn.strwidth(line))
        end

        -- Clamp width: minimum 30 chars, maximum 45 chars
        local width = math.min(math.max(max_len + 2, 30), 45)

        return {
          border = "double",
          width = width,
        }
      end,
    },
    -- Define which clues to show. By default shows only clues for custom mappings
    -- (uses `desc` field from the mapping; takes precedence over custom clue).
    clues = {
      generated_clues,
      -- This is defined in 'plugin/20_keymaps.lua' with Leader group descriptions
      -- Config.leader_group_clues,
      -- miniclue.gen_clues.builtin_completion(),
      -- miniclue.gen_clues.g(),
      -- miniclue.gen_clues.marks(),
      -- miniclue.gen_clues.registers({ show_contents = true }),
      -- miniclue.gen_clues.square_brackets(),
      -- miniclue.gen_clues.windows({ submode_resize = true }),
      -- miniclue.gen_clues.z(),
    },
    -- Explicitly opt-in for set of common keys to trigger clue window
    triggers = {
      { mode = { "n", "x" },  keys = "<Leader>" }, -- Leader triggers
      { mode = "n",           keys = "\\" }, -- mini.basics
      { mode = { "n", "x" },  keys = "[" }, -- mini.bracketed
      { mode = { "n", "x" },  keys = "]" },
      { mode = "i",           keys = "<C-x>" }, -- Built-in completion
      { mode = { "n", "x" },  keys = "g" }, -- `g` key
      { mode = { "n", "x" },  keys = "'" }, -- Marks
      { mode = { "n", "x" },  keys = "`" },
      { mode = { "n", "x" },  keys = '"' }, -- Registers
      { mode = { "i", "c" },  keys = "<C-r>" },
      { mode = "n",           keys = "<C-w>" }, -- Window commands
      { mode = { "n", "x" },  keys = "s" }, -- `s` key (mini.surround, etc.)
      { mode = { "n", "x" },  keys = "z" }, -- `z` key
      -- Text object targets (trigged inside visual/operator-pending modes)
      { mode = 'o', keys = 'i' }, { mode = 'o', keys = 'a' },
      { mode = 'x', keys = 'i' }, { mode = 'x', keys = 'a' },
    },
  })
end)

later(function()
  require("mini.comment").setup()
end)

later(function()
  require("mini.cursorword").setup()
end)

-- Git diff indicators
later(function()
  require("mini.diff").setup({
    view = {
      style = "number",
    },
  })
end)

-- Git integration & custom blame split

-- 1. Define custom highlight groups (or link to your colorscheme's groups)
vim.api.nvim_set_hl(0, "GitBlameHash", { link = "Identifier", default = true })
vim.api.nvim_set_hl(0, "GitBlameAuthor", { link = "Function", default = true })
vim.api.nvim_set_hl(0, "GitBlameDate", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "GitBlameLine", { link = "Number", default = true })

later(function()
  require("mini.git").setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniGitCommandSplit",
    callback = function(ev)
      if ev.data.git_subcommand ~= "blame" then
        return
      end

      local win_src = ev.data.win_source
      local win_blame = ev.data.win_stdout
      local buf_blame = ev.buf

      -- 1. Window & Buffer settings
      vim.bo[buf_blame].modifiable = false
      vim.bo[buf_blame].buftype = "nofile"
      vim.wo[win_blame].wrap = false
      vim.wo[win_blame].cursorline = true
      vim.wo[win_blame].number = false
      vim.wo[win_blame].relativenumber = false

      -- 2. Synchronize view and cursor between blame and source
      vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
      vim.api.nvim_win_set_cursor(win_blame, { vim.fn.line(".", win_src), 0 })
      vim.wo[win_blame].scrollbind = true
      vim.wo[win_src].scrollbind = true
      vim.wo[win_blame].cursorbind = true
      vim.wo[win_src].cursorbind = true

      -- 3. Auto-cleanup: Reset source window bindings when blame buffer closes
      vim.api.nvim_create_autocmd({ "BufWipeout", "BufHidden" }, {
        buffer = buf_blame,
        once = true,
        callback = function()
          if vim.api.nvim_win_is_valid(win_src) then
            vim.wo[win_src].scrollbind = false
            vim.wo[win_src].cursorbind = false
          end
        end,
      })

      -- 4. Convenient 'q' keymap to close blame split quickly
      vim.keymap.set("n", "q", "<Cmd>close<CR>", {
        buffer = buf_blame,
        nowait = true,
        desc = "Close Blame Split",
      })

      -- 5. Auto-resize width to fit blame metadata
      local lines = vim.api.nvim_buf_get_lines(buf_blame, 0, 50, false)
      local max_width = 0
      for _, line in ipairs(lines) do
        local header = line:match("^(%S+%s+%b())")
        if header then
          max_width = math.max(max_width, vim.fn.strwidth(header))
        end
      end
      if max_width > 0 then
        vim.api.nvim_win_set_width(win_blame, max_width + 2)
      end

      -- 6. Add syntax highlights directly to the blame window
      vim.api.nvim_win_call(win_blame, function()
        vim.fn.matchadd("GitBlameHash", [[^\^\?\x\+]])
        vim.fn.matchadd("GitBlameAuthor", [[\s\+(\zs[^0-9]\+\ze\s\+\d]])
        vim.fn.matchadd("GitBlameDate", [[\d\{4}-\d\{2}-\d\{2}[^)]*]])
        vim.fn.matchadd("GitBlameLine", [[\d\+\ze)\s]])
      end)

      vim.cmd("redraw")
    end,
  })
end)

-- Pattern highlights (TODO, FIXME, hex colors)
later(function()
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = "%f[%w]()FIXME%S*()", group = "MiniHipatternsFixme" },
      hack = { pattern = "%f[%w]()HACK%S*()", group = "MiniHipatternsHack" },
      todo = { pattern = "%f[%w]()TODO%S*()", group = "MiniHipatternsTodo" },
      note = { pattern = "%f[%w]()NOTE%S*()", group = "MiniHipatternsNote" },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

later(function()
  require("mini.indentscope").setup()
end)

later(function()
  require("mini.input").setup()
end)

later(function()
  require("mini.jump").setup()
end)

later(function()
  require("mini.jump2d").setup({
    view = { dim = true },
    allowed_lines = {
      blank = false,
      folded = false,
    },
  })
end)

later(function()
  require("mini.keymap").setup()
  MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })
end)

-- Code minimap
later(function()
  local map = require("mini.map")
  map.setup({
    symbols = { encode = map.gen_encode_symbols.dot("4x2") },
    integrations = {
      map.gen_integration.builtin_search(),
      map.gen_integration.diff(),
      map.gen_integration.diagnostic(),
    },
  })

  for _, key in ipairs({ "n", "N", "*", "#" }) do
    local rhs = key
      .. "zv"
      .. "<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
    vim.keymap.set("n", key, rhs)
  end
end)

later(function()
  require("mini.move").setup()
end)

later(function()
  require("mini.pairs").setup({ modes = { command = true } })
end)

later(function()
  require("mini.pick").setup()
end)

-- Snippet expansion & loader
later(function()
  local latex_patterns = { "latex/**/*.json", "**/latex.json" }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    markdown_inline = { "markdown.json" },
  }

  local snippets = require("mini.snippets")
  local config_path = vim.fn.stdpath("config")
  snippets.setup({
    snippets = {
      snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
      snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })
end)

later(function()
  require("mini.splitjoin").setup()
end)

later(function()
  require("mini.surround").setup()
end)

later(function()
  require("mini.trailspace").setup()
end)

later(function()
  require("mini.visits").setup()
end)
