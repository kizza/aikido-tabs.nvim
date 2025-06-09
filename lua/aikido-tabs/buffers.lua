local Tab = require("aikido-tabs.tab")

local M = {}

local api = vim.api

local should_handle = function(bufnr, path)
  return path ~= "" and vim.bo[bufnr].buflisted and api.nvim_buf_get_name(bufnr) ~= ""
end

function M.list()
  return vim.tbl_filter(function(bufnr)
    return should_handle(bufnr)
  end, api.nvim_list_bufs())
end

local function build_buffers_list()
  local current_bufnr = api.nvim_get_current_buf()
  local processed = {}
  -- print("building_buffer_list " .. tostring(current_bufnr))
  -- print(vim.inspect(M.list()))

  for _, bufnr in ipairs(M.list()) do
    local path = api.nvim_buf_get_name(bufnr)
    local opts = vim.bo[bufnr]

    if should_handle(bufnr, path) then
      local buf = {
        bufnr = bufnr,
        path = path,
        is_directory = vim.fn.isdirectory(path) == 1,
        dir = vim.fn.fnamemodify(path, ":.:h"),
        name = vim.fn.fnamemodify(path, ":t:r"):match("^(.+)") or "",
        -- ext = vim.fn.fnamemodify(path, ":e"),
        ext = vim.fn.fnamemodify(path, ":t"):match("%.(.+)$") or "", -- support .multiple.extensions
        current = bufnr == current_bufnr,
        safe = bufnr <= current_bufnr,
        filetype = opts.filetype,
        buftype = opts.buftype,
        modified = opts.modified,
        modifiable = opts.modifiable,
        readonly = opts.readonly,
        active = vim.fn.bufwinnr(bufnr) > 0,
      }
      table.insert(processed, buf)
    end
  end
  return processed
end

function M.build()
  local elements = {}
  for i, buf in ipairs(build_buffers_list()) do
    table.insert(elements, Tab.new(buf, i))
  end
  return elements
end

return M
