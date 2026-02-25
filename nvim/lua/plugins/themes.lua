return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        -- opts = require("config.catppuccin"),
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
        },
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            compile = true,
            undercurl = true,
            commentStyle = { italic = true },
            functionStyle = {},
            keywordsStyle = { italic = true },
            statementStyle = { bold = true },
            typeStyle = {},
            transparent = false,
            -- stringsStyle = { bold = true },
            dimInactive = true,
            terminalColors = true,
            colors = {
                theme = {
                    all = {
                        ui = {
                            bg_gutter = "none",
                        },
                    },
                },
            },
            theme = "wave",
        },
    },

    { "LazyVim/LazyVim", opts = { colorscheme = "kanagawa" } },
}
