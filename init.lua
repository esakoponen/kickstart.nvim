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

-- How tabs, trailing spaces and non-breaking spaces are drawn *when* 'list' is on. Off by
-- default, since the texture is a distraction outside review; <leader>ul turns it on.
vim.opt.list = false
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

-- [[ Shell: PowerShell 7 ]]
-- Used by :terminal, :! and system(). Guarded on pwsh being present so the config still loads
-- on a machine without it, where Neovim falls back to its own default (cmd.exe on Windows).
-- These settings follow `:help shell-pwsh` rather than being hand-rolled; the parts matter:
--   -NoProfile          start-up is not slowed by a user profile, and behaviour is reproducible
--   InputEncoding/...   forces UTF-8 both ways, otherwise non-ASCII output arrives mangled
--   Out-File:Encoding   makes redirection write UTF-8 too, not the legacy codepage
--   OutputRendering     strips the ANSI colour codes pwsh 7 emits, which would show as escapes
--   shellquote/xquote   cleared, because PowerShell does its own quoting
--   shelltemp = false   pipe command output instead of going via a temporary file
if vim.fn.executable('pwsh') == 1 then
  vim.opt.shell = 'pwsh'
  vim.opt.shellcmdflag = table.concat({
    '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command',
    '[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();',
    "$PSDefaultParameterValues['Out-File:Encoding']='utf8';",
    "$PSStyle.OutputRendering='PlainText';",
  }, ' ')
  vim.opt.shellredir = '> %s 2>&1'
  vim.opt.shellpipe = '> %s 2>&1'
  vim.opt.shellquote = ''
  vim.opt.shellxquote = ''
  vim.opt.shelltemp = false
  vim.env.__SuppressAnsiEscapeSequences = 1 -- workaround pwsh still needs; harmless once it does not
end

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

-- Write, then re-run this buffer. `:source` with no filename sources the current buffer,
-- so this reloads init.lua after editing it. Sits next to <leader>rc under the Config group.
vim.keymap.set('n', '<leader>rr', '<cmd>update<CR><cmd>source<CR>', { desc = '[R]eload current Lua/Vim buffer' })

vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = '[W]rite buffer' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Nordic layout: [ and ] need AltGr, so use the free home-row keys instead.
-- `remap = true` is required so plugin-defined pairs (]d, ]c, ]q, ...) resolve through them.
vim.keymap.set({ 'n', 'x', 'o' }, 'ö', '[', { remap = true, desc = 'Prev ([) prefix' })
vim.keymap.set({ 'n', 'x', 'o' }, 'ä', ']', { remap = true, desc = 'Next (]) prefix' })

-- Replay macro q without reaching for @ (AltGr+2); Q's default Ex mode is dead weight.
vim.keymap.set('n', 'Q', '@q', { desc = 'Replay macro q' })

-- Show the diagnostics for the current line in a floating window.
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })

-- Collect the buffer's diagnostics into the location list (window-local, not the quickfix list).
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })


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

-- Move between splits with one keystroke instead of <C-w> then a direction.
-- <C-l> was :nohlsearch + :diffupdate + redraw; <Esc> above already clears the search highlight.
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })

-- Join lines without the cursor jumping to the seam: mark, join, return to the mark.
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join line, keep cursor put' })

-- Stay in Visual after shifting, so >>>> is just > pressed four times.
vim.keymap.set('x', '<', '<gv', { desc = 'Shift left, keep selection' })
vim.keymap.set('x', '>', '>gv', { desc = 'Shift right, keep selection' })

-- Recentre after a half-page jump or a search hit, so the cursor never lands at a screen edge.
-- zv additionally opens a fold the match is hidden inside.
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down, centred' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up, centred' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search hit, centred' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Prev search hit, centred' })

-- Replace a selection without losing what you copied: plain p would swap the register contents.
vim.keymap.set('x', '<leader>p', '"_dP', { desc = '[P]aste over, keep register' })

