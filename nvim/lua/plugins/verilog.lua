-- lua/plugins/verilog.lua
local lsp_opts = {
    veridian = {

        cmd = { "veridian" },
        filetypes = { "verilog", "systemverilog" },
        -- This function correctly finds the project root based on the .git folder
        root_dir = require("lspconfig").util.root_pattern(
            "veridian.yml",
            ".git"
        ),
    },
    verible = {
        cmd = {
            "verible-verilog-ls",
            "--lsp_enable_hover",
            "--indentation_spaces=4",
            "--rules=-explicit-parameter-storage-type=false",
        },
        filetypes = { "verilog", "systemverilog" },
        -- This function correctly finds the project root based on the .git folder
        root_dir = require("lspconfig").util.root_pattern(
            "verible.filelist",
            ".git"
        ),
    },
    svlangserver = {
        cmd = { "svlangserver" },
        filetypes = { "systemverilog", "verilog" },
        root_dir = require("lspconfig").util.root_pattern(
            ".svlangserver",
            ".git"
        ),
        settings = {
            systemverilog = {
                includeIndexing = {
                    "**/{rtl,include}/**/*.{sv,svh,v,vh,veo,vstub}",
                },
                excludeIndexing = {
                    -- "*venv*/**",
                    -- "{scripts,common,shared_ip,grid,nic,nextcore}/**",
                    -- "verif/**",
                    -- "target/**",
                },
                defines = {},
                linter = "verilator",
                launchConfiguration = "verilator --sv --lint-only --Wall",
                formatCommand = "verible-verilog-format --indentation_spaces=4",
            },
        },
    },
}

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
                -- "svlangserver", -- SystemVerilog LSP server
            })
        end,
    },

    -- Configure the LSP server
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- Add the verible configuration
                verible = lsp_opts.verible,
                -- svlangserver = lsp_opts.svlangserver,
                -- veridian = lsp_opts.veridian,
            },
        },
    },
    {
        "mfussenegger/nvim-lint",
        -- opts = function(_, opts)
        --     vim.list_extend(opts.linters_by_ft, {
        --         verilog = { "verilator" },
        --         systemverilog = { "verilator" },
        --     })
        -- end,
        opts = {
            linters_by_ft = {
                verilog = { "verilator" },
                systemverilog = { "verilator" },
            },
        },
    },
}
