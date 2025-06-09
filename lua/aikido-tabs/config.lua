local M = {
  icons = true,
}

function M.setup(opts)
  opts = opts or {}
  if opts.icons ~= nil then
    M.icons = opts.icons
  end
end

return M
