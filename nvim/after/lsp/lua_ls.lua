-- Lua Language Server LSP Configuration for Neovim 0.12+ (vim.lsp.config)
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        pathStrict = true,
        path = vim.split(package.path, ";"),
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
          vim.fn.stdpath("data") .. "/site/pack/core/opt/mini.nvim/lua",
        },
        pullMode = "background",
      },
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        globals = { "vim" },
      },
      format = {
        enable = false, -- Deferred exclusively to stylua via conform.nvim
      },
      hint = {
        enable = true,
        arrayIndex = "Disable",
        paramName = "All",
        paramType = true,
        setType = true,
      },
    },
  },
}