-- Delete into the black hole register, for throwing text away without disturbing the clipboard.
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"_d', { desc = '[D]elete to black hole' })

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
  -- Remembers which files were open, per directory and git branch
  'https://github.com/folke/persistence.nvim',
  -- One centred column, everything else hidden, on demand
  'https://github.com/folke/zen-mode.nvim',
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
  -- Select/move/swap by syntax node, and the textobject queries mini.ai reads
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  -- Close </div> as soon as <div> is typed, in HTML/JSX/HEEx
  'https://github.com/windwp/nvim-ts-autotag',
  -- Completion engine (text prediction as you type); snippets go through Neovim's own vim.snippet
  -- A library of ready-made snippets; pure data, blink discovers it on the runtimepath by itself
  'https://github.com/rafamadriz/friendly-snippets',
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
  { '<leader>b', group = 'Buffer' },
  { '<leader>c', group = 'Code' },
  { '<leader>g', group = 'Git' },
  { '<leader>s', group = 'Search' },
  -- Capital S, because <leader>q is already the diagnostics loclist here.
  { '<leader>S', group = 'Session' },
  { '<leader>u', group = 'UI / toggle' },
  { '<leader>r', group = 'Config' },
  { 'ö', proxy = '[', group = 'Prev ([)' },
  { 'ä', proxy = ']', group = 'Next (])' },
})

-- [[ Sessions ]]
-- HEADS UP, this is the one thing here that acts on its own: setup() registers a VimLeavePre
-- autocmd, so quitting records which files were open. It writes only to
-- stdpath('state')/sessions, keyed by directory and git branch, and never touches the project.
-- `need = 1` means quitting an empty Neovim writes nothing. Restoring is always manual, below.
-- <leader>Sd cancels saving for the current session when you would rather not record it.
require('persistence').setup()

vim.keymap.set('n', '<leader>Ss', function() require('persistence').load() end, { desc = '[S]ession restore (this dir)' })
vim.keymap.set('n', '<leader>Sl', function() require('persistence').load({ last = true }) end, { desc = '[S]ession restore [L]ast' })
vim.keymap.set('n', '<leader>Sf', function() require('persistence').select() end, { desc = '[S]ession pick from list' })
vim.keymap.set('n', '<leader>Sd', function() require('persistence').stop() end, { desc = '[S]ession do not save on exit' })

-- [[ Zen mode ]]
-- Purely on demand. Hides the number and sign columns as well as narrowing the window, so
-- nothing but the text remains; press it again to restore the previous layout exactly.
require('zen-mode').setup({
  window = {
    width = 100,
    options = { number = false, relativenumber = false, signcolumn = 'no' },
  },
})
vim.keymap.set('n', '<leader>uz', '<cmd>ZenMode<CR>', { desc = 'Toggle [Z]en mode' })

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
vim.keymap.set('n', '<leader>sp', fzf.builtin, { desc = '[S]earch [P]ickers (list every fzf-lua picker)' })

-- Symbols: function, class, module and method names, rather than file names or raw text.
-- ss covers the current file and sS the whole project. Both come from the language server, so
-- they know what a symbol *is*; st asks treesitter instead, which needs no server running and is
-- therefore the only one of the three that works in Erlang here.
-- The built-in gO does the same job as ss, but dumps into the location list instead of a picker.
vim.keymap.set('n', '<leader>ss', fzf.lsp_document_symbols, { desc = '[S]earch [S]ymbols (this file)' })
vim.keymap.set('n', '<leader>sS', fzf.lsp_live_workspace_symbols, { desc = '[S]earch [S]ymbols (project)' })
vim.keymap.set('n', '<leader>st', fzf.treesitter, { desc = '[S]earch [T]reesitter symbols (no LSP needed)' })
vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', fzf.diagnostics_workspace, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })

-- Browse colorschemes with live preview; the choice is persisted by the autocmd above.
vim.keymap.set('n', '<leader>uc', fzf.colorschemes, { desc = 'Change [C]olorscheme' })

-- Git pickers. These are repo-wide, unlike the gitsigns mappings which act on the current hunk.
-- <leader>gg is the hub: it lists changed files and can stage/unstage them from the picker.
vim.keymap.set('n', '<leader>gg', fzf.git_status, { desc = '[G]it status' })
vim.keymap.set('n', '<leader>gl', fzf.git_commits, { desc = '[G]it [L]og (repo)' })
vim.keymap.set('n', '<leader>gL', fzf.git_bcommits, { desc = '[G]it [L]og (this file)' })
vim.keymap.set('n', '<leader>gB', fzf.git_branches, { desc = '[G]it [B]ranches' })

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
require('oil').setup({
  view_options = { show_hidden = true },
})

