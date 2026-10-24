vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.wrap = false

vim.opt.cmdheight = 0

vim.opt.scrolloff = 10
vim.opt.colorcolumn = '81'

-- UFO folding
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.diagnostic.config({ virtual_text = false, float = { border = "rounded" } })
vim.wo.relativenumber = true

require 'lazy-bootstrap'
require 'lazy-plugins'
require 'options'
require 'keymaps'
require 'telescope-setup'
require 'treesitter-setup'
require 'lsp-setup'
require 'cmp-setup'
require("catppuccin").setup({
  no_italic = true,
  styles = {
    comments = {},
  }
})
vim.cmd.colorscheme "catppuccin-mocha"

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

