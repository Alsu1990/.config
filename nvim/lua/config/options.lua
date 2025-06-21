-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.lsp.set_log_level("off")

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
        tss = "tcl",
        pcf = "tcl",
        xdc = "tcl",
        fdc = "tcl",
        sdc = "tcl",
        idc = "tcl",
        utf = "tcl",
        auto = "verilog",
        vstub = "verilog",
        v = "verilog",
        vh = "verilog",
        svh = "verilog",
    },
})
