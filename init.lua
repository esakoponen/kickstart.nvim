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
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

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

-- Run build steps for plugins that need them after install/update.
-- See `:help vim.pack-events`
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end
    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      vim.cmd('TSUpdate')
    end
  end,
})

-- Add all plugins at once
vim.pack.add({
  -- Fuzzy finder (files, live grep, buffers, help)
  'https://github.com/ibhagwan/fzf-lua',
  -- File explorer as an editable buffer
  'https://github.com/stevearc/oil.nvim',
  -- Auto-detect indent style/width per file
  'https://github.com/NMAC427/guess-indent.nvim',
  -- Git gutter signs + hunk navigation
  'https://github.com/lewis6991/gitsigns.nvim',
  -- Small independent modules: better text objects + surround editing + statusline
  'https://github.com/nvim-mini/mini.nvim',
  -- Accurate, fast syntax highlighting + indentation
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  -- Snippet engine + completion engine (text prediction as you type)
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range('2.*') },
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
  -- LSP client config + automatic language-server installer
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
  -- Formatting on demand / on save
  'https://github.com/stevearc/conform.nvim',
  -- Standalone linters (for style/lint rules the LSP doesn't cover)
  'https://github.com/mfussenegger/nvim-lint',
})

require('fzf-lua').setup({})
-- fzf-lua shells out to ripgrep for grep (rg)
-- winget install BurntSushi.ripgrep.MSVC

vim.keymap.set('n', '<leader>ff', require('fzf-lua').files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', require('fzf-lua').live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', require('fzf-lua').buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', require('fzf-lua').help_tags, { desc = 'Help tags' })

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
require('oil').setup({
  view_options = { show_hidden = true },
})

require('guess-indent').setup({})

require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})

-- [[ mini.nvim modules ]]
-- va) [V]isually select [A]round [)]paren, ci' [C]hange [I]nside [']quote, etc.
require('mini.ai').setup({ n_lines = 500 })
-- saiw) [S]urround [A]dd [I]nner [W]ord [)]Paren, sd' [S]urround [D]elete [']quotes
require('mini.surround').setup()
-- Minimal statusline
require('mini.statusline').setup({ use_icons = false })

-- [[ Treesitter: syntax highlighting + indentation ]]
local ts_parsers = {
  'bash',
  'diff',
  'html',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  -- Languages below match the LSP section further down
  'c',
  'c_sharp',
  'cpp',
  'elixir',
  'embedded_template', -- embedded_template = ERB, for Rails views
  'erlang',
  'lua',
  'luadoc',
  'python',
  'ruby',
  'rust',
}
require('nvim-treesitter').install(ts_parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  if not vim.treesitter.language.add(language) then return end
  vim.treesitter.start(buf, language)
  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
  if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
end

local ts_available = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match
    local language = vim.treesitter.language.get_lang(filetype)
    if not language then return end
    local ts_installed = require('nvim-treesitter').get_installed('parsers')
    if vim.tbl_contains(ts_installed, language) then
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(ts_available, language) then
      require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
    else
      treesitter_try_attach(buf, language)
    end
  end,
})

-- [[ Autocomplete + snippets: text prediction as you type ]]
require('luasnip').setup({})
require('blink.cmp').setup({
  keymap = { preset = 'default' }, -- <C-y> accept, <C-n>/<C-p> select, <C-space> open/docs
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  sources = { default = { 'lsp', 'path', 'snippets' } },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
})

-- [[ LSP: navigation, hover, diagnostics for each language ]]
-- [x] C             -> clangd
-- [x] C++           -> clangd
-- [x] Python        -> pyright
-- [x] Ruby          -> ruby_lsp
-- [x] Elixir        -> elixirls
-- [x] C#            -> csharp_ls
-- [x] Erlang        -> erlangls
-- [x] Ruby on Rails -> ruby_lsp (same server as Ruby)
-- [ ] Add the 'ruby-lsp-rails' gem to the project for Rails-aware features
-- [x] Rust          -> rust_analyzer (with clippy as the check command)
-- [x] Lua           -> lua_ls

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gri', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('grr', vim.lsp.buf.references, '[G]oto [R]eferences')
    map('grt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

---@type table<string, vim.lsp.Config>
local servers = {
  clangd = {},      -- C, C++
  pyright = {},     -- Python
  ruby_lsp = {},    -- Ruby, Ruby on Rails
  elixirls = {},    -- Elixir
  csharp_ls = {},   -- C#
  erlangls = {},    -- Erlang
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        check = { command = 'clippy' }, -- run clippy instead of plain `cargo check`
      },
    },
  },
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- formatting done by stylua instead
    end,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = { checkThirdParty = false },
        format = { enable = false },
      },
    },
  },
}

require('mason').setup({})

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, {
  'stylua',  -- Lua formatter
  'ruff',    -- Python linter + formatter
  'rubocop', -- Ruby linter + formatter
  -- NOTE: Elixir's `credo` and Erlang tooling aren't standalone
  -- Mason-installable binaries -- they are added as project dependencies
  -- instead (e.g. `credo` via `mix.exs`).
  -- LSP diagnostics from elixirls/erlangls still work without them.
})
require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- [[ Formatting ]]
require('conform').setup({
  notify_on_error = false,
  default_format_opts = { lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_format' },
    ruby = { 'rubocop' },
    rust = { 'rustfmt' }, -- requires `rustup component add rustfmt`
  },
})
vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format({ async = true }) end, { desc = '[F]ormat buffer' })

-- [[ Linting: style/lint rules beyond what the LSP flags ]]
require('lint').linters_by_ft = {
  python = { 'ruff' },
  ruby = { 'rubocop' },
}
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function() require('lint').try_lint() end,
})

-- Set indent prefs.
-- NOTE: shiftwidth was 4 while tabstop/softtabstop were 2 -- fixed to match,
-- otherwise <Tab> and >>/<< indent by different amounts.
vim.opt.expandtab = true  -- Use spaces instead of tab char.
vim.opt.tabstop = 2       -- Number of spaces a <Tab> char is displayed as.
vim.opt.softtabstop = 2   -- Number of spaces inserted with <Tab>
vim.opt.shiftwidth = 4    -- Number of spaces used for indent level (>>, <<, auto)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
