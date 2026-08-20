# Plugins

Every plugin is declared in the single `vim.pack.add({...})` call in `init.lua`. `vim.pack` is
Neovim's built-in package manager — there is no lazy.nvim or framework layer here. Revisions are
recorded in `nvim-pack-lock.json`.

Useful commands: `:packupdate` (update, with a diff to confirm), `:packupdate ++offline` (browse
what is installed), `:packdel <name>` (remove), `:checkhealth`.

## Appearance

| Plugin | Purpose |
|---|---|
| **tokyonight.nvim** | Colorscheme. Variants `tokyonight-night` (default), `-storm`, `-moon`, `-day`. |
| **catppuccin** | Alternative colorscheme: `catppuccin-mocha`, `-macchiato`, `-frappe`, `-latte`. Installed under an explicit `name` because the repo is literally called `nvim`. |
| **zen-mode.nvim** | Narrows to one centred column and hides the number and sign columns, on demand via `<leader>uz`. |

Both colorschemes are configured up front; `<leader>uc` switches between them with live preview,
and the choice is remembered in `stdpath('state')` across restarts.

## Navigation and discovery

| Plugin | Purpose |
|---|---|
| **fzf-lua** | Fuzzy finder for files, live grep, symbols, buffers, help, diagnostics, git state and colorschemes. Needs `fzf`, `rg` and `fd` on PATH. The main way to move around. |
| **oil.nvim** | File manager as an ordinary editable buffer: `-` opens the parent directory, then normal editing plus `:w` performs the renames, moves and deletes. Chosen deliberately over a file tree. |
| **which-key.nvim** | Shows which keys can follow the prefix just typed, labelled by group. The `ö`/`ä` entries use its `proxy` feature so they expand to the real `[`/`]` mappings. |
| **persistence.nvim** | Records which files were open, keyed by directory and git branch, so a project reopens where it was left. Saves on quit; restoring is manual. |

## Syntax and text structure

| Plugin | Purpose |
|---|---|
| **nvim-treesitter** (`main`) | Real parsers instead of regex, giving accurate highlighting and indentation. Parsers install on first encounter with a filetype, so a language missing from the list still works. |
| **nvim-treesitter-textobjects** (`main`) | Two jobs: `]m`/`[m` style motions and parameter swapping, plus the textobject *queries* that `mini.ai` reads for `aF`, `aC` and `ao`. |
| **nvim-ts-autotag** | Closes and renames HTML/JSX/TSX/HEEx tags as you type. |
| **guess-indent.nvim** | Detects a file's existing indentation and overrides the 4-space default per buffer, so editing someone else's file does not reformat it. |

## Editing (mini.nvim)

One plugin providing many independent modules; each is enabled by its own `setup()` call.

| Module | Purpose |
|---|---|
| **mini.ai** | Extends `a`/`i` textobjects: function calls, arguments, tags, and the treesitter-backed `F` (function definition), `C` (class), `o` (block). |
| **mini.surround** | Add, delete and replace surrounding characters: `sa`, `sd`, `sr`. |
| **mini.pairs** | Auto-closes brackets and quotes; `<BS>` removes both halves of an empty pair. |
| **mini.bufremove** | Closes a buffer without disturbing the window layout, unlike `:bdelete`. |
| **mini.statusline** | Minimal statusline, icon-free. |
| **mini.icons** | Filetype markers for fzf-lua and oil, in ASCII style since no Nerd Font is installed. |
| **mini.hipatterns** | Paints `#rrggbb` colour codes in their own colour. |

## Completion

| Plugin | Purpose |
|---|---|
| **blink.cmp** | Completion engine. Draws candidates from the LSP, open buffers, filesystem paths and snippets, and also completes in `:` and `/`. Accept with `<C-y>`; the documentation window opens only on `<C-space>`. |
| **friendly-snippets** | A library of ready-made snippets in VS Code format. Pure data — blink finds it on the runtimepath by itself and expands through Neovim's own `vim.snippet`, so there is no snippet engine to install or configure. |

## Language tooling

| Plugin | Purpose |
|---|---|
| **nvim-lspconfig** | Server configurations (paths, root markers, default settings) that `vim.lsp.config`/`vim.lsp.enable` then apply. Diagnostics, navigation and hover. |
| **mason.nvim** | Installs language servers, formatters and linters into Neovim's own data directory, so nothing has to be installed system-wide. |
| **mason-lspconfig.nvim** | Bridges mason's package names to lspconfig's server names. |
| **mason-tool-installer.nvim** | Installs everything in the `servers` table plus a hand-listed set of formatters and linters. Adding a server is enough to get it installed; a new formatter must also be added to that list. |
| **conform.nvim** | Formatting, on demand via `<leader>f`. Owns formatting exclusively — where a server would also format, that is disabled server-side so there is exactly one formatter per filetype. Save-time formatting is off unless `<leader>uf` enables it. |
| **nvim-lint** | Standalone linters for rules no language server covers (ruff, rubocop, stylelint). Runs on save. JS/TS linting comes from the `eslint` server instead, not from here. |

## How the language tooling divides up

The three pieces are deliberately kept from overlapping:

- **LSP** — diagnostics, navigation, hover, code actions.
- **conform** — formatting, and nothing else.
- **nvim-lint** — only lint rules the LSP does not already report.

Language coverage, including deliberate gaps and the reasons for them, is tracked in the comment
block above the `LspAttach` autocmd in `init.lua`.

## Things intentionally not installed

- **No file tree** — oil.nvim plus fzf-lua covers it.
- **No framework** (LazyVim, NvChad, AstroNvim) — every setting is written out and commented.
- **No statusline framework** — mini.statusline is enough.
- **No bufferline/tabline** — `öb`/`äb` and `<leader><leader>` cover buffer switching.
- **No flash.nvim** — its `s` prefix would collide with mini.surround.
- **No snippet engine** — blink expands through Neovim's built-in `vim.snippet`. LuaSnip was
  removed once it turned out to be a third layer doing the same job.
- **No mini.move / mini.splitjoin / mini.bracketed** — enabled once and removed again. Each added
  mappings that are easy to forget you have, and leaving them out keeps everything under `ö`/`ä`
  coming from Neovim, gitsigns or treesitter alone. Each is one `setup()` call to restore.
- **No terminal plugin** — `:terminal` runs PowerShell 7, configured via `'shell'` in `init.lua`.
- **No Erlang LSP** — `erlang_ls` is unmaintained and `elp` ships no native Windows binary.
  Treesitter still highlights `.erl` files.
