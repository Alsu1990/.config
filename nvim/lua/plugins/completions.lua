return {
    {
        "saghen/blink.cmp",
        opts = function(_, opts)
            opts.keymap = {
                preset = "default",
                ["<C-y>"] = { "select_and_accept" },
            }
        end,
    },
}
