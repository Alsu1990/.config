local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Tree-sitter ================================================================
now_if_args(function()
  local ts_update = function()
    vim.cmd("TSUpdate")
  end
  Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

  add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-treesitter/nvim-treesitter-context",
  })

  local languages = {
    "lua",
    "vimdoc",
    "markdown",
    "c",
    "cpp",
    "systemverilog",
    "tcl",
    "make",
    "starlark",
    "python",
    "bash",
  }

  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then
    require("nvim-treesitter").install(to_install)
  end

  -- Register language aliases for treesitter
  vim.treesitter.language.register("starlark", "bzl")
  vim.treesitter.language.register("bash", { "sh", "zsh" })

  -- Start tree-sitter on FileType if a parser is available
  local ts_start = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end
  Config.new_autocmd("FileType", "*", ts_start, "Start tree-sitter")

  -- Sticky header showing enclosing scope
  require("treesitter-context").setup({
    max_lines = 3,
    min_window_height = 20,
    mode = "topline",
  })
end)

-- Hook for compiling blink.cmp native fuzzy matcher only on install/update
Config.on_packchanged("blink.cmp", { "install", "update" }, function()
  require("blink.cmp").build():pwait()
end, "Build blink.cmp fuzzy matcher")

-- Snippets, Completion & Language servers =====================================
now_if_args(function()
  add({
    "https://github.com/rafamadriz/friendly-snippets",
    "https://github.com/saghen/blink.lib",
    "https://github.com/saghen/blink.cmp",
    "https://github.com/neovim/nvim-lspconfig",
  })

  local blink = require("blink.cmp")
  blink.setup({
    keymap = {
      preset = "super-tab",
      ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      ghost_text = { enabled = true },
      menu = { border = "rounded" },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    cmdline = {
      enabled = true,
      -- keymap = { preset = "inherit" },
      completion = { menu = { auto_show = true } },
    },
  })

  -- Register Blink capabilities to Neovim 0.12's LSP registry
  vim.lsp.config("*", {
    capabilities = blink.get_lsp_capabilities(),
  })

  vim.lsp.enable({
    "lua_ls",
    "clangd",
    "starpls",
    "ruff",
    "ty",
    "verible",
    "slang_server",
    "bashls",
  })
  vim.lsp.log.set_level("off")
end)

-- Git ========================================================================
now_if_args(function()
  add({ "https://github.com/NeogitOrg/neogit" })

  require("neogit").setup({
    disable_signs = true,
    integrations = {
      mini_pick = true,
    },
  })
end)

-- Formatting =================================================================
later(function()
  add({ "https://github.com/stevearc/conform.nvim" })
  require("conform").setup({
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      bzl = { "buildifier" },
      starlark = { "buildifier" },
      zsh = { "shfmt" },
      sh = { "shfmt" },
      python = { "ruff_format", "ruff_organize_imports" },
    },
    formatters = {
      buildifier = {
        prepend_args = { "-warnings=-load-on-top" },
      },
    },
  })
end)

-- AI =========================================================================
later(function()
  add({ "https://github.com/folke/sidekick.nvim" })
  require("sidekick").setup({
    nes = { enabled = false },
    cli = {
      win = {
        layout = "right",
        split = { width = 100, height = 20 },
      },
      mux = { enabled = false },
      tools = {
        jetski = { cmd = { "jetski" } },
      },
    },
  })
end)

-- Search & Replace ===========================================================
later(function()
  add({ "https://github.com/MagicDuck/grug-far.nvim" })
  require("grug-far").setup({
    transient = true,
  })
end)

-- Mason ======================================================================
now_if_args(function()
  add({ "https://github.com/mason-org/mason.nvim" })
  require("mason").setup()
end)

-- Colorscheme ================================================================
Config.now(function()
  add({ "https://github.com/rebelot/kanagawa.nvim" })

  require("kanagawa").setup({
    compile = true,
    colors = {
      theme = { all = { ui = { bg_gutter = "none" } } },
    },
    theme = "wave",
    overrides = function(colors)
      local theme = colors.theme
      return {
        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_m1 },
        PmenuSel = { fg = "NONE", bg = theme.ui.bg_p1 },
        PmenuSbar = { bg = theme.ui.bg_m2 },
        PmenuThumb = { bg = theme.ui.bg_p1 },
        NormalFloat = { bg = theme.ui.bg_m1 },
        FloatBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg_m1 },
        FloatTitle = { fg = theme.ui.shade0, bg = theme.ui.bg_m1 },

        -- Blink.cmp completion & documentation menu theme blending
        BlinkCmpMenu = { fg = theme.ui.fg, bg = theme.ui.bg_m1 },
        BlinkCmpMenuBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg_m1 },
        BlinkCmpMenuSelection = { fg = "NONE", bg = theme.ui.bg_p1 },
        BlinkCmpScrollBarThumb = { bg = theme.ui.bg_p1 },
        BlinkCmpScrollBarGutter = { bg = theme.ui.bg_m2 },
        BlinkCmpDoc = { fg = theme.ui.fg, bg = theme.ui.bg_m1 },
        BlinkCmpDocBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg_m1 },
        BlinkCmpDocSeparator = { fg = theme.ui.float.fg_border, bg = theme.ui.bg_m1 },
        BlinkCmpSignatureHelp = { fg = theme.ui.fg, bg = theme.ui.bg_m1 },
        BlinkCmpSignatureHelpBorder = { fg = theme.ui.float.fg_border, bg = theme.ui.bg_m1 },
      }
    end,
  })
  add({ "https://github.com/scottmckendry/cyberdream.nvim" })

  require("cyberdream").setup({
    cache = true,
    transparent = false,
    italic_comments = true,
    borderless_pickers = false,
    extensions = {
      notify = true,
      neogit = true,
      mini = true,
      blinkcmp = true,
      grugfar = true,
      treesitter = true,
      treesittercontext = true,
    },
  })

  -- vim.cmd("color cyberdream")
  vim.cmd("color kanagawa")
end)
