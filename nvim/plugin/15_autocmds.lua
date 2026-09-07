-- Autocommands ===============================================================

-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.
local f = function()
  vim.cmd("setlocal formatoptions-=c formatoptions-=o")
end
Config.new_autocmd("FileType", nil, f, "Proper 'formatoptions'")

-- Open Help and Man pages in a right vertical split
Config.new_autocmd("FileType", { "help", "man" }, function()
  vim.cmd("wincmd L")
  vim.cmd("vertical resize 85") -- Set comfortable reading width (adjust to preference)
end, "Open help in vertical split")

-- Quick exit from help, man pages, diagnostic lists, and git buffers
Config.new_autocmd("FileType", {
  "help",
  "man",
  "qf",
  "query",
  "checkhealth",
  "lspinfo",
  "startuptime",
  "mininotify*",
}, function(args)
  vim.bo[args.buf].buflisted = false
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = args.buf, silent = true, nowait = true })
end, "Close utility windows with 'q'")

-- Filetypes
vim.filetype.add({
  filename = {
    ["edacloud_bashrc"] = "bash",
    [".bashrc"] = "bash",
    [".bash_profile"] = "bash",
    [".bash_aliases"] = "bash",
  },
  pattern = {
    ["%.bash.*"] = "bash",
    [".*%.bash.*"] = "bash",
  },
  extension = {
    --
    bazelrc = "config",
    -- Core
    core = "yaml",
    -- Bash
    bashrc = "bash",
    -- Tcl
    qel = "tcl",
    fdc = "tcl",
    idc = "tcl",
    pcf = "tcl",
    sdc = "tcl",
    tss = "tcl",
    utf = "tcl",
    xdc = "tcl",
    -- SystemVerilog
    auto = "systemverilog",
    v = "systemverilog",
    veo = "systemverilog",
    vh = "systemverilog",
    vstub = "systemverilog",
    svh = "systemverilog",
    rdl = "systemrdl",
  },
})

