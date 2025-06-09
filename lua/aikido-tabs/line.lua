local Element    = require("aikido-tabs.element")
local Parent     = require("aikido-tabs.element.parent")
local highlights = require("aikido-tabs.highlights")

---Out tabline is simply an element, containing each tab as an element also
---This allows us to set a maximum width, and have the *children* organise as required
local Line       = {}

---@class AikidoTabs.Line --: AikidoTabs.Element.Parent
---@field children table -- AikidoTabs.Element[]
---@field overflow_symbols boolean
---@field focus_index? number

---@param args AikidoTabs.Line
function Line.new(args)
  local self = setmetatable({
    children = args.children,
    focus_index = args.focus_index,
    overflow_symbols = args.overflow_symbols,
    maximum_width = nil
  }, {
    __index = vim.tbl_extend("force", Element, Parent, Line) -- Extendig element parent
  })

  return self
end

function Line:focused_child()
  if not self.focus_index then return nil end
  return self.children[self.focus_index]
end

function Line:set_maximum_width(amount)
  self.maximum_width = amount
  Parent.set_maximum_width(self, amount)
end

---The left offset then center of the focused element
---@return number | nil
function Line:focus_center_point()
  if not self.focus_index then return nil end

  local point = 0
  for i = 1, self.focus_index - 1 do
    point = point + self.children[i]:width()
  end
  return point + self:focused_child():width() / 2
end

function Line:dimensions()
  local viewport_width = self.maximum_width or self:width()
  local viewport_center = viewport_width / 2
  local content_width = self:width()
  local content_center = self:focus_center_point() or content_width / 2

  local measured = {
    viewport_width = viewport_width,
    viewport_center = viewport_center,
    content_width = content_width,
    content_center = content_center,
    bias = content_center <= content_width / 2 and "left" or "right",
    x = 1, -- first char to use
  }

  -- Move the viewport forward if behind content
  if content_center > viewport_center then
    measured.x = math.floor(content_center - viewport_center) + 1 -- skip this many chars (not zero based)
    measured.x = math.min(measured.x, content_width - viewport_width + 1)
  end

  -- Place our end point  for convenience
  measured.y = measured.x + viewport_width - 1 -- "up to" so minus one

  return measured
end

function Line:visible_chars()
  local chars = self:chars()
  local dimensions = self:dimensions()

  -- Sample the chars from within our dimensions
  local visible_chars = {}
  for i = dimensions.x, dimensions.y do
    table.insert(visible_chars, chars[i])
  end

  if self.overflow_symbols then
    if dimensions.x > 1 then
      visible_chars[1].char = ""
      visible_chars[1].hl = "BufferOverflow"
      visible_chars[2].char = "…"
      visible_chars[2].hl = "BufferOverflow"
    end

    if dimensions.y < dimensions.content_width then
      visible_chars[#visible_chars - 1].char = "…"
      visible_chars[#visible_chars].hl = "BufferOverflow"
      visible_chars[#visible_chars].char = ""
      visible_chars[#visible_chars].hl = "BufferOverflow"
    end
  end

  return visible_chars
end

function Line:to_string()
  return table.concat(vim.tbl_map(function(char) return char.char end, self:visible_chars()))
end

function Line:render()
  return highlights.render(self:visible_chars())
end

return Line
