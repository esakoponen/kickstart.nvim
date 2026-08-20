-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`

-- Enable line numbers default
vim.opt.relativenumber = true

-- Disable mouse
vim.opt.mouse = ''

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- :echo stdpath('config')
-- In Windows, ~/AppData/Local/nvim/init.lua
-- :e $MYVIMRC and :source $
vim.keymap.set('n', '<leader>rc', ':e $MYVIMRC<CR>', { desc = 'Edit init.lua' })

-- Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Add all plugins at once
vim.pack.add({
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/stevearc/oil.nvim'
})

require('fzf-lua').setup({})
-- fzf-lua shells out to ripgrep for grep (rg)
-- winget install BurntSushi.ripgrep.MSVC

vim.keymap.set('n', '<leader>ff', require('fzf-lua').files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', require('fzf-lua').live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', require('fzf-lua').buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', require('fzf-lua').help_tags, { desc = 'Help tags' })

-- Setup LSP for following languages
-- [ ] C
-- [ ] C++
-- [ ] Python
-- [ ] Ruby
-- [ ] Elixir
-- [ ] C#
-- [ ] Erlang
-- [ ] Ruby on Rails
-- [ ] Rust
-- [ ] Lua

-- Set intend prefs.
vim.opt.expandtab = true  -- Use spaces instead of tab char.
vim.opt.tabstop = 2       -- Number of spaces a <Tab> char is displayed as.
vim.opt.softtabstop = 2   -- Number of spaces inserted with <Tab>
vim.opt.shiftwidth = 4    -- Number of spaces used for indent level (>>, <<, auto)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
