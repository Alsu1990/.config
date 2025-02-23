local M = {
    -- highlight
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "verilog",
                "tcl",
                "make",
            })
        end,
    },

    -- LSP
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
                svlangserver = {
                    cmd = { "svlangserver" },
                    filetypes = { "verilog", "systemverilog" },
                    root_dir = require("lspconfig").util.root_pattern(
                        ".svlangserver",
                        ".git"
                    ),
                    settings = {
                        systemverilog = {
                            includeIndexing = {
                                "*.{v,vh,sv,svh}",
                                "**/*.{v,vh,sv,svh}",
                                -- "/tools/Xilinx/Vivado/2023.2/data/verilog/src/unimacro/*.{v,vh,sv,svh}",
                                -- "/tools/Xilinx/Vivado/2023.2/data/verilog/src/unisims/*.{v,vh,sv,svh}",
                            },
                            linter = "verilator",
                            launchConfiguration = "verilator --sv --Wall --lint-only",
                            formatCommand = "verible-verilog-format --indentation_spaces 4",
                        },
                    },
                },
            },
        },
        setup = {},
    },
}

return M
