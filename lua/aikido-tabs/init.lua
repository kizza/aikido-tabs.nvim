local Buffers = require("aikido-tabs.buffers")
local Element = require("aikido-tabs.element")
local Line = require("aikido-tabs.line")
local util = require("aikido-tabs.util")
local augroup = vim.api.nvim_create_augroup('AikidoTabs', { clear = true })
local timer = vim.uv.new_timer()

-- [Tab bar]
--   [Tab]
--     [Number] - flex.basis 99
--     [Icon] - flex.basis 99
--     [Label]
--     [Status]
--   [Tab]
--   [Tab]
local M = {}

local function display()
  vim.o.tabline = M.render()
end

local function listen()
  vim.api.nvim_create_autocmd(
    {
      'BufAdd',
      -- 'BufWipeout', -- BufDelete fire *before* removes from :ls
      'BufEnter',
      'BufWritePost',
      'TabEnter',
      'TextChanged',
      'TextChangedI',
      'VimEnter',
      'VimResized',
    }, {
      group = augroup,
      callback = function(args)
        timer:stop()
        if vim.list_contains({ 'VimResized', 'TextChanged', 'TextChangedI' }, args.event) then
          timer:start(100, 0, vim.schedule_wrap(display))
        else
          vim.schedule(function() display() end)
        end
      end,
    })
end

function M.setup(opts)
  local config = require("aikido-tabs.config")
  config.setup(opts)

  local highlights = require("aikido-tabs.highlights")
  highlights.create()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      highlights.create()
      display()                  -- once, to rebuild the highlight groups for icons /shrug
      vim.schedule_wrap(display) -- second to redraw, with the highlight groups present
    end,
  })

  listen()
  display()
  vim.o.showtabline = 2
end

function M.click_handler(index)
  local buffers = Buffers.list()
  vim.fn.execute("b " .. buffers[index])
end

local function build_tabline()
  local bufs = Buffers.build()
  local elements = vim.tbl_map(function(buf) return buf:element() end, bufs)

  local tabline = Line.new({ overflow_symbols = true, children = elements })
  tabline:set_maximum_width(vim.o.columns)

  local focused = util.find(bufs, function(buf) return buf.active or buf.current end)
  if focused then
    tabline.focus_index = focused.index
  end

  return tabline
end

function M.to_string()
  return build_tabline():to_string()
end

function M.render()
  return build_tabline():render()
end

return M
