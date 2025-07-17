-- lua/plugins/verilog.lua

return {
    -- Make sure treesitter parsers are installed
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

    -- Configure Mason to install verible
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "verible", -- Ensure verible is installed
            })
        end,
    },

    -- Configure the LSP server
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- Add the verible configuration
                verible = {
                    -- The command to start the language server.
                    -- We point it to a file list in the project's root directory.
                    cmd = {
                        "verible-verilog-ls",
                        "--lsp_enable_hover",
                        "--indentation_spaces=4",
                    },
                    filetypes = { "verilog", "systemverilog" },
                    -- This function correctly finds the project root based on the .git folder
                    root_dir = require("lspconfig").util.root_pattern(
                        "verible.filelist",
                        ".git"
                    ),
                },
            },
        },
    },
}
