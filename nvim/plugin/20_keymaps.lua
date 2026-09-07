-- stylua: ignore start

local map = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  local modes = type(mode) == "table" and mode or vim.split(mode, "")
  vim.keymap.set(modes, lhs, rhs, opts)
end

local start_jump = "<Cmd>lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<CR>"

-- General Mappings ===========================================================
map("n",  "<Esc>",        "<cmd>nohlsearch<cr>",                  "Clear search highlights")
map("x",  "<",            "<gv",                                  "Indent left and keep visual selection")
map("x",  ">",            ">gv",                                  "Indent right and keep visual selection")
map("n",  "z=",           "<cmd>Pick spellsuggest<cr>",           "Pick Suggestions")
map("nx", "<CR>",         start_jump,                             "Jump to single character")

-- Terminal
map("t",  "<Esc><Esc>",   "<C-\\><C-n>",                          "Exit terminal mode")
map("t",  "<C-h>",        "<cmd>wincmd h<CR>",                    "Go to Left Window")
map("t",  "<C-j>",        "<cmd>wincmd j<CR>",                    "Go to Lower Window")
map("t",  "<C-k>",        "<cmd>wincmd k<CR>",                    "Go to Upper Window")
map("t",  "<C-l>",        "<cmd>wincmd l<CR>",                    "Go to Right Window")

-- Buffers & Registers
map("n",  "[p",           "<Cmd>exe \"iput! \" . v:register<CR>", "Paste Above")
map("n",  "]p",           "<Cmd>exe \"iput \"  . v:register<CR>", "Paste Below")
map("n",  "H",            "<cmd>bprevious<cr>",                   "Prev Buffer")
map("n",  "L",            "<cmd>bnext<cr>",                       "Next Buffer")

-- Leader mappings ============================================================

-- Global table for mini.clue leader group descriptions
Config.leader_group_clues = {
  { mode = "n", keys = "<Leader>a", desc = "+[A]i" },
  { mode = "n", keys = "<Leader>b", desc = "+[B]uffer" },
  { mode = "n", keys = "<Leader>c", desc = "+[C]ode/Lsp" },
  { mode = "n", keys = "<Leader>f", desc = "+[F]ind/Files" },
  { mode = "n", keys = "<Leader>g", desc = "+[G]it" },
  { mode = "n", keys = "<Leader>o", desc = "+[O]ther" },
  { mode = "n", keys = "<Leader>q", desc = "+[Q]uit/Session" },
  { mode = "n", keys = "<Leader>s", desc = "+[S]earch" },
  { mode = "n", keys = "<Leader>t", desc = "+[T]erminal" },
  { mode = "n", keys = "<Leader>v", desc = "+[V]isits" },

  { mode = "x", keys = "<Leader>g", desc = "+[G]it" },
  { mode = "x", keys = "<Leader>c", desc = "+[C]ode/Lsp" },
  { mode = "x", keys = "<Leader>s", desc = "+[S]earch" },
}

-- Mostly used
map("n",  "<leader><leader>", "<Cmd>Pick files<CR>",                  "Find Files")
map("n",  "<leader>,",        "<Cmd>Pick buffers<CR>",                "Find Buffers")
map("n",  "<leader>/",        "<Cmd>Pick grep_live<CR>",              "Grep live")
map("n",  "<leader>:",        "<Cmd>Pick history<CR>",                "Command History")

-- ---------------------------------------------------------------------------
-- [A]I
-- ---------------------------------------------------------------------------
map("n",  "<leader>aa",       "<cmd>Sidekick cli toggle<cr>",                 "Sidekick CLI Toggle")
map("n",  "<leader>as",       "<cmd>Sidekick cli select<cr>",                 "Sidekick CLI Select")
map("n",  "<leader>ad",       "<cmd>Sidekick cli close<cr>",                  "Sidekick CLI Detach")
map("nx", "<leader>ap",       "<cmd>Sidekick cli prompt<cr>",                 "Select Prompt")
map("nx", "<leader>at",       "<cmd>Sidekick cli send msg=\"{this}\"<cr>",      "Send This")
map("n",  "<leader>af",       "<cmd>Sidekick cli send msg=\"{file}\"<cr>",      "Send File")
map("x",  "<leader>av",       "<cmd>Sidekick cli send msg=\"{selection}\"<cr>", "Send Selection")

