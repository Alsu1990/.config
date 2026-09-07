-- Bash Language Server LSP Configuration for Neovim 0.12+ (vim.lsp.config)
return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  root_markers = {
    ".git",
    "WORKSPACE",
  },
  settings = {
    bashIde = {
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
}
