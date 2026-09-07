-- Verible Language Server LSP Configuration for Neovim 0.12+ (vim.lsp.config)
-- Designed as a companion LSP alongside Slang. Verible delegates primary hover,
-- go-to-definition, and signature resolving to Slang while driving formatting
-- and project-level linting via `verible-verilog-ls`.
local bazel = require("utils.bazel")

return {
  cmd = {
    "verible-verilog-ls",
    "--init_substitution=true",
    "--rules_config_search",
    "--flagfile=" .. vim.fn.expand("~/.config/verible/verible.flags"),
  },
  filetypes = { "verilog", "systemverilog" },
  root_dir = bazel.make_root_resolver({
    "WORKSPACE",
    "WORKSPACE.bazel",
    ".git",
  }),
  root_markers = {
    "WORKSPACE",
    "WORKSPACE.bazel",
    ".git",
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.diagnosticProvider = false
    -- Disable hover (K) and code definitions (gd) so Slang takes priority
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.definitionProvider = false
    client.server_capabilities.workspaceSymbolProvider = false
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.referencesProvider = false
    -- Ensure Verible keeps its formatting capability active
    client.server_capabilities.documentFormattingProvider = true
  end,
}
