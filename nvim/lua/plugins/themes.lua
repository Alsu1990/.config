return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = require("config.catppuccin"),
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
            transparent = false,
            commentStyle = { italic = true },
            keywordsStyle = { italic = true },
            stringsStyle = { bold = true },
            dimInactive = false,
            terminalColors = true,
            overrides = function(colors)
                return {}
            end,
            theme = "dragon",
        },
    },

    { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
