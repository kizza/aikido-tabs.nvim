local Element                = require("aikido-tabs.element")
local util                   = require("aikido-tabs.util")
local config                 = require("aikido-tabs.config")
local has_devicons, devicons = pcall(require, "nvim-web-devicons")
local highlights             = require("aikido-tabs.highlights")


local Tab = {}

---@class AikidoTabs.Tab
---@field buf table
---@field index number

----@param buf AikidoTabs.Tab
----@param index number
function Tab.new(buf, index)
  local self = setmetatable(buf, { __index = Tab })
  self.index = index

  return self
end

----@return AikidoTabs.Element.Parent
function Tab:element()
  local function hl(context)
    context = context or ""
    if self.active then context = context .. "Active" end
    if self.modified then context = context .. "Modified" end
    return "Buffer" .. context
  end

  local function space()
    return Element.new({ text = " ", hl = hl("Number") })
  end

  local modified = function()
    if self.modified then
      return Element.new({ text = " ", hl = hl("Status") })
    end
  end

  local icon = function()
    if not (config.icons and has_devicons) then return end
    local icon, color = devicons.get_icon_color(self.path, self.ext, { default = false })
    if not icon then
      icon, color = devicons.get_icon_color_by_filetype(self.filetype, { default = true })
    end

    if icon and color then
      local styles = { fg = color }
      local bg = highlights.extract_highlights(hl()).bg
      if bg then styles['bg'] = string.format("#%06x", bg) end

      local icon_hl = highlights.create_custom(hl("Icon" .. self.ext), styles)
      return Element.new({
        children = {
          Element.new({ text = icon, hl = icon_hl }),
          space(),
        }
      })
    end
  end

  return Element.new({
    index = self.index,
    children = util.compact({
      space(),
      Element.new({
        text = tostring(self.index),
        hl = hl("Number"),
      }),
      space(),
      icon(),
      Element.new({
        text = self.dir .. "/",
        hl = hl("Ext"),
        flex = { align = "right", minimum = 2 },
      }),
      Element.new({
        text = self.name,
        hl = hl("Name"),
      }),
      Element.new({
        text = "." .. self.ext,
        hl = hl("Ext"),
      }),
      modified(),
      space(),
    })
  })
end

return Tab
