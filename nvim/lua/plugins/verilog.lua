local lsp_servers = {
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
                    -- "{design,emu,fpga,rtl}/**/*.{v,vh,sv,svh}",
                    -- "{grid,pcie,nic,common,shared_ip}/{design,rtl}/**/*.{v,vh,sv,svh}",
                    -- "/tools/Xilinx/Vivado/2023.2/data/verilog/src/unimacro/*.{v,vh,sv,svh}",
                    -- "/tools/Xilinx/Vivado/2023.2/data/verilog/src/unisims/*.{v,vh,sv,svh}",
                },
                excludeIndexing = {
                    -- ".*",
                    "{target,verif,sim,build}/**",
                    "*hard_ip*/",
                },
                linter = "verilator",
                launchConfiguration = "verilator --sv --Wall --lint-only",
                formatCommand = "verible-verilog-format --indentation_spaces 4",
            },
        },
    },
    -- verible = {
    --     cmd = { "verible-verilog-ls", "--file_list_path", ".nvim/verible.filelist" },
    --     filetypes = { "verilog", "systemverilog" },
    --     root_dir = function(fname)
    --         return vim.fs.dirname(
    --             vim.fs.find(".git", { path = fname, upward = true })[1]
    --         )
    --     end,
    -- },
}
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
            vim.list_extend(opts.ensure_installed, vim.tbl_keys(lsp_servers))
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = lsp_servers,
        },
        setup = {},
    },
}

return M
