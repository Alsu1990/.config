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
    -- NOTE: according to "bug: failed to run config for bufferline.nvim #6355"
    -- https://github.com/LazyVim/LazyVim/pull/6354
    {
        "akinsho/bufferline.nvim",
        init = function()
            local bufline = require("catppuccin.groups.integrations.bufferline")
            function bufline.get()
                return bufline.get_theme()
            end
        end,
    },
}