-- Windows has no single root above C:/, so oil's parent action at a drive root tries to list the
-- machine's drives -- and it does that by shelling out to `wmic`, which Windows 11 no longer
-- ships. The result is E475 "'wmic' is not executable" and a buffer stuck on "loading".
-- Intercept `-` at a drive root and offer the drives found here instead. vim.uv.fs_stat needs no
-- subprocess, takes a few milliseconds for A-Z, and naturally skips drives that exist but hold no
-- media, such as an empty card reader.
if vim.fn.has('win32') == 1 then
  local function drive_roots()
    local roots = {}
    for letter in ('ABCDEFGHIJKLMNOPQRSTUVWXYZ'):gmatch('.') do
      local root = letter .. ':/'
      if vim.uv.fs_stat(root) then roots[#roots + 1] = root end
    end
    return roots
  end

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'oil',
    group = vim.api.nvim_create_augroup('oil-windows-drive-root', { clear = true }),
    callback = function(ev)
      vim.keymap.set('n', '-', function()
        -- get_current_dir() returns a trailing-separator path, so a drive root looks like `C:\`
        local dir = require('oil').get_current_dir()
        if not (dir and dir:match('^%a:[/\\]$')) then
          require('oil').open() -- not at a root, so oil's own parent behaviour is correct
          return
        end
        local roots = drive_roots()
        if #roots < 2 then
          vim.notify(dir .. ' is the only drive ready; nothing above it', vim.log.levels.INFO)
          return
        end
        require('fzf-lua').fzf_exec(roots, {
          prompt = 'Drive> ',
          actions = { default = function(selected) require('oil').open(selected[1]) end },
        })
      end, { buffer = ev.buf, desc = 'Parent directory, or pick a drive at a drive root' })
    end,
  })
end

require('guess-indent').setup({})

require('gitsigns').setup({
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  -- Buffer-local, so these only exist in a file git actually tracks.
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'Git: ' .. desc })
    end

    -- äh/öh step between changes; capital H jumps straight to the last/first one in the file.
    -- 'h' rather than the more usual 'c' because ]c/[c is diff mode's own change motion.
    map('n', ']h', function() gs.nav_hunk('next') end, 'Next hunk')
    map('n', '[h', function() gs.nav_hunk('prev') end, 'Prev hunk')
    map('n', ']H', function() gs.nav_hunk('last') end, 'Last hunk')
    map('n', '[H', function() gs.nav_hunk('first') end, 'First hunk')

    -- Stage or discard just the change under the cursor, or exactly the lines selected.
    -- stage_hunk toggles: run it on an already-staged hunk to unstage it again.
    map('n', '<leader>gs', gs.stage_hunk, 'Stage hunk')
    map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
    map('x', '<leader>gs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage selection')
    map('x', '<leader>gr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset selection')
    map('n', '<leader>gS', gs.stage_buffer, 'Stage whole buffer')
    map('n', '<leader>gR', gs.reset_buffer, 'Reset whole buffer')

    -- Inspect without leaving the file: the diff inline, who wrote the line, or a full diff split.
    map('n', '<leader>gp', gs.preview_hunk_inline, 'Preview hunk inline')
    map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
    map('n', '<leader>gd', gs.diffthis, 'Diff this file')
    map('n', '<leader>ub', gs.toggle_current_line_blame, 'Toggle inline blame')

    -- Hunk as a textobject, so dih discards a change and vih selects one.
    map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select hunk')
  end,
})

-- [[ mini.nvim modules ]]
-- va) [V]isually select [A]round [)]paren, ci' [C]hange [I]nside [']quote, etc.
-- Uppercase F/C and lowercase o are backed by treesitter queries. They are deliberately not
-- af/ac: mini.ai already uses lowercase f for a function *call* and a for an argument, and
-- those keep working in files no parser handles. daF deletes a whole function definition.
local MiniAi = require('mini.ai')
local ai_ts = MiniAi.gen_spec.treesitter
require('mini.ai').setup({
  n_lines = 500,
  custom_textobjects = {
    F = ai_ts({ a = '@function.outer', i = '@function.inner' }), -- function/method definition
    C = ai_ts({ a = '@class.outer', i = '@class.inner' }),       -- class, module, struct
    o = ai_ts({                                                  -- block: if/case/for/while
      a = { '@conditional.outer', '@loop.outer' },
      i = { '@conditional.inner', '@loop.inner' },
    }),
  },
})
-- saiw) [S]urround [A]dd [I]nner [W]ord [)]Paren, sd' [S]urround [D]elete [']quotes
require('mini.surround').setup()
-- Minimal statusline
require('mini.statusline').setup({ use_icons = false })

-- Auto-close brackets and quotes, and make <BS> delete both halves of an empty pair.
require('mini.pairs').setup()

-- File-type markers for fzf-lua and oil. 'ascii' shows a letter instead of a glyph, because
-- only stock Cascadia is installed here; switch to 'glyph' after installing a Nerd Font.
require('mini.icons').setup({ style = 'ascii' })
MiniIcons.mock_nvim_web_devicons() -- lets plugins that ask for nvim-web-devicons use these instead

-- Close a buffer while leaving the window layout alone, which :bdelete does not do.
require('mini.bufremove').setup()
vim.keymap.set('n', '<leader>bd', function() require('mini.bufremove').delete(0, false) end, { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { desc = '[B]uffer [D]elete, discard changes' })

-- Paint #rrggbb strings in their own colour; TODO/FIXME words are left to todo-comments later.
local hipatterns = require('mini.hipatterns')
hipatterns.setup({ highlighters = { hex_color = hipatterns.gen_highlighter.hex_color() } })

-- NOTE: mini.move, mini.splitjoin and mini.bracketed were deliberately left out. They were
-- enabled once and removed again: each adds mappings that are easy to forget you have, and
-- ö/ä stays easier to reason about when everything under it comes from Neovim itself,
-- gitsigns or treesitter. Re-enabling any of them is a single setup() call.

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

-- [[ Treesitter textobjects: move between and swap syntax nodes ]]
-- Selection (daF, cio, ...) is handled by mini.ai above; this half covers jumping and reordering.
require('nvim-treesitter-textobjects').setup({
  move = { set_jumps = true }, -- record each jump so <C-o> walks back out of them
})

local ts_move = require('nvim-treesitter-textobjects.move')
local ts_swap = require('nvim-treesitter-textobjects.swap')
local ts_repeat = require('nvim-treesitter-textobjects.repeatable_move')

-- ]m/[m jump to the start of the next/previous function, ]M/[M to its end (so äm/öm on this layout).
-- Neovim's built-in ]m only understands brace languages; going through the parser makes it work
-- in Elixir, Ruby and Python too. Wrapped so the jump can be repeated with ; and ,.
local function move_map(key, move_fn, capture, desc)
  local repeatable = ts_repeat.make_repeatable_move(move_fn)
  vim.keymap.set({ 'n', 'x', 'o' }, key, function() repeatable(capture, 'textobjects') end, { desc = desc })
end
move_map(']m', ts_move.goto_next_start, '@function.outer', 'Next function start')
move_map('[m', ts_move.goto_previous_start, '@function.outer', 'Prev function start')
move_map(']M', ts_move.goto_next_end, '@function.outer', 'Next function end')
move_map('[M', ts_move.goto_previous_end, '@function.outer', 'Prev function end')

-- ; and , now repeat the last treesitter jump *or* the last f/F/t/T, whichever came last.
-- The four expr mappings below are what keep plain f/t repeatable; without them ; would only
-- know about treesitter moves. Nothing is lost -- this is a superset of the default behaviour.
vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat.repeat_last_move_next, { desc = 'Repeat move forward' })
vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat.repeat_last_move_previous, { desc = 'Repeat move backward' })
vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat.builtin_f_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat.builtin_F_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat.builtin_t_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat.builtin_T_expr, { expr = true })

-- Reorder function parameters in place, without a cut-and-paste round trip.
vim.keymap.set('n', '<leader>ca', function() ts_swap.swap_next('@parameter.inner') end, { desc = '[C]ode swap [A]rg next' })
vim.keymap.set('n', '<leader>cA', function() ts_swap.swap_previous('@parameter.inner') end, { desc = '[C]ode swap [A]rg prev' })

-- Keep the closing tag in step with the opening one while typing (html, jsx, tsx, heex, xml).
require('nvim-ts-autotag').setup({})

-- [[ Autocomplete + snippets: text prediction as you type ]]
-- No snippet engine is configured: blink's default preset expands through Neovim's own
-- vim.snippet, and its snippets source finds friendly-snippets on the runtimepath by itself.
require('blink.cmp').setup({
  -- <C-y> accept, <C-n>/<C-p> select, <C-space> open/docs, <Tab>/<S-Tab> jump between
  -- the placeholders of an expanded snippet, <C-k> signature help.
  keymap = { preset = 'default' },
  completion = {
    -- A calmer default; <C-space> shows the documentation when it is actually wanted.
    documentation = { auto_show = false },
  },
  -- 'buffer' completes words already present in open buffers. It is blink's own default and
  -- is the only source that does anything in a filetype with no LSP, such as Erlang here.
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
  -- Completion in : and / is already on by blink's own default, driven by <Tab>. Its menu is
  -- deliberately left on press rather than auto-showing, so typing a command is never intercepted.
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

    -- Inlay hints are off by default; toggle them for this buffer alone, under the UI prefix.
    -- Both calls must carry the same filter. enable() without one sets the global state and
    -- walks every loaded buffer, so reading one buffer's state and then writing globally would
    -- toggle hints everywhere -- and per-buffer enables never update the global flag, so the
    -- two can disagree.
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      local filter = { bufnr = event.buf }
      map('<leader>uh', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
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
  'stylua',        -- Lua formatter
  'ruff',          -- Python linter + formatter
  'rubocop',       -- Ruby linter + formatter
  'stylelint',     -- CSS linter
  'prettierd',     -- JS/TS/JSON/YAML/HTML/CSS/Markdown formatter (daemon)
  'prettier',      -- same, used when the daemon is not running
  'clang-format',  -- C/C++ formatter (mason spells it with a hyphen, conform with an underscore)
  'shfmt',         -- shell script formatter
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
-- prettierd is a background daemon producing the same output as prettier, without paying
-- node's startup cost on every format; prettier is the fallback if the daemon is unavailable.
local prettier = { 'prettierd', 'prettier', stop_after_first = true }

-- Off by default, so saving never reformats a file behind your back. <leader>uf turns it on
-- for the session; <leader>f formats on demand regardless.
vim.g.format_on_save = false

require('conform').setup({
  notify_on_error = false,
  default_format_opts = { lsp_format = 'fallback' }, -- filetypes absent below fall back to the LSP
  format_on_save = function()
    if not vim.g.format_on_save then return end
    return { timeout_ms = 1000, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_format' },
    ruby = { 'rubocop' },
    rust = { 'rustfmt' },   -- requires `rustup component add rustfmt`
    elixir = { 'mix' },     -- `mix format` ships with Elixir, so mason has nothing to install
    heex = { 'mix' },
    eex = { 'mix' },
    c = { 'clang_format' },
    cpp = { 'clang_format' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    html = prettier,
    css = prettier,
    scss = prettier,
    markdown = prettier,
  },
})

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format({ async = true }) end, { desc = '[F]ormat buffer' })

-- Reveal tabs and trailing whitespace when reviewing. 'list' is window-local, so this toggles
-- the current window alone; a split inherits whatever the window it was split from had.
vim.keymap.set('n', '<leader>ul', function()
  vim.wo.list = not vim.wo.list
end, { desc = 'Toggle invisible characters' })

-- Session-only toggle: it is deliberately not persisted, so a new session starts off again.
vim.keymap.set('n', '<leader>uf', function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify('Format on save: ' .. (vim.g.format_on_save and 'on' or 'off'))
end, { desc = 'Toggle [F]ormat on save' })

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
