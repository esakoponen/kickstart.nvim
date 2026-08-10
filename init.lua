-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Setting options ]]
-- `:help option-list` lists them all; `:help 'name'` explains any single one.

-- Absolute number on the cursor line, relative on the rest, so 5j / 3k are countable at a glance.
vim.opt.number = true
vim.opt.relativenumber = true

-- Rounded borders on every floating window (hover, diagnostics, fzf-lua).
vim.opt.winborder = 'rounded'

-- Long lines run off the right edge instead of continuing on the next row, so one line stays one row.
vim.opt.wrap = false

-- Ignore the mouse entirely, so a stray touchpad brush cannot move the cursor or start a selection.
vim.opt.mouse = ''

-- mini.statusline already shows the mode; this drops the duplicate "-- INSERT --" on the last line.
vim.opt.showmode = false

-- When a line does wrap, the continuation keeps the indent of the line it belongs to.
vim.opt.breakindent = true

-- Persist undo history to disk, so `u` still reaches yesterday's edits after reopening a file.
vim.opt.undofile = true

-- Searches ignore case until you type a capital (or \C), which then makes the search exact.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Always reserve the sign column, so git signs and diagnostics appearing never shift text sideways.
vim.opt.signcolumn = 'yes'

-- Idle milliseconds before CursorHold fires; this is what paces LSP document highlight.
vim.opt.updatetime = 250

-- How long Neovim waits for the rest of a multi-key mapping, and so when which-key will pop up.
vim.opt.timeoutlen = 300

-- New splits open right and below, rather than pushing the current buffer out of position.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Keep the text you are reading visually still when a split opens or closes above it.
vim.opt.splitkeep = 'screen'

-- Render otherwise-invisible characters, so tabs and stray trailing spaces are obvious.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Hide the ~ filler that would otherwise mark every row past the end of the buffer.
vim.opt.fillchars = { eob = ' ' }

-- Live preview of :s/// as you type it, with off-screen matches shown in a temporary split.
vim.opt.inccommand = 'split'

-- Subtle highlight on the line the cursor sits on.
vim.opt.cursorline = true

-- Start scrolling this many lines/columns before the cursor reaches the edge, instead of at it.
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Scroll wrapped lines by screen row rather than jumping a whole logical line (only bites when wrap is on).
vim.opt.smoothscroll = true

-- In Visual-block mode only, allow the cursor past end-of-line, so ragged lines still select as a rectangle.
vim.opt.virtualedit = 'block'

-- Cap the completion popup at 10 rows, so a long candidate list cannot swallow the window.
vim.opt.pumheight = 10

-- One statusline for the whole window instead of one per split: less chrome once splits are open.
vim.opt.laststatus = 3

-- Share the Windows clipboard with the unnamed register, so y and p work across applications.
-- Trade-off: d and x overwrite it too. Use "0p to paste the last *yank* specifically.
vim.opt.clipboard = 'unnamedplus'

-- Make <C-o>/<C-i> behave as a real stack, and restore the scroll position when jumping back.
vim.opt.jumpoptions = 'stack,view,clean'

-- Prompt to save rather than failing with E37 when :q would discard unsaved changes.
vim.opt.confirm = true

-- Indentation: 4 spaces everywhere. guess-indent overrides these per file when a file disagrees.
vim.opt.expandtab = true -- <Tab> inserts spaces, never a literal tab character
vim.opt.tabstop = 4      -- display width of a tab character that is already in the file
vim.opt.softtabstop = 4  -- how far <Tab> and <BS> move in insert mode
vim.opt.shiftwidth = 4   -- how far >>, << and autoindent shift

-- Sort diagnostics worst-first, and name the source only when more than one is reporting.
-- Borders come from 'winborder' above, so no border option is needed here.
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = 'if_many' },
  float = { source = 'if_many' },
})

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Source rc
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Disable recursive mapping and silence command-line feedback.
local opts = { noremap = true, silent = true }

-- Nordic layout: [ and ] need AltGr, so use the free home-row keys instead.
-- `remap = true` is required so plugin-defined pairs (]d, ]c, ]q, ...) resolve through them.
vim.keymap.set({ 'n', 'x', 'o' }, 'ö', '[', { remap = true, desc = 'Prev ([) prefix' })
vim.keymap.set({ 'n', 'x', 'o' }, 'ä', ']', { remap = true, desc = 'Next (]) prefix' })

