-- Slang Server LSP Configuration for Neovim 0.12+ (vim.lsp.config)
-- Designed for dual-LSP operations alongside verible-verilog-ls, providing
-- advanced diagnostics, go-to-definition, and auto-completion.
local bazel = require("utils.bazel")

return {
  cmd = { "slang-server" },
  filetypes = { "verilog", "systemverilog" },
  root_dir = bazel.make_root_resolver({
    ".slang",
    "WORKSPACE",
    "WORKSPACE.bazel",
    ".git",
  }),
  root_markers = {
    ".slang",
    "WORKSPACE",
    "WORKSPACE.bazel",
    ".git",
  },
  settings = {},
}
