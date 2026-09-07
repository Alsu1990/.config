-- Ruff Python Linter & Formatter LSP Configuration for Neovim 0.12+ (vim.lsp.config)
local config_path = vim.fn.expand("~/.config/ruff/ruff.toml")

return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    "WORKSPACE",
    ".git",
  },
  init_options = {
    settings = {
      args = vim.fn.filereadable(config_path) == 1 and { "--config", config_path } or {},
      configuration = vim.fn.filereadable(config_path) == 1 and config_path or nil,
    },
  },
}
