-- Astral's ty Python type checker & language server

return {
  cmd = { "ty", "server" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "ty.toml",
    "WORKSPACE",
    ".git",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "pyrightconfig.json",
  },
  settings = {},
}
