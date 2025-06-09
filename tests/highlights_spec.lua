local Element = require("aikido-tabs.element")
local highlights = require("aikido-tabs.highlights")

local Shared = {}

function Shared:foo()
  print(self.name)
end

local Parent = {}

function Parent.new(args)
  local self = setmetatable({
    name = args.name
  }, { __index = vim.tbl_extend("force", Shared, Parent) })

  return self
end

describe("highlights", function()
  describe("render", function()
    it("renders chars to a formatted string", function()
      local element = Element.new({
        children = {
          Element.new({ text = "Foo", hl = "First" }),
          Element.new({ text = "bar", hl = "Second" }),
        }
      })
      local chars = element:chars()
      local rendered = highlights.render(chars)

      assert.are.same(
        table.concat({
          "%#First#Foo%*",
          "%#Second#bar%*",
        }),
        rendered
      )
    end)

    it("renders index click actions", function()
      local element = Element.new({
        index = 3,
        children = {
          Element.new({ text = "Foo", hl = "First" }),
          Element.new({ text = "bar", hl = "Second" }),
        }
      })
      local chars = element:chars()
      print(vim.inspect(chars))
      local rendered = highlights.render(chars)

      assert.are.same(
        table.concat({
          "%#First#" ..
          "%3",                                         -- index
          "@v:lua.require'aikido-tabs'.click_handler@", -- click handler
          "Foo%*",
          "%#Second#bar%*",
        }),
        rendered
      )
    end)
  end)
end)
