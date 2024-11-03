-- LSP, formatting, linting for various languages

-- [S]Verilog ---------------------------------------------------------------------------------
local svlangserver_opts = {
    cmd = { "svlangserver" },
    filetypes = { "verilog", "systemverilog" },
    root_dir = require("lspconfig").util.root_pattern(".svlangserver", ".git"),
    settings = {
        systemverilog = {
            includeIndexing = {
                "*.{v,vh,sv,svh}",
                "**/*.{v,vh,sv,svh}",
                "/tools/Xilinx/Vivado/2023.2/data/verilog/src/unimacro/*.{v,vh,sv,svh}",
                "/tools/Xilinx/Vivado/2023.2/data/verilog/src/unisims/*.{v,vh,sv,svh}",
            },
            launchConfiguration = "verilator -sv -Wall --lint-only",
            formatCommand = "verible-verilog-format --indentation_spaces 4",
        },
    },
}

local M = {

    -- [S]Verilog ---------------------------------------------------------------------------------
    -- highlight
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "verilog",
                "tcl",
            })
        end,
    },
    -- lspconfig
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "svlangserver",
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                svlangserver = svlangserver_opts,
            },
        },
    },
    -- C/C++
}

return M