-- ---------------------------------------------------------------------------
-- [B]uffers
-- ---------------------------------------------------------------------------
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

map("n",  "<leader>ba",       "<Cmd>b#<CR>",                                 "Alternate")
map("n",  "<leader>bo",       "<Cmd>%bd|e#|bd#<CR>",                         "Delete Others")
map("n",  "<leader>bd",       "<Cmd>lua MiniBufremove.delete()<CR>",         "Delete")
map("n",  "<leader>bD",       "<Cmd>lua MiniBufremove.delete(0, true)<CR>",  "Delete!")
map("n",  "<leader>bs",       new_scratch_buffer,                            "Scratch")
map("n",  "<leader>bw",       "<Cmd>lua MiniBufremove.wipeout()<CR>",        "Wipeout")
map("n",  "<leader>bW",       "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", "Wipeout!")


-- ---------------------------------------------------------------------------
-- [F]ile & [F]ind & Explorer
-- ---------------------------------------------------------------------------
local explore_at_file = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"
local toggle_explorer = function()
  if not (MiniFiles and MiniFiles.close()) then
    MiniFiles.open()
  end
end
local find_config = "<Cmd>lua MiniPick.builtin.files({}, { source = { cwd = vim.fn.stdpath(\"config\") } })<CR>"

map("n",  "<leader>e",        toggle_explorer,                        "Explorer (Toggle)")
map("n",  "<leader>fm",       explore_at_file,                        "File Manager (buf)")
map("n",  "<leader>fM",       "<Cmd>lua MiniFiles.open()<CR>",        "File Manager (cwd)")
map("n",  "<leader>fn",       "<cmd>enew<cr>",                        "New File")
map("n",  "<leader>ff",       "<Cmd>Pick files<CR>",                  "Find Files (Root)")
map("n",  "<leader>fb",       "<Cmd>Pick buffers<CR>",                "Buffers")
map("n",  "<leader>fc",       find_config,                            "Config")
map("n",  "<leader>fg",       "<cmd>Pick git_files<CR>",              "Git Files")
map("n",  "<leader>fr",       "<Cmd>Pick oldfiles<CR>",               "Recent Files")
map("n",  "<leader>fT",       "<Cmd>Pick colorschemes<CR>",           "Colorschemes")
map("n",  "<leader>fv",       "<Cmd>Pick visit_paths cwd=\"\"<CR>",   "Visit Paths (All)")
map("n",  "<leader>fV",       "<Cmd>Pick visit_paths<CR>",            "Visit Paths (CWD)")

-- ---------------------------------------------------------------------------
-- [S]earch
-- ---------------------------------------------------------------------------
local search_quickfix = function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end
local search_locations = function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end

local pickers = require("utils.pickers")

map("n",  "<leader>sb",       "<Cmd>Pick buf_lines scope=\"current\"<CR>",          "Lines (buf)")
map("n",  "<leader>sB",       "<Cmd>Pick buf_lines scope=\"all\"<CR>",              "Lines (all)")
map("n",  "<leader>sg",       "<Cmd>Pick grep_live<CR>",                            "Grep live")
map("n",  "<leader>sw",       "<Cmd>Pick grep pattern=\"<cword>\"<CR>",             "Grep current word")
map("n",  "<leader>sd",       "<Cmd>Pick diagnostic scope=\"current\"<CR>",         "Diagnostic buffer")
map("n",  "<leader>sD",       "<Cmd>Pick diagnostic scope=\"all\"<CR>",             "Diagnostic workspace")
map("n",  "<leader>ss",       "<Cmd>Pick lsp scope=\"document_symbol\"<CR>",        "Symbols document")
map("n",  "<leader>sS",       "<Cmd>Pick lsp scope=\"workspace_symbol_live\"<CR>",  "Symbols workspace (live)")
-- map("n",  "<leader>st",       "<Cmd>Pick hipatterns<CR>",                           "TODO/FIXME")
map("n",  "<leader>st",    pickers.pick_todo,                           "TODO/FIXME")
map("n",  "<leader>sT",       "<Cmd>Pick treesitter<CR>",                           "Treesitter")
map("n",  "<leader>sh",       "<Cmd>Pick help<CR>",                                 "Help")
map("n",  "<leader>sH",       "<Cmd>Pick hl_groups<CR>",                            "Highlight groups")
map("n",  "<leader>sk",       "<Cmd>Pick keymaps<CR>",                              "Keymaps")
map("n",  "<leader>sm",       "<Cmd>Pick marks<CR>",                                "Marks")
map("n",  "<leader>sM",       "<Cmd>Pick manpages<CR>",                             "Man Pages")
map("n",  "<leader>sr",       "<Cmd>lua require(\"grug-far\").open()<CR>",                  "Search and Replace")
map("x",  "<leader>sr",       "<Cmd>lua require(\"grug-far\").with_visual_selection()<CR>",  "Search and Replace")
map("n",  "<leader>sR",       "<Cmd>Pick resume<CR>",                               "Resume")
map("n",  "<leader>sq",       search_quickfix,                                      "Quickfix list")
map("n",  "<leader>sQ",       search_locations,                                     "Location list")
map("n",  "<leader>s/",       "<Cmd>Pick history scope=\"/\"<CR>",                  "\"/\" history")
map("n",  "<leader>s:",       "<Cmd>Pick history scope=\":\"<CR>",                  "\":\" history")

