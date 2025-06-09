local Char = {}

---@class AikidoTabs.Char
---@field char string
---@field hl string
---@field index? number

---@param args AikidoTabs.Char
function Char.new(args)
  local self = setmetatable({
    char = args.char,
    hl = args.hl,
    index = args.index,
  }, { __index = Char })

  return self
end

return Char
