-- Keymaps

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
-- Mapping helpers to make clean and easy to align with mini.align
local map = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  vim.keymap.set(vim.split(mode, ''), lhs, rhs, opts)
end

local L = function(key)
  return '<leader>' .. key
end
local C = function(cmd)
  return '<Cmd>' .. cmd .. '<CR>'
end

local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end


-- stylua: ignore start
-- ---------------------------------------------------------------------------
-- Leader mappings
-- ---------------------------------------------------------------------------
Config.leader_group_clues = {
  { mode = "n",        keys = L"b",  desc = "+Buffer" },
  { mode = {"n", "x"}, keys = L"a",  desc = "+Ai" },
  { mode = "n",        keys = L"e",  desc = "+Explore" },
  { mode = "n",        keys = L"f",  desc = "+Find" },
  { mode = {"n", "x"}, keys = L"g",  desc = "+Git" },
  { mode = {"n", "x"}, keys = L"l",  desc = "+Language" },
  { mode = "n",        keys = L"o",  desc = "+Other" },
  { mode = "n",        keys = L"s",  desc = "+Session" },
  { mode = "n",        keys = L"v",  desc = "+Visits" },
  { mode = "n",        keys = L"w",  desc = "+Window" },
}
-- ---------------------------------------------------------------------------
-- General Mappings
-- ---------------------------------------------------------------------------

-- Better popup window escaping
Config.new_autocmd(
  'FileType',
  { 'help', 'startuptime', 'qf', 'lspinfo', 'man', 'checkhealth', 'terminal' },
  function()
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = true, silent = true })
  end
)

vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')
map("i",   "<A-Space>", C"normal ciw ",                                        "Just one space")
map("n",   "H",         C"lua MiniBracketed.buffer('backward')",               "Prev buffer")
map("n",   "L",         C"lua MiniBracketed.buffer('forward')",                "Next buffer")
map("n",   "z=",        C"Pick spellsuggest",                                  "Spelling suggestions")
map("n",   "[p",        C'exe "iput! " . v:register',                          "Paste Above")
map("n",   "]p",        C'exe "iput "  . v:register',                          "Paste Below")

-- ---------------------------------------------------------------------------
-- Frequently Used Pickers
-- ---------------------------------------------------------------------------

map("n",   L" ",        C"FzfLua files",                                       "Find Files")
map("n",   L",",        C"FzfLua buffers",                                     "Find Buffers")
map("n",   L"/",        C"FzfLua blines",                                      "Lines (current buffer)")

-- ---------------------------------------------------------------------------
-- Buffer
-- ---------------------------------------------------------------------------

map("n",   L"ba",       C"b#",                                                 "Alternate buffer")
map("n",   L"bd",       C"lua MiniBufremove.delete()",                         "Delete buffer")
map("n",   L"bD",       C"%bd|e#|bd#",                                         "Delete other buffers")
map("n",   L"bs",       new_scratch_buffer,                                    "New scratch buffer")
map("n",   L"bt",       C"lua MiniTrailspace.trim()",                          "Trim trailspace")
map("n",   L"bu",       C"lua MiniBufremove.unshow()",                         "Unshow buffer")
map("n",   L"bw",       C"lua MiniBufremove.wipeout()",                        "Wipeout buffer")

-- ---------------------------------------------------------------------------
-- Copilot
-- ---------------------------------------------------------------------------
-- TODO: integrate sidekick.nvim

-- map("nx",  L"cc",       C"CodeCompanionChat Toggle",                           "Code Companion chat")
-- map("nx",  L"cC",       C"CodeCompanionActions",                               "Code Companion actions")

-- ---------------------------------------------------------------------------
-- Explore
-- ---------------------------------------------------------------------------

local pick_config = function()
  MiniPick.builtin.files(nil,{source = {cwd = vim.fn.stdpath('config')}})
end

map("n",   "-",         C"Oil",                                                "Open parent directory")
map("n",   L"ec",       pick_config,                                           "Config")
map("n",   L"ed",       C"lua MiniFiles.open()",                               "Directory (cwd)")
map("n",   L"ef",       C"lua MiniFiles.open(vim.api.nvim_buf_get_name(0))",   "Directory (file)")
map("n",   L"en",       C"lua MiniNotify.show_history()",                      "Notifications")
map("n",   L"eq",       C"FzfLua quickfix",                                      "Quickfix")
map("n",   L"el",       C"FzfLua loclist",                                     "Location list")

-- ---------------------------------------------------------------------------
-- Find
-- ---------------------------------------------------------------------------
-- History & General
map("n",   L"f/",       C"FzfLua search_history",                  '"/" history')
map("n",   L"f:",       C"FzfLua command_history",                 '":" history')
map("n",   L"fr",       C"FzfLua resume",                          "Resume last search")
map("n",   L"fT",       C"FzfLua colorschemes",                    "Search colorschemes")
map("n",   L"fh",       C"FzfLua helptags",                        "Help tags")
map("n",   L"fH",       C"FzfLua highlights",                      "Highlight groups")
-- Files & Buffers
map("n",   L"ff",       C"FzfLua files",                           "Files")
map("n",   L"ff",       C"FzfLua files",                           "Config")
map("n",   L"fb",       C"FzfLua buffers",                         "Buffers")
map("n",   L"fv",       C"FzfLua oldfiles",                        "Recent files (all)")
map("n",   L"fV",       C"FzfLua oldfiles cwd_only=true",          "Recent files (cwd)")
-- Search & Grep (Optimized for C++17/Verilog)
map("n",   L"fg",       C"FzfLua live_grep",                       "Grep live")
map("n",   L"fG",       C"FzfLua grep_cword",                      "Grep current word")
map("n",   L"fl",       C"FzfLua lines",                           "Lines (all open buffers)")
map("n",   L"fL",       C"FzfLua blines",                          "Lines (current buffer)")
map("n",   L"ft",       C"FzfLua grep_project { search='TODO|FIXME|HACK|NOTE' }", "Search TODO/FIXME")

