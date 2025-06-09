local util = require("aikido-tabs.util")

local Parent = {}

---@class AikidoTabs.Element.Parent --: AikidoTabs.Element:
---@field children table -- AikidoTabs.Element[]

---Return the contents of the current buffer that the chat was initiated from
---@return AikidoTabs.Char[]
function Parent:chars()
  -- Cascade attributes
  local children = vim.tbl_map(function(element)
    element.index = self.index or element.index
    return element
  end, self.children)

  -- Render each element
  local renderds = vim.tbl_map(function(element)
    return element:chars()
  end, children)

  -- Flatten rendered elements
  local flattened = {}
  for _, rendered in ipairs(renderds) do
    vim.list_extend(flattened, rendered)
  end

  return flattened
end

---@return number
function Parent:width()
  return util.sum(self.children, function(child)
    return child:width()
  end)
end

---Given elements can disappear with a threshold, loop until we're below the maximum width
---(or otherwise unable to reduce further)
---@param wanted number
function Parent:set_maximum_width(wanted)
  local request
  while self:width() > wanted and request ~= false do
    request = self:reduce_by(1) -- Any single reduction could *remove* an element
  end
  return request
end

---@return table
function Parent:_reduceable_children()
  return vim.tbl_filter(function(child)
    return child:is_reduceable_by(1)
  end, self.children)
end

---@return table
function Parent:_widest_reduceable_child()
  local candidates = self:_reduceable_children()
  local widest = candidates[1]
  for _, child in ipairs(candidates) do
    if child:width() > widest:width() then
      widest = child
    end
  end
  return widest
end

---@return boolean
function Parent:is_reduceable_by(amount)
  return util.any(self.children, function(child)
    return child:is_reduceable_by(amount)
  end)
end

---@param amount number
---@return boolean
function Parent:reduce_by(amount)
  local request, widest
  for _ = 1, amount do
    widest = self:_widest_reduceable_child()
    request = widest and widest:reduce_by(1)
    if not request then
      return false
    end
  end
  return true
end

return Parent
