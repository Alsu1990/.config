-- Ignore floating LSP hover windows and nofile buffers
local is_floating = vim.api.nvim_win_get_config(0).relative ~= ""
local is_nofile = vim.bo.buftype == "nofile"

if is_floating or is_nofile then
  vim.opt_local.spell = false
  vim.opt_local.wrap = true
  return
end

-- Enable spelling and wrap for window
vim.cmd('setlocal spell wrap')

-- Fold with tree-sitter
vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')

-- Disable built-in `gO` mapping in favor of 'mini.basics'
vim.keymap.del('n', 'gO', { buffer = 0 })

-- Markdown link surrounding in mini.surround
vim.b.minisurround_config = {
  custom_surroundings = {
    L = {
      input = { '%[().-()%]%(.-%)' },
      output = function()
        local link = require('mini.surround').user_input('Link: ')
        return { left = '[', right = '](' .. link .. ')' }
      end,
    },
  },
}
