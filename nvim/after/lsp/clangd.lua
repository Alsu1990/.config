-- Clangd LSP Configuration for Neovim 0.12+ (vim.lsp.config)
local bazel = require("utils.bazel")
local function switch_source_header(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local params = { uri = vim.uri_from_bufnr(bufnr) }

  vim.lsp.buf_request(bufnr, "textDocument/switchSourceHeader", params, function(err, result)
    if err then
      vim.notify("Error switching source/header: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if not result or result == "" then
      vim.notify("Corresponding source/header file not found", vim.log.levels.WARN)
      return
    end

    vim.cmd.edit(vim.uri_to_fname(result))
  end)
end

return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=Google",
    "--inlay-hints=true",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_dir = bazel.make_root_resolver({
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    "WORKSPACE",
    ".git",
  }),
  root_markers = {
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    "WORKSPACE",
    ".git",
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
  init_options = {
    clangdFileStatus = true,
    usePlaceholders = true,
    completeUnimported = true,
  },
  on_attach = function(client, bufnr)
    vim.lsp.inlay_hint.enable()
    -- Map <leader>lh directly to the native LSP request function
    vim.keymap.set("n", "<leader>ch", function()
      switch_source_header(bufnr)
    end, {
      buffer = bufnr,
      desc = "Switch Source/Header (clangd)",
    })
  end,
}
