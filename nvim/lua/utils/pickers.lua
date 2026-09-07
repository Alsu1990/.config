local M = {}

local pick_todo = function()
  -- 1. Attempt to fetch keywords from your actual mini.hipatterns configuration
  local hipatterns_status, hipatterns = pcall(require, "mini.hipatterns")
  local keywords = { "TODO", "FIXME" } -- Fallback defaults

  if hipatterns_status and hipatterns.config and hipatterns.config.highlighters then
    keywords = {}
    for name, hl in pairs(hipatterns.config.highlighters) do
      -- Filter to grab configured word patterns (ignoring hex colors, etc.)
      if type(hl.pattern) == "string" and hl.pattern:match("%%f%%[%w]") then
        table.insert(keywords, name)
      elseif type(hl.pattern) == "table" then
        table.insert(keywords, name)
      end
    end
  end

  -- If no keywords were extractable, default back safely
  if #keywords == 0 then
    keywords = { "TODO", "FIXME", "HACK", "NOTE" }
  end

  -- 2. Build a regex pattern for ripgrep: \b(TODO|FIXME|HACK)\b
  local rg_pattern = "\\b(" .. table.concat(keywords, "|") .. ")\\b"

  -- 3. Launch mini.pick using the pattern match builtin
  MiniPick.builtin.grep({
    tool = "rg",
    pattern = rg_pattern,
  }, {
    source = {
      name = "Workspace Todo / Fixme",
      -- Custom match highlighting inside the picker window
      show = function(buf_id, items, query)
        MiniPick.default_show(buf_id, items, query)

        -- Apply the mini.hipatterns styling onto the picker buffer matches
        for _, kw in ipairs(keywords) do
          local hl_group = "MiniHipatterns" .. kw
          -- If the specific highlight group exists, map it in the picker buffer
          if vim.fn.hlexists(hl_group) == 1 then
            vim.cmd(string.format("syntax match %s /\\V\\<%s\\>/ containedin=ALL", hl_group, kw))
          end
        end
      end,
    },
  })
end

M.pick_todo = pick_todo
return M

