-- Starpls (Starlark & Bazel) LSP Configuration for Neovim 0.12+ (vim.lsp.config)
local bazel = require("utils.bazel")

return {
  cmd = { "starpls" },
  filetypes = { "bzl", "starlark" },
  root_dir = bazel.make_root_resolver({
    "WORKSPACE",
    "WORKSPACE.bazel",
    "MODULE.bazel",
    ".git",
  }),
  root_markers = {
    "WORKSPACE",
    "WORKSPACE.bazel",
    "MODULE.bazel",
    ".git",
  },
  settings = {
    starpls = {
      bazel = {
        enabled = true,
      },
    },
  },
}