-- ---------------------------------------------------------------------------
-- [G]it
-- ---------------------------------------------------------------------------
local term = require("utils.terminal")

map("n",  "<leader>gg",       "<cmd>Neogit<cr>",                        "Neogit")
map("nt", "<leader>gG",       term.toggle_lazygit,                      "LazyGit")
map("n",  "<leader>gb",       "<Cmd>vert Git blame -- %<CR>",           "Blame (File Split)")
map("n",  "<leader>gB",       "<Cmd>Pick git_branches<CR>",             "Branches")
map("n",  "<leader>gd",       "<Cmd>Pick git_hunks<CR>",                "Diff")
map("nx", "<leader>gs",       "<Cmd>lua MiniGit.show_at_cursor()<CR>",  "Show at Cursor")
map("n",  "<leader>gl",       "<Cmd>Pick git_commits<CR>",              "Commits (Project)")
map("n",  "<leader>gL",       "<Cmd>Pick git_commits path=\"%\"<CR>",     "Commits (File)")
map("nx", "<leader>gr",       "<Cmd>lua MiniGit.show_range_history()<CR>", "Range History")
map("n",  "<leader>go",       "<Cmd>lua MiniDiff.toggle_overlay()<CR>",  "Toggle overlay")

-- ---------------------------------------------------------------------------
-- [C]ode/Lsp & Diagnostics
-- ---------------------------------------------------------------------------

-- Unmap Neovim 0.11/0.12 default LSP keymaps that collide with `gr` (Goto References)
for _, key in ipairs({ "gra", "grn", "grr", "gri", "grt", "grx" }) do
  pcall(vim.keymap.del, "n", key)
  pcall(vim.keymap.del, "x", key)
end

map("n",  "gd",               "<Cmd>Pick lsp scope=\"definition\"<CR>",      "Goto Definition")
map("n",  "gD",               "<Cmd>Pick lsp scope=\"declaration\"<CR>",     "Goto Declaration")
map("n",  "gr",               "<Cmd>Pick lsp scope=\"references\"<CR>",      "Goto References")
map("n",  "gI",               "<Cmd>Pick lsp scope=\"implementation\"<CR>",  "Goto Implementation")
map("n",  "K",                "<Cmd>lua vim.lsp.buf.hover()<CR>",           "Hover Documentation")
map("n",  "gK",               "<Cmd>lua vim.lsp.buf.signature_help()<CR>",  "Signature Help")

map("nx", "<leader>ca",       "<Cmd>lua vim.lsp.buf.code_action()<CR>",      "Actions")
map("n",  "<leader>cd",       "<Cmd>lua vim.diagnostic.open_float()<CR>",    "Diagnostic popup")
map("nx", "<leader>cf",       "<Cmd>lua require(\"conform\").format()<CR>",    "Format")
map("n",  "<leader>cl",       "<cmd>checkhealth vim.lsp<cr>",                "LSP Information")
map("n",  "<leader>cc",       "<Cmd>lua vim.lsp.codelens.run()<CR>",         "Lens")
map("n",  "<leader>cr",       "<Cmd>lua vim.lsp.buf.rename()<CR>",           "Rename")
map("n",  "<leader>cm",       "<cmd>Mason<cr>",                              "Mason Tool Manager")