-- Replay macro q without reaching for @ (AltGr+2); Q's default Ex mode is dead weight.
vim.keymap.set('n', 'Q', '@q', { desc = 'Replay macro q' })

-- Show diagnostic in a floating window (remains unchanged)
vim.keymap.set('n', '<leader>e', function() vim.diagnostic.open_float() end, opts)

-- Show diagnostics in quickfix list (remains unchanged)
vim.keymap.set('n', '<leader>q', function() vim.diagnostic.setloclist() end, opts)


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

-- Briefly highlight the region that was just yanked or pasted; try it with `yap`.
--  See `:help vim.hl.hl_op()` (replaced vim.highlight.on_yank / vim.hl.on_yank)
vim.api.nvim_create_autocmd({ 'TextYankPost', 'TextPutPost' }, {
  desc = 'Highlight yanked/pasted text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
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
  -- Colorschemes (both installed; pick between them at runtime with <leader>uc)
  'https://github.com/folke/tokyonight.nvim',
  -- `name` is needed here: the repo is called "nvim", which would be a confusing directory
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  -- Popup listing the keys that can follow the prefix you just typed
  'https://github.com/folke/which-key.nvim',
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

-- [[ Colorscheme ]]
-- Both variants must be configured before one is applied, since setup() decides
-- what the `tokyonight`/`catppuccin` names resolve to.
require('tokyonight').setup({ style = 'night' })   -- storm | moon | night | day
require('catppuccin').setup({ flavour = 'mocha' }) -- latte | frappe | macchiato | mocha

-- The chosen scheme is remembered in Neovim's state directory, outside this repo.
local colorscheme_file = vim.fs.joinpath(vim.fn.stdpath('state'), 'colorscheme')

-- Record every colorscheme change, wherever it came from (:colorscheme, the picker below).
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('remember-colorscheme', { clear = true }),
  callback = function(ev)
    vim.fn.writefile({ ev.match }, colorscheme_file)
  end,
})

-- Restore last session's choice; fall back if the file is missing or names a scheme that is gone.
local saved = vim.fn.filereadable(colorscheme_file) == 1 and vim.fn.readfile(colorscheme_file)[1] or nil
if not (saved and pcall(vim.cmd.colorscheme, saved)) then
  vim.cmd.colorscheme('tokyonight-night')
end

-- [[ which-key: shows what can follow a half-typed key sequence ]]
-- It reads the `desc` field of every keymap, so a mapping without one shows as raw Lua.
require('which-key').setup({
  preset = 'helix',                 -- centred column; 'classic' and 'modern' are the alternatives
  delay = vim.o.timeoutlen,         -- pop up in step with the mapping timeout rather than before it
  icons = { mappings = false },     -- text only, matching the icon-free statusline
})

