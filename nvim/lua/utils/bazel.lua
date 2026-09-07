local M = {}

--- Resolve the true, originating Bazel workspace root when viewing or 
--- editing files mapped within the read-only `.cache/bazel/.../execroot` cache.
--- @param fname string The fully qualified absolute file path.
--- @return string|nil workspace_root Absolute directory path of the resolved Bazel workspace, or nil if unmatched.
function M.get_bazel_workspace_root(fname)
  if not fname or fname == "" then
    return nil
  end

  local bazel_cache_pattern = "/%.cache/bazel/_bazel_[^/]+/([a-f0-9]+)/"
  local match = string.match(fname, bazel_cache_pattern)
  if match then
    local output_base = string.match(fname, "(.+/%.cache/bazel/_bazel_[^/]+/[a-f0-9]+)")
    if output_base then
      local execroot = output_base .. "/execroot"
      local dirs = vim.fn.glob(execroot .. "/*", false, true)
      for _, dir in ipairs(dirs) do
        if not string.match(dir, "DO_NOT_BUILD_HERE$") then
          local workspace_link = dir .. "/WORKSPACE"
          if vim.fn.getftype(workspace_link) == "link" then
            local resolved = vim.fn.resolve(workspace_link)
            if resolved and resolved ~= workspace_link then
              return vim.fs.dirname(resolved)
            end
          end
        end
      end
    end
  end
  return nil
end

--- Generates a unified `root_dir` function for Neovim 0.12+ LSP manifests (`lsp.config`).
--- Resolves Bazel `.cache/` execroot paths natively, evaluates `fallback_markers`,
--- and defaults to the file's parent directory for standalone files.
--- @param fallback_markers string[] Array of filesystem anchors to evaluate in top-down hierarchy (e.s., `.git`, `WORKSPACE`).
--- @return fun(bufnr_or_fname: integer|string, on_dir?: fun(root_dir?: string)): string|nil Resolved workspace directory.
function M.make_root_resolver(fallback_markers)
  return function(arg1, arg2)
    local bufnr = type(arg1) == "number" and arg1 or vim.api.nvim_get_current_buf()
    local fname = type(arg1) == "string" and arg1 or vim.api.nvim_buf_get_name(bufnr)
    local on_dir = type(arg2) == "function" and arg2 or nil

    local root = nil
    local ok, bazel_root = pcall(M.get_bazel_workspace_root, fname)
    if ok and bazel_root then
      root = bazel_root
    else
      root = vim.fs.root(bufnr, fallback_markers)
    end

    -- Graceful fallback for standalone files located outside standard source control / repositories
    if not root and fname and fname ~= "" then
      root = vim.fs.dirname(fname)
    end

    if on_dir then
      on_dir(root)
    end
    return root
  end
end

return M
