local M = {}

---@return table
function M.compact(tbl)
  return vim.tbl_filter(function(v) return v ~= nil end, tbl)
end

function M.find(list, fn)
  return vim.tbl_filter(fn, list)[1]
end

function M.all(list, fn)
  return #list == #vim.tbl_filter(fn, list)
end

---@return boolean
function M.any(list, fn)
  for _, item in ipairs(list) do
    if fn(item) then
      return true
    end
  end
  return false
end

---@return number
function M.sum(list, fn)
  local total = 0
  for _, item in ipairs(list) do
    total = total + fn(item)
  end
  return total
end

return M
