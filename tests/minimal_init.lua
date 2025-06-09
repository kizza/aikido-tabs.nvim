-- Setup plugin
local current_dir = vim.fn.getcwd()
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Setup plenary
vim.opt.runtimepath:append(current_dir .. "/deps/plenary.nvim")

-- Setup nvim-web-devicons
vim.opt.runtimepath:append(current_dir .. "/deps/nvim-web-devicons")

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")

require('aikido-tabs').setup({ icons = false })
