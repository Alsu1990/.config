-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Fuzzy Search
now_if_args(function()
  add({
    'https://github.com/ibhagwan/fzf-lua',
  })
  require('fzf-lua').setup({
    winopts = {
      height = 0.85,
      width = 0.80,
    },
    keymap = {
      builtin = {
        ['<C-d>'] = 'preview-page-down',
        ['<C-u>'] = 'preview-page-up',
      },
    },
    files = {
      formatter = 'path.filename_first',
    },
  })
end)

-- File explorer
now_if_args(function()
  add({
    'https://github.com/stevearc/oil.nvim',
  })
  require('oil').setup({
    -- Use the default set of columns
    columns = {
      'icon',
      -- "permissions",
      -- "size",
      -- "mtime",
    },
    -- Buffer-local options
    buf_options = {
      buflisted = false,
      bufhidden = 'hide',
    },
    -- Window options
    win_options = {
      wrap = false,
      signcolumn = 'no',
      cursorcolumn = false,
      foldcolumn = '0',
      spell = false,
      list = false,
      concealcursor = 'nvic',
      conceallevel = 3,
    },
    -- Use mini.icons for a cohesive look
    default_file_explorer = true,
    restore_win_options = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
      is_hidden_file = function(name, bufnr)
        return vim.startswith(name, '.')
      end,
    },
  })
end)

-- Term
now_if_args(function()
  add({
    'https://github.com/akinsho/toggleterm.nvim',
  })

  require('toggleterm').setup({
    -- Sets the default mapping to toggle the terminal
    open_mapping = [[<c-_>]],
    direction = 'float', -- Options: 'vertical', 'horizontal', 'tab', 'float'
    shade_terminals = true,
    float_opts = {
      border = 'curved', -- 'single', 'double', 'shadow', 'curved'
    },
  })

  -- LazyGit Terminal Instance
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = 'lazygit',
    hidden = true,
    direction = 'float',
  })

  function _G.Config.toggle_lazygit()
    lazygit:toggle()
  end
end)
-- Git ====================================================================
now_if_args(function()
  add({
    'https://github.com/lewis6991/gitsigns.nvim',
  })
  require('gitsigns').setup({
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
    -- Standard in 2026: inline blame that doesn't feel intrusive
    current_line_blame = true,
    sign_priority = 6,
    update_debounce = 100,
    word_diff = false, -- Turn this on if you want character-level diffs
  })
end)

-- Tree-sitter ================================================================
now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  Config.on_packchanged(
    'nvim-treesitter',
    { 'update' },
    vim.cmd('TSUpdate'),
    ':TSUpdate'
  )

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  -- Define languages which will have parsers installed and auto enabled
  -- After changing this, restart Neovim once to install necessary parsers. Wait
  -- for the installation to finish before opening a file for added language(s).
  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',
    'c',
    'cpp',
    'make',
    'starlark',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then
    require('nvim-treesitter').install(to_install)
  end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev)
    vim.treesitter.start(ev.buf)
  end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================
-- ':h vim.lsp'
now_if_args(function()
  add({ 'https://github.com/neovim/nvim-lspconfig' })

  -- Use `:h vim.lsp.enable()` to automatically enable language server based on
  -- the rules provided by 'nvim-lspconfig'.
  -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
  -- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
  vim.lsp.enable({
    'lua_ls',
    'clangd',
    'starpls',
  })
end)

-- Automatic install/update with mason
now_if_args(function()
  add({
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/mason-org/mason-lspconfig.nvim',
    'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  })
end)

later(function()
  require('mason').setup()
  require('mason-lspconfig').setup()
  require('mason-tool-installer').setup({
    ensure_installed = {
      'tree-sitter-cli',
      'lua_ls',
      'stylua',
      'clangd',
      'ruff',
      'starpls',
    },
    auto_update = false,
    run_on_start = true,
    start_delay = 500,
  })
end)

-- Formatting =================================================================
later(function()
  add({ 'https://github.com/stevearc/conform.nvim' })
  -- - `:h Conform`
  require('conform').setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = 'fallback',
    },
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    formatters_by_ft = { lua = { 'stylua' } },
    formatters = {
      stylua = {},
    },
  })
end)

-- Snippets&Completion=========================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function()
  add({ 'https://github.com/rafamadriz/friendly-snippets' })
  add({ 'https://github.com/saghen/blink.cmp' })

  require('blink.cmp').setup({
    keymap = {
      preset = 'default',
      ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
      ['<C-space>'] = { 'show', 'fallback' },

      ['<CR>'] = { 'accept', 'fallback' },
      ['<Esc>'] = { 'hide', 'fallback' },
    },
    appearance = {
      -- use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },
    completion = {
      ghost_text = { enabled = true },
      menu = {
        border = 'none',
        winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDoc,CursorLine:BlinkCmpDocCursorLine,Search:None',
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = 'none',
          winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDoc,CursorLine:BlinkCmpDocCursorLine,Search:None',
        },
      },
    },
    snippets = {
      preset = 'default',
      expand = function(snippet)
        vim.snippet.expand(snippet)
      end,
      active = function(filter)
        return vim.snippet.active(filter)
      end,
      jump = function(direction)
        vim.snippet.jump(direction)
      end,
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    signature = { enabled = true },
  })
end)

-- kanagawa theme
Config.now(function()
  add({
    'https://github.com/rebelot/kanagawa.nvim',
  })
  require('kanagawa').setup({
    compile = true, -- Enables compilation for faster startup
    undercurl = true, -- Enable undercurls (useful for LSP diagnostics)
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true },
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false, -- Set to true if you want terminal background transparency
    dimInactive = false, -- Dim inactive windows
    terminalColors = true, -- Define colors for the built-in terminal
    colors = {
      palette = {},
      theme = {
        all = {
          ui = {
            bg_gutter = 'none', -- Makes the line number gutter look cleaner
          },
        },
      },
    },
    background = {
      dark = 'wave',
      light = 'lotus',
    },
    theme = 'wave', -- Options: "wave", "dragon", "lotus"
  })
  vim.cmd('color kanagawa')
end)
