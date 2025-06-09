local Line = require("aikido-tabs.line")
local Element = require("aikido-tabs.element")

describe("Line", function()
  -- it("renders a line", function()
  --   local line = Line.new({
  --     children = {
  --       Element.new({ text = "One", hl = "First" }),
  --       Element.new({ text = "Two", hl = "Second" }),
  --     }
  --   })

  --   assert.are.same("OneTwo", line:to_string())
  -- end)

  describe("centering on child elements", function()
    local line

    before_each(function()
      line = Line.new({
        overflow_symbols = false,
        children = {
          Element.new({ text = "aaaa", hl = "Normal" }),
          Element.new({ text = "bbbb", hl = "Normal" }),
          Element.new({ text = "cccc", hl = "Normal" }), -- focused
          Element.new({ text = "dddd", hl = "Normal" }),
          Element.new({ text = "eeee", hl = "Normal" }),
        },
      })
    end)

    describe("when content fill fit within line", function()
      local full_line = "aaaabbbbccccddddeeee"

      it("it renders the entire content", function()
        line:set_maximum_width(20)
        line.focus_index = 1
        assert.are.same(full_line, line:to_string())
      end)

      it("it renders the entire content", function()
        line:set_maximum_width(20)
        line.focus_index = 5
        assert.are.same(full_line, line:to_string())
      end)
    end)

    describe("when content won't fit within line", function()
      it("can focus the first element", function()
        line:set_maximum_width(6)
        line.focus_index = 1

        assert.are.same(
          {
            viewport_width = 6, -- maximum width
            viewport_center = 3,
            content_width = 20, -- 4 * 5
            content_center = 2, -- aaaa + bbbb + cc
            bias = "left",
            x = 1,              -- start character (ie. first)
            y = 6,              -- end character (ie. width)
          },
          line:dimensions()
        )

        assert.are.same("aaaabb", line:to_string()) --"|aaaab|bbbccccddddeeee
      end)

      it("can focus the second element", function()
        line:set_maximum_width(6)
        line.focus_index = 2

        assert.are.same(
          {
            viewport_width = 6, -- maximum width
            viewport_center = 3,
            content_width = 20, -- 4 * 5
            content_center = 6, -- aaaa + bbbb + cc
            bias = "left",
            x = 4,              -- start character (ie. first)
            y = 9,              -- end character (ie. width)
          },
          line:dimensions()
        )

        assert.are.same("abbbbc", line:to_string()) --"|aaaab|bbbccccddddeeee
      end)

      it("can focus the third (middle) element", function()
        line:set_maximum_width(6)
        line.focus_index = 3

        assert.are.same(
          {
            viewport_width = 6,  -- maximum width
            viewport_center = 3,
            content_width = 20,  -- 4 * 5
            content_center = 10, -- aaaa + bbbb + cc
            bias = "left",
            x = 8,               -- start character (ie. last of b's)
            y = 13,
          },
          line:dimensions()
        )

        assert.are.same("bccccd", line:to_string()) --aaaabbb|bccccd|dddeeee
      end)

      it("can focus the second last element", function()
        line:set_maximum_width(6)
        line.focus_index = 4

        assert.are.same(
          {
            viewport_width = 6, -- maximum width
            viewport_center = 3,
            content_width = 20, -- 4 * 5
            content_center = 14,
            bias = "right",
            x = 12, -- start character (ie. last of c's)
            y = 17,
          },
          line:dimensions()
        )

        assert.are.same("cdddde", line:to_string()) --aaaabbb|bccccd|dddeeee
      end)

      it("can focus the last element", function()
        line:set_maximum_width(6)
        line.focus_index = 5

        assert.are.same(
          {
            viewport_width = 6,  -- maximum width
            viewport_center = 3,
            content_width = 20,  -- 4 * 5
            content_center = 18, -- aaaa + bbbb + cc
            bias = "right",
            x = 15,              -- start character (ie. last of b's)
            y = 20,
          },
          line:dimensions()
        )

        assert.are.same("ddeeee", line:to_string()) --aaaabbb|bccccd|dddeeee
      end)

      it("can focus the last element", function()
        line = Line.new({
          children = {
            Element.new({ text = "bbbb", hl = "Normal" }),
            Element.new({ text = "cccc", hl = "Normal" }), -- focused
            Element.new({ text = "dddd", hl = "Normal" }),
            Element.new({ text = "eeeee", hl = "Normal" }),
          },
        })

        line:set_maximum_width(5)
        line.focus_index = 4

        assert.are.same(
          {
            viewport_width = 5, -- maximum width
            viewport_center = 2.5,
            content_width = 17,
            content_center = 14.5, -- aaaa + bbbb + cc
            bias = "right",
            x = 13,                -- start character (ie. last of b's)
            y = 17,
          },
          line:dimensions()
        )

        assert.are.same("eeeee", line:to_string()) --aaaabbb|bccccd|dddeeee
      end)
    end)
  end)
end)
