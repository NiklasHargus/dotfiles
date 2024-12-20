-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- vim: ts=2 sts=2 sw=2 et
--

-- Filetree
-- vim.keymap.set('n', '<C-n>', "<cmd>Neotree toggle<cr>", {desc = "Open Filetree"})
-- vim.keymap.set('n', '<C-n>', "<cmd>Explore<cr>")
vim.keymap.set('n', '<leader>n', "<cmd>Oil<cr>", {desc="Open parent directory"})

-- Change focus
-- vim.keymap.set('n', '<C-h>', '<C-w>h')
-- vim.keymap.set('n', '<C-j>', '<C-w>j')
-- vim.keymap.set('n', '<C-k>', '<C-w>k')
-- vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Splits
vim.keymap.set('n', '<leader>ws', "<cmd>split<cr>", {desc = "[W]indow [s]plit"})
vim.keymap.set('n', '<leader>wv', "<cmd>vsplit<cr>", {desc = "[W]indow [v]ertical split"})
vim.keymap.set('n', '<leader>wq', "<cmd>q<cr>", {desc = "[W]indow [q]uit"})


-- Tmux 
vim.keymap.set('n', '<C-h>', '<cmd> TmuxNavigateLeft<cr>', {desc = "Move left"})
vim.keymap.set('n', '<C-j>', '<cmd> TmuxNavigateDown<cr>', {desc = "Move left"})
vim.keymap.set('n', '<C-k>', '<cmd> TmuxNavigateUp<cr>', {desc = "Move left"})
vim.keymap.set('n', '<C-l>', '<cmd> TmuxNavigateRight<cr>', {desc = "Move left"})


--clangd format
-- vim.keymap.set('n', '<leader>cf','<cmd>py3f<path-to-this-file>/clang-format.py<cr>')


-- TODO List
vim.keymap.set('n', '<leader>st', '<cmd> TodoTelescope<cr>', {desc = "[S]earch [T]ODOs"})

-- Debug
vim.keymap.set('n', '<leader>db', '<cmd> DapToggleBreakpoint <CR>', {desc = "[D]ebug [B]reakpoint"})
vim.keymap.set('n', '<leader>dr', '<cmd> DapContinue <CR>', {desc = "[d]ebug [r]un"})

-- Fold
vim.keymap.set('n', '<leader>fc', '<leader>zc', {desc = "[f]old [c]lose"})
vim.keymap.set('n', '<leader>fo', '<leader>zo', {desc = "[f]old [o]pen"})




