local Char = require("aikido-tabs.element.char")
local Parent = require("aikido-tabs.element.parent")

---An "Element" is our primary construct
---It is simply some text with a highlight group, plus context allowing it to shrink (inspired by flexbox)
---Via a parent/children relationship it can contain it's own elements, allowing for nested functionality
local Element = {}

---@class AikidoTabs.Element
---@field text string
---@field hl_name string
---@field ellipsis string
---@field flex? AikidoTabs.Flex

---@class AikidoTabs.Element.Parent

---@class AikidoTabs.Element.Text
---@field text string
---@field index? number
---@field hl? string
---@field flex? AikidoTabs.Flex

---@param args AikidoTabs.Element.Text | AikidoTabs.Element.Parent
function Element.new(args)
  local klass = Element
  if args.children then
    klass = vim.tbl_extend("force", Element, Parent)
  end

  local self = setmetatable({
    children = args.children,
    _text = args.text,
    hl = args.hl or "Normal",
    index = args.index,
    flex = args.flex or {},
    truncation = 0,
    ellipsis = "…",
  }, { __index = klass })

  return self
end

-- Apply the truncation value to our text
---@return string
function Element:text()
  if self.truncation == 0 then return self._text end
  if vim.fn.strdisplaywidth(self._text) - self.truncation <= (self.flex.minimum or 0) then
    return ""
  end

  if self.flex.align == "left" then
    return self._text:sub(1, -(self.truncation + 2)) .. self.ellipsis
  else
    return self.ellipsis .. self._text:sub(self.truncation + 2)
  end
end

---Return the contents of the current buffer that the chat was initiated from
---@return AikidoTabs.Char[]
function Element:chars()
  if self:text() == "" then return {} end

  local chars = {}
  -- Match any single character (`.`) plus any following UTF-8 continuation bytes (`[\128-\191]*`)
  -- This ensures we don't break apart multi char unicode icons or such
  for char in self:text():gmatch(".[\128-\191]*") do
    table.insert(chars, Char.new({
      char = char,
      hl = self.hl,
      index = self.index,
    }))
  end
  return chars
end

function Element:to_string()
  return table.concat(
    vim.tbl_map(function(char) return char.char end, self:chars())
  )
end

function Element:width()
  local truncated = vim.fn.strdisplaywidth(self._text) - self.truncation
  if truncated == self.flex.minimum then return 0 end
  return truncated
end

---@return boolean
function Element:is_reduceable_by(amount)
  if self:text() == nil then return false end     -- only avaialble for text nodes
  if next(self.flex) == nil then return false end -- not flexing
  if amount > self:width() then return false end  -- too much
  return true
end

---@param amount number
---@return boolean
function Element:reduce_by(amount)
  if not self:is_reduceable_by(amount) then return false end

  self.truncation = self.truncation + amount
  return true
end

return Element
