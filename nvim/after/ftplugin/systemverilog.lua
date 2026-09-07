-- Prevent auto-pairs from inadvertently pairing the Verilog tick-macro character (`).
-- Enables seamless entry of pre-processor definitions (`include, `define).
vim.b.minipairs_disable = true

-- Ensure correct indentation for SystemVerilog files
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