-- Jump between errors quickly
map("n",  "]e",               function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end,  "Next Error")
map("n",  "[e",               function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, "Prev Error")

-- ---------------------------------------------------------------------------
-- [O]thers
-- ---------------------------------------------------------------------------
map("n",  "<leader>or",       "<Cmd>lua MiniMisc.resize_window()<CR>",        "Resize to default width")
map("n",  "<leader>ot",       "<Cmd>lua MiniTrailspace.trim()<CR>",           "Trim trailspace")
map("n",  "<leader>oz",       "<Cmd>lua MiniMisc.zoom()<CR>",                 "Zoom toggle")
map("n",  "<leader>on",       "<Cmd>lua MiniNotify.show_history()<CR>",       "Show Notifications")

local session_new = "vim.ui.input({ prompt = \"Session name: \" }, MiniSessions.write)"

-- ---------------------------------------------------------------------------
-- [Q]uit / Sessions
-- ---------------------------------------------------------------------------
map("n",  "<leader>qd",       "<Cmd>lua MiniSessions.select(\"delete\")<CR>", "Delete")
map("n",  "<leader>qn",       "<Cmd>lua " .. session_new .. "<CR>",          "New")
map("n",  "<leader>qr",       "<Cmd>lua MiniSessions.select(\"read\")<CR>",   "Read")
map("n",  "<leader>qR",       "<Cmd>lua MiniSessions.restart()<CR>",         "Restart")
map("n",  "<leader>qw",       "<Cmd>lua MiniSessions.write()<CR>",           "Write current")
map("n",  "<leader>qq",       "<cmd>quitall<cr>",                            "Quit Neovim")

-- ---------------------------------------------------------------------------
-- [T]erminal
-- ---------------------------------------------------------------------------
map("nt", "<C-_>",            term.toggle_terminal,                          "Floating Terminal")
map("n",  "<leader>tT",       "<Cmd>horizontal term<CR>",                    "Terminal (horizontal)")
map("n",  "<leader>tt",       "<Cmd>vertical term<CR>",                      "Terminal (vertical)")

-- ---------------------------------------------------------------------------
-- [V]isits
-- ---------------------------------------------------------------------------
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = "core", sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

map("n",  "<leader>vc",       make_pick_core("", "Core visits (all)"),        "Core visits (all)")
map("n",  "<leader>vC",       make_pick_core(nil, "Core visits (cwd)"),       "Core visits (cwd)")
map("n",  "<leader>vv",       "<Cmd>lua MiniVisits.add_label(\"core\")<CR>",    "Add \"core\" label")
map("n",  "<leader>vV",       "<Cmd>lua MiniVisits.remove_label(\"core\")<CR>", "Remove \"core\" label")
map("n",  "<leader>vl",       "<Cmd>lua MiniVisits.add_label()<CR>",          "Add label")
map("n",  "<leader>vL",       "<Cmd>lua MiniVisits.remove_label()<CR>",       "Remove label")

-- ---------------------------------------------------------------------------
-- [\] Option Toggles (Extends mini.basics)
-- ---------------------------------------------------------------------------
map("n",  "\\H",              function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, "Toggle inlay hints")
map("n",  "\\I",              function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, "Toggle inlay hints")
map("n",  "\\T",              function() require("treesitter-context").toggle() end,                         "Toggle Treesitter context")
map("n",  "\\g",              function() MiniDiff.toggle_overlay() end,                                      "Toggle diff overlay")
map("n",  "\\k",              function() vim.wo.colorcolumn = vim.wo.colorcolumn == "" and "+1" or "" end,   "Toggle colorcolumn")
map("n",  "\\D",              function()
  local cur = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = not cur })
end, "Toggle diagnostic virtual lines")
map("n",  "\\f",              function()
  vim.g.autoformat = not (vim.g.autoformat == nil and true or vim.g.autoformat)
  vim.notify("Autoformat: " .. (vim.g.autoformat and "enabled" or "disabled"))
end, "Toggle autoformat")

-- stylua: ignore end
