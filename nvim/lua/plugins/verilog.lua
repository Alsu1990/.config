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
                "verible",
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                verible = {
                    cmd = { "verible-verilog-ls --indentation_spaces 4" },
                    filetypes = { "verilog", "systemverilog" },
                    root_dir = require("lspconfig").util.root_pattern(
                        "verible.filelist",
                        ".git"
                    ),
                },
            },
        },
        setup = {},
    },
}

return M
