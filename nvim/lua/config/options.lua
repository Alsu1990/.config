-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.lsp.set_log_level("off")

vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

vim.o.scrolloff = 15
-- use system clipboard
vim.opt.clipboard = "unnamedplus"

vim.g.autoformat = false

-- file extensions
local tcl_exts = { "fdc", "idc", "pcf", "sdc", "tss", "utf", "xdc" }
local verilog_exts = { "auto", "v", "veo", "vh", "vstub", "svh" }

local extension = { core = "yaml" }
for _, ext in ipairs(tcl_exts) do
    extension[ext] = "tcl"
end
for _, ext in ipairs(verilog_exts) do
    extension[ext] = "verilog"
end

vim.filetype.add({
    extension = extension,
})