-- LSP (High-performance symbol searching)
map("n",   L"fs",       C"FzfLua lsp_live_workspace_symbols",      "Symbols workspace")
map("n",   L"fS",       C"FzfLua lsp_document_symbols",            "Symbols document")
map("n",   L"fR",       C"FzfLua lsp_references",                  "References (LSP)")
map("n",   L"fd",       C"FzfLua diagnostics_workspace",           "Diagnostic (workspace)")
map("n",   L"fD",       C"FzfLua diagnostics_document",            "Diagnostic (buf)")




-- ---------------------------------------------------------------------------
-- Git (Gitsigns & Fzf-Lua Overrides)
-- ---------------------------------------------------------------------------

local gs = package.loaded.gitsigns

-- Diff & Hunks
map("n",   L"ga",       C"FzfLua git_status",                      "Added diff (Status)")
map("n",   L"gA",       C"Gitsigns stage_buffer",                  "Stage whole buffer")
map("n",   L"gd",       C"Gitsigns diffthis",                      "Diff (Hunk vs Index)")
map("n",   L"gD",       C"lua require('gitsigns').diffthis('~')",  "Diff (Hunk vs Last Commit)")
map("n",   L"go",       C"Gitsigns toggle_linehl",                 "Toggle line highlight")

-- Navigation & History
map("nx",  L"gb",       C"FzfLua git_blame",                       "Blame history (Fzf)")
map("nx",  L"gs",       C"Gitsigns preview_hunk_inline",           "Show hunk at cursor")
map("n",   L"gl",       C"FzfLua git_commits",                     "Log (Project)")
map("n",   L"gL",       C"FzfLua git_bcommits",                    "Log (Buffer)")

-- Commit & Workflow
map("n",   L"gg",       C"lua Config.toggle_lazygit()",        "Toggle Lazygit")

-- Hunk Actions (The 'No-Mouse' Power Moves)
map("n",   L"ghs",      C"Gitsigns stage_hunk",                    "Stage Hunk")
map("n",   L"ghr",      C"Gitsigns reset_hunk",                    "Reset Hunk")
map("v",   L"ghs",      function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, "Stage Range")
map("n",   L"ghu",      C"Gitsigns undo_stage_hunk",               "Undo stage hunk")

-- Quickfix
map("n",   L"gq",       C"Gitsigns setqflist all",              "Quickfix all hunks")
-- ---------------------------------------------------------------------------
-- Language
-- ---------------------------------------------------------------------------

map("nx",  L"la",       C"lua vim.lsp.buf.code_action()",                      "Actions")
map("n",   L"ld",       C"lua vim.diagnostic.open_float()",                    "Diagnostic popup")
map("nx",  L"lf",       C"lua require('conform').format()",                    "Format")
map("n",   L"li",       C"lua vim.lsp.buf.implementation()",                   "Implementation")
map("n",   L"lI",       C"checkhealth vim.lsp",                                "LSP info")
map("n",   L"lh",       C"lua vim.lsp.buf.hover()",                            "Hover")
map("n",   L"ll",       C"lua vim.lsp.codelens.run()",                         "Run codelens")
map("n",   L"lL",       C"lua vim.lsp.codelens.refresh()",                     "Refresh & display codelens")
map("n",   L"lr",       C"lua vim.lsp.buf.rename()",                           "Rename")
map("n",   L"lR",       C"lua vim.lsp.buf.references()",                       "References")
map("n",   L"ls",       C"lua vim.lsp.buf.definition()",                       "Source definition")
map("n",   L"lt",       C"lua vim.lsp.buf.type_definition()",                  "Type definition")


-- ---------------------------------------------------------------------------
-- Other
-- ---------------------------------------------------------------------------

map("n",   L"oa",       C"Mason",                                              "Mason")
map("n",   L"os",       C"lua MiniStarter.open()",                             "Open MiniStarter")
map("n",   L"ou",       C"lua vim.pack.update()",                              "Update deps")
map("n",   L"or",       C"lua MiniMisc.resize_window()",                       "Resize to default width")
map("n",   L"ot",       C"lua MiniTrailspace.trim()",                          "Trim trailspace")
map("n",   L"oz",       C"lua MiniMisc.zoom()",                                "Zoom toggle")

-- ---------------------------------------------------------------------------
-- Session
-- ---------------------------------------------------------------------------

map("n",   L"sd",       C"lua MiniSessions.select('delete')",                  'Delete session')
map("n",   L"sl",       C"lua MiniSessions.select('read')",                    'Load session')
map("n",   L"sn",       C"lua MiniSessions.write(vim.fn.input('Name: '))",     'New session')
map("n",   L"ss",       C"lua MiniSessions.write()",                           'Save session')

-- ---------------------------------------------------------------------------
-- Visits
-- ---------------------------------------------------------------------------
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

map("n",   L"va",       C"Pick visit_labels cwd=''",                           "All labels")
map("n",   L"vc",       make_pick_core('',  'Core visits (all)'),              "Core visits (all)")
map("n",   L"vC",       make_pick_core(nil, 'Core visits (cwd)'),              "Core visits (cwd)")
map("n",   L"vl",       C"lua MiniVisits.add_label()",                         "Add label")
map("n",   L"vL",       C"lua MiniVisits.remove_label()",                      "Remove label")
map("n",   L"vv",       C"lua MiniVisits.add_label('core')",                   "Add core label")
map("n",   L"vV",       C"lua MiniVisits.remove_label('core')",                "Remove core label")

-- stylua: ignore end
