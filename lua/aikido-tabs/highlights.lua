local M = {}
local custom_cache = {}

function M.create()
  local theme = require("colours")
  custom_cache = {} -- reset, to allow for new colours

  local bg = theme.darken(19, 0.5, { to = theme.darken(5, 0.9).hex })
  local grey = theme.darken(7, 0.4)
  local highlights = {
    Buffer = { fg = 7, bg = bg },
    BufferNumber = { fg = grey, bg = bg, italic = true },
    BufferName = { bg = bg, bold = true },
    BufferExt = { fg = theme.darken(7, 0.4), bg = bg, italic = true },
    BufferStatus = { fg = 7, bg = bg },
    BufferOverflow = { fg = 5, bg = bg },
  }

  local function apply_variant(variant, append)
    for highlight, styles in pairs(vim.deepcopy(highlights)) do
      highlights[highlight .. variant] = vim.tbl_extend("force", styles, append)
    end
  end

  apply_variant("Active", { fg = 2, bg = 0 })
  apply_variant("Modified", { italic = true })

  -- Don't override all active states
  highlights.BufferNumberActive.fg = 3
  highlights.BufferNumberActiveModified.fg = highlights.BufferNumberActive.fg
  highlights.BufferExtActive.fg = theme.darken(2, 0.4)
  highlights.BufferExtActiveModified.fg = highlights.BufferExtActive.fg
  highlights.BufferStatusActiveModified.fg = 5

  for highlight, styles in pairs(highlights) do
    theme.hi(highlight, styles)
  end
end

function M.extract_highlights(hl_group)
  return vim.api.nvim_get_hl(0, { name = hl_group })
end

---@return string
function M.create_custom(name, styles)
  local key = vim.inspect(styles)
  if custom_cache[key] then
    return custom_cache[key]
  else
    vim.api.nvim_set_hl(0, name, styles)
    custom_cache[key] = name
    return name
  end
end

---Renders a series of char=>highlights as spans of formatted text
---@return string
function M.render(chars)
  local chunks = {}
  local span = ""

  local last_hl = ""

  local stop_hl = function()
    if last_hl == "" then return end
    if span == "" then return end
    span = span .. "%*"        -- end highlighting
    table.insert(chunks, span) -- append chunk
    span = ""                  -- reset
  end

  local start_hl = function(hl)
    stop_hl()
    span = span .. string.format("%%#%s#", hl)
  end

  local last_index = nil

  local stop_index = function()
    if last_index == nil then return end
    if span == "" then return end
    span = span .. '%X'
  end

  local start_index = function(index)
    stop_index()
    span = span .. '%' .. index .. "@v:lua.require'aikido-tabs'.click_handler@"
  end

  for _, char in ipairs(chars) do
    if char.hl ~= last_hl then start_hl(char.hl) end
    if char.index ~= last_index then start_index(char.index) end
    span = span .. char.char
    last_hl = char.hl
    last_index = char.index
  end
  stop_hl()
  stop_index()

  return table.concat(chunks)
end

return M
