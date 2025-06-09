local Element = require("aikido-tabs.element")
local util = require("aikido-tabs.util")

describe("element", function()
  describe("chars", function()
    it("renders text", function()
      local element = Element.new({ text = "Test", hl = "Normal" })
      local rendered = element:chars()
      local chars = vim.tbl_map(function(char) return char.char end, rendered)

      assert(table.concat(chars) == "Test")
    end)

    it("renders children", function()
      local element = Element.new({
        children = {
          Element.new({ text = "Foo", hl = "First" }),
          Element.new({ text = "bar", hl = "Second" }),
        }
      })

      local chars = vim.tbl_map(function(char) return char.char end, element:chars())
      local highlights = vim.tbl_map(function(char) return char.hl end, element:chars())

      assert(table.concat(chars) == "Foobar", "Characters match")
      assert.are.same(highlights, { "First", "First", "First", "Second", "Second", "Second" }, "Highlights match")
    end)

    it("renders children deeper", function()
      local element = Element.new({
        children = {
          Element.new({
            children = {
              Element.new({
                children = {
                  Element.new({ text = "Nested", hl = "Highlight" }),
                }
              })
            }
          })
        }
      })

      local chars = vim.tbl_map(function(char) return char.char end, element:chars())
      assert(table.concat(chars) == "Nested")
    end)
  end)

  describe("index attribute", function()
    it("cascades down through children", function()
      local element = Element.new({
        index = 3,
        children = {
          Element.new({ text = "Foo", hl = "First" }),
          Element.new({ text = "bar", hl = "Second" }),
        }
      })

      local indexes = vim.tbl_map(function(char) return char.index end, element:chars())

      assert.is_true(util.all(indexes, function(index)
        return index == 3
      end))
    end)
  end)

  describe("shrinking", function()
    local element

    before_each(function()
      element = Element.new({ text = "Test" })
      assert.are.same(element:to_string(), "Test")
      assert.are.same(element:width(), 4)
    end)

    it("rejects shrinking if not flexed", function()
      assert.is.falsy(element:reduce_by(1))
    end)

    describe("with flex", function()
      it("shrinks from the right", function()
        element = Element.new({ text = "Test", flex = { align = "left" } })
        assert.is.truthy(element:reduce_by(1))
        assert.are.same("Te…", element:to_string())
        assert.are.same(3, element:width())
      end)

      it("shrinks from the left", function()
        element = Element.new({ text = "Test", flex = { align = "right" } })
        assert.is.truthy(element:reduce_by(1))
        assert.are.same(element:to_string(), "…st")
        assert.are.same(element:width(), 3)
      end)

      describe("edge cases", function()
        before_each(function()
          element = Element.new({ text = "Test", flex = { align = "right" } })
        end)

        it("shrinks by any number", function()
          assert.is.truthy(element:reduce_by(2))
          assert.are.same(element:to_string(), "…t")
          assert.are.same(element:width(), 2)
        end)

        it("shrinks by maximum", function()
          assert.is.truthy(element:reduce_by(4))
          assert.are.same(element:to_string(), "")
          assert.are.same(element:width(), 0)
        end)

        it("shrinks multiple times", function()
          assert.is.truthy(element:reduce_by(1))
          assert.are.same("…st", element:to_string())
          assert.are.same(3, element:width())

          assert.is.truthy(element:reduce_by(1))
          assert.are.same("…t", element:to_string())
          assert.are.same(2, element:width())

          assert.is.truthy(element:reduce_by(1))
          assert.are.same("…", element:to_string())
          assert.are.same(1, element:width())
        end)

        it("shrinks to a provided minimum", function()
          element = Element.new({ text = "Test", flex = { align = "left", minimum = 2 } })

          -- At minimum
          assert.is.truthy(element:reduce_by(1))
          assert.are.same(element:to_string(), "Te…")
          assert.are.same(element:width(), 3)

          -- Past minimum
          assert.is.truthy(element:reduce_by(1))
          assert.are.same(element:to_string(), "")
          assert.are.same(element:width(), 0)
        end)

        it("does not shrink past maximum", function()
          assert.is.falsy(element:reduce_by(5))
        end)
      end)
    end)

    describe("shrinking with children", function()
      it("does not shink when children don't", function()
        element = Element.new({
          children = {
            Element.new({ text = "One" }),
            Element.new({ text = "Two" }),
          }
        })

        assert.is.falsy(element:reduce_by(1))
      end)

      it("will shrink when one child does", function()
        element = Element.new({
          children = {
            Element.new({ text = "One", flex = { align = "left" } }),
            Element.new({ text = "Two" }),
          }
        })

        assert.is.truthy(element:reduce_by(1))
        assert.is.same("O…Two", element:to_string())
      end)

      it("will shrink the longest child", function()
        element = Element.new({
          children = {
            Element.new({ text = "One", flex = { align = "left" } }),
            Element.new({ text = "Longer", flex = { align = "left" } }),
          }
        })

        assert.is.same(9, element:width())
        assert.is.truthy(element:reduce_by(1))
        assert.is.same("OneLong…", element:to_string())
        assert.is.same(8, element:width())
      end)

      it("will shrink across children", function()
        element = Element.new({
          children = {
            Element.new({ text = "One", flex = { align = "left" } }),
            Element.new({ text = "Longer", flex = { align = "left" } }),
          }
        })

        assert.is.same(9, element:width())
        assert.is.truthy(element:reduce_by(2))
        assert.is.same("OneLon…", element:to_string())
        assert.is.same(7, element:width())
      end)

      it("will shrink across then amongst children", function()
        element = Element.new({
          children = {
            Element.new({ text = "One", flex = { align = "left" } }),
            Element.new({ text = "Longer", flex = { align = "left" } }),
          }
        })

        assert.is.same(9, element:width())
        assert.is.truthy(element:reduce_by(3))
        assert.is.same("OneLo…", element:to_string()) -- The truncated text is favoured
        assert.is.same(6, element:width())

        assert.is.truthy(element:reduce_by(1))
        assert.is.same("O…Lo…", element:to_string()) -- But only till a point
        assert.is.same(5, element:width())
      end)

      it("shrinks a single child to a provided minimum", function()
        element = Element.new({
          children = {
            Element.new({ text = "Test", flex = { align = "left", minimum = 2 } })
          }
        })

        -- At minimum
        assert.is.truthy(element:set_maximum_width(3))
        assert.are.same("Te…", element:to_string())
        assert.are.same(3, element:width())

        -- Past minimum
        assert.is.truthy(element:set_maximum_width(2))
        assert.are.same(element:to_string(), "")
        assert.are.same(element:width(), 0)
      end)

      it("doesn't shrink beyond requested width if child disappears", function()
        element = Element.new({
          children = {
            Element.new({ text = "123456", flex = { align = "left", minimum = 5 } }),
            Element.new({ text = "Test", flex = { align = "left" } }),
          }
        })

        assert.is.truthy(element:set_maximum_width(6))
        assert.are.same("Test", element:to_string()) -- Numbers has disappeared
        assert.are.same(4, element:width())          -- and we're down below the request
      end)
    end)
  end)
end)
