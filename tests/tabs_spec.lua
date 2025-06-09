local Tab = require("aikido-tabs.tab")
local Element = require("aikido-tabs.element")

local buf = {
  nr = 1,
  dir = "foo/bar/baz",
  name = "file",
  ext = "ext",
  current = false,
  safe = true,
  modified = false,
  modifiable = true,
  readonly = false,
  active = false,
}

describe("tabs", function()
  it("renders as a tabline", function()
    local tabs = {
      Tab.new(vim.tbl_extend("force", buf, { name = "first", dir = "aaa/bbb" }), 1),
      Tab.new(vim.tbl_extend("force", buf, { name = "second", dir = "ccc/ddd/eee/fff" }), 2),
      Tab.new(vim.tbl_extend("force", buf, { name = "third", dir = "ggg" }), 3),
    }

    local tabline = Element.new({
      children = vim.tbl_map(function(tab)
        return tab:element()
      end, tabs)
    })

    assert.are.same(" 1 aaa/bbb/first.ext  2 ccc/ddd/eee/fff/second.ext  3 ggg/third.ext ", tabline:to_string())
    assert.are.same(68, tabline:width())
  end)

  describe("setting maximum width", function()
    local tabline

    before_each(function()
      local tabs = {
        Tab.new(vim.tbl_extend("force", buf, { name = "first", dir = "aaa/bbb" }), 1),
        Tab.new(vim.tbl_extend("force", buf, { name = "second", dir = "ccc/ddd/eee/fff" }), 2),
        Tab.new(vim.tbl_extend("force", buf, { name = "third", dir = "ggg" }), 3),
      }

      tabline = Element.new({
        children = vim.tbl_map(function(tab)
          return tab:element()
        end, tabs)
      })
    end)

    it("can be set a maximum width", function()
      local width = tabline:width()
      tabline:set_maximum_width(width - 5)

      assert.are.same({
        " 1 aaa/bbb/first.ext ",
        " 2 …d/eee/fff/second.ext ",
        " 3 ggg/third.ext ",
      }, vim.tbl_map(function(tab) return tab:to_string() end, tabline.children))

      assert.are.same({
        21,
        25,
        17,
      }, vim.tbl_map(function(tab) return tab:width() end, tabline.children))

      assert.are.same(68 - 5, tabline:width())
    end)

    it("can reduce width across multiple tabs", function()
      local width = tabline:width()
      tabline:set_maximum_width(width - 5 - 4)

      assert.are.same({
        " 1 aaa/bbb/first.ext ",
        " 2 …e/fff/second.ext ",
        " 3 ggg/third.ext ",
      }, vim.tbl_map(function(tab) return tab:to_string() end, tabline.children))

      assert.are.same({
        21,
        21,
        17,
      }, vim.tbl_map(function(tab) return tab:width() end, tabline.children))

      assert.are.same(68 - 5 - 4, tabline:width())
    end)

    it("will reduce width till all elements are equal", function()
      local width = tabline:width()
      tabline:set_maximum_width(width - 17)

      assert.are.same({
        " 1 …bb/first.ext ",
        " 2 …f/second.ext ",
        " 3 ggg/third.ext ",
      }, vim.tbl_map(function(tab) return tab:to_string() end, tabline.children))

      assert.are.same({
        17,
        17,
        17,
      }, vim.tbl_map(function(tab) return tab:width() end, tabline.children))

      assert.are.same(68 - 17, tabline:width())
    end)

    it("will reduce up until a minimum char visibility", function()
      local width = tabline:width()
      tabline:set_maximum_width(width - 18)

      assert.are.same({
        " 1 …b/first.ext ", -- About to hide path
        " 2 …f/second.ext ",
        " 3 ggg/third.ext ",
      }, vim.tbl_map(function(tab) return tab:to_string() end, tabline.children))

      assert.are.same({
        16,
        17,
        17,
      }, vim.tbl_map(function(tab) return tab:width() end, tabline.children))

      assert.are.same(68 - 18, tabline:width())
    end)

    it("will drop an entire path when below its minimum", function()
      local width = tabline:width()
      tabline:set_maximum_width(width - 19)

      assert.are.same({
        " 1 …b/first.ext ",
        " 2 second.ext ", -- path has dropped off by an extra 2 (ie. don't show "../")
        " 3 ggg/third.ext ",
      }, vim.tbl_map(function(tab) return tab:to_string() end, tabline.children))

      assert.are.same({
        16,
        14,
        17,
      }, vim.tbl_map(function(tab) return tab:width() end, tabline.children))

      assert.are.same(68 - 19 - 2, tabline:width())
    end)
  end)
end)
