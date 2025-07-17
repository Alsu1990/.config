local M = {
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            -- change clangd fallback to google
            opts.servers.clangd.cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=webkit",
            }
        end,
    },
}

return M
