-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

-- use system clipboard
vim.opt.clipboard = "unnamedplus"

vim.g.autoformat = false

-- file extensions
vim.filetype.add({
    extension = {
        core = "yaml",
        xdc = "tcl",
        vh = "verilog",
        svh = "systemverilog",
    },
})