-- Name the prefixes, so the popup reads as a menu instead of a flat key dump.
-- `proxy` is what makes the Nordic bracket keys work: ö is a mapping *to* [, so
-- without it which-key would show an empty group rather than everything under [.
require('which-key').add({
  { '<leader>s', group = 'Search' },
  { '<leader>u', group = 'UI / toggle' },
  { '<leader>r', group = 'Config' },
  { 'ö', proxy = '[', group = 'Prev ([)' },
  { 'ä', proxy = ']', group = 'Next (])' },
})

-- List the mappings that only exist in this buffer (LSP, oil, gitsigns).
vim.keymap.set('n', '<leader>?', function()
  require('which-key').show({ global = false })
end, { desc = 'Buffer-local keymaps' })

require('fzf-lua').setup({})
-- fzf-lua shells out to ripgrep for grep (rg)
-- winget install BurntSushi.ripgrep.MSVC

local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect fzf-lua' })
vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', fzf.diagnostics_workspace, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })

-- Browse colorschemes with live preview; the choice is persisted by the autocmd above.
vim.keymap.set('n', '<leader>uc', fzf.colorschemes, { desc = 'Change [C]olorscheme' })

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
  'bicep',
  'c',
  'c_sharp',
  'cpp',
  'css',
  'eex', -- HEEx templates embed EEx, treesitter needs both for correct injections
  'elixir',
  'embedded_template', -- embedded_template = ERB, for Rails views
  'erlang',
  'heex',
  'javascript',
  'lua',
  'luadoc',
  'python',
  'ruby',
  'rust',
  'typescript',
}
require('nvim-treesitter').install(ts_parsers)

-- HEEx files aren't detected by Neovim's built-in filetype rules by default;
-- without this, elixirls and the heex treesitter parser never attach.
vim.filetype.add({ extension = { heex = 'heex' } })

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
-- [ ] Erlang         -> no LSP on native Windows for now
--     NOTE: erlang_ls is unmaintained and its recommended replacement, elp,
--     only ships prebuilt binaries for macOS/Linux (confirmed via ELP's own
--     install docs -- no Windows binary, and building from source needs
--     `sbt`/Scala for a sub-component, not worth attempting here).
--     Treesitter still gives syntax highlighting for .erl files below.
--     Revisit via WSL later, where `elp`/`erlang_ls` install cleanly.
-- [x] Ruby on Rails -> ruby_lsp (same server as Ruby)
-- [ ] Add the 'ruby-lsp-rails' gem to the project for Rails-aware features
-- [x] Rust          -> rust_analyzer (with clippy as the check command)
-- [x] Lua           -> lua_ls
-- [x] HTML          -> html
-- [x] CSS           -> cssls
-- [x] JavaScript    -> ts_ls (+ eslint for lint diagnostics/code actions)
-- [x] TypeScript    -> ts_ls (+ eslint for lint diagnostics/code actions)
-- [x] Bicep         -> bicep
-- [x] HEEx          -> elixirls (same server as Elixir; handles .heex via its
--     filetypes list, see vim.filetype.add above for HEEx detection)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    -- Neovim maps grn/gra/gri/grr/grt/grx/gO globally and K/<C-s> on attach; grd is the gap.
    map('grd', vim.lsp.buf.definition, '[G]oto [D]efinition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Underline the other references to the symbol under the cursor while it rests there.
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local hl = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = hl,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = hl,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- Inlay hints are off by default; toggle them per buffer under the UI prefix.
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>uh', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, 'Toggle inlay [H]ints')
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
  -- elp = {}, -- Erlang: no native-Windows binary available, see note above
  html = {},   -- HTML
  cssls = {},  -- CSS
  ts_ls = {},  -- JavaScript, TypeScript
  eslint = {
    -- Runs the project's own local ESLint config; provides lint diagnostics
    -- and a code action to auto-fix everything ESLint can fix.
    settings = { workingDirectories = { mode = 'auto' } },
  },
  bicep = {}, -- Azure Bicep
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
        -- Tell lua_ls that `vim` is a real global (it's injected by Neovim's
        -- runtime, not something lua_ls can infer on its own), and point it
        -- at Neovim's own Lua API definitions so completion/hover work too.
        diagnostics = { globals = { 'vim' } },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
        format = { enable = false },
      },
    },
  },
}

require('mason').setup({})

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, {
  'stylua',     -- Lua formatter
  'ruff',       -- Python linter + formatter
  'rubocop',    -- Ruby linter + formatter
  'stylelint',  -- CSS linter
  -- NOTE: Elixir's `credo` isn't a standalone Mason-installable binary -- it's
  -- added as a project dependency instead (e.g. via `mix.exs`). LSP
  -- diagnostics from elixirls still work without it.
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
-- NOTE: JS/TS linting comes from the `eslint` LSP server above (surfaces as
-- diagnostics automatically) -- no nvim-lint entry needed for those.
require('lint').linters_by_ft = {
  python = { 'ruff' },
  ruby = { 'rubocop' },
  css = { 'stylelint' }, -- requires a project-local stylelint config to do anything
}
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function() require('lint').try_lint() end,
})

-- The modeline below applies to this file only, and stays at 2 to match how init.lua
-- is already indented; the global default set near the top is 4. See `:help modeline`.
-- vim: ts=2 sts=2 sw=2 et
