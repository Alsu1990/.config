return {
    "saghen/blink.cmp",
    opts = {
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "copilot" },
        },
        keymap = {
            preset = "none",
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = { "select_next", "fallback" },
            ["<S-Tab>"] = { "select_prev", "fallback" },
            ["<C-space>"] = { "show", "fallback" },
        },
        completion = {
            menu = {
                border = "none",
                winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDoc,CursorLine:BlinkCmpDocCursorLine,Search:None",
            },
            documentation = {
                window = {
                    border = "none",
                    winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDoc,CursorLine:BlinkCmpDocCursorLine,Search:None",
                },
            },
        },
    },
}
