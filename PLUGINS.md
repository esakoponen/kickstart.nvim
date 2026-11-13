# Plugins

Every plugin is declared in the single `vim.pack.add({...})` call in `init.lua`. `vim.pack` is
Neovim's built-in package manager — there is no lazy.nvim or framework layer here. It records the
installed revisions in `nvim-pack-lock.json`, which is deliberately not committed: each machine
keeps its own, and running `:packupdate` on each brings them level.

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
| **persistence.nvim** | Records which files were open, keyed by directory and git branch, so a project reopens where it was left. Saves on quit; restoring is manual. Turned off when git starts Neovim for `mergetool` or `difftool`, so those runs never overwrite the real session. |

## Git

| Plugin | Purpose |
|---|---|
| **gitsigns.nvim** | Change markers in the sign column (`+` `~` `_`), hunk jumps `öh`/`äh`, and per-hunk stage, reset, inline preview and blame under `<leader>g`, plus the `ih` hunk textobject. Buffer-local, so it only appears in files git tracks. |

The repo-wide git pickers (`<leader>gg`, `gl`, `gL`, `gB`) come from fzf-lua. The merge view's extras
are `init.lua` code, not a plugin: in `git mergetool`'s LOCAL and REMOTE panes, each differing line
ends with the 8-character hash and author of its commit, and `<leader>gb` opens that commit.

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
| **mini.cursorword** | Underlines other occurrences of the word under the cursor. Purely textual, so it also works in files with no language server. |
| **mini.trailspace** | Marks trailing whitespace with a pastel pink block, never on the line being typed. `<leader>uw` turns the marking off, `<leader>cw` or `:TrimWhitespace` strips it. |

Also loaded, though not a plugin: Neovim's own optional **undotree** package (`nvim.undotree`,
switched on with `:packadd`). `<leader>uu` opens it.

## Completion

| Plugin | Purpose |
|---|---|
| **blink.cmp** | Completion engine. Draws candidates from the LSP, open buffers, filesystem paths and snippets, and also completes in `:` and `/`. Accept with `<C-y>`; the documentation window opens only on `<C-space>`. |
| **friendly-snippets** | A library of ready-made snippets in VS Code format. Pure data — blink finds it on the runtimepath by itself and expands through Neovim's own `vim.snippet`, so there is no snippet engine to install or configure. |

## Language tooling

| Plugin | Purpose |
|---|---|
| **nvim-lspconfig** | Server configurations (paths, root markers, default settings) that `vim.lsp.config`/`vim.lsp.enable` then apply. Diagnostics, navigation and hover. |
| **mason.nvim** | Installs language servers, formatters, linters and debug adapters into Neovim's own data directory, so nothing has to be installed system-wide. |
| **mason-lspconfig.nvim** | Bridges mason's package names to lspconfig's server names. |
| **mason-tool-installer.nvim** | Installs everything in the `servers` table plus a hand-listed set of formatters, linters and debug adapters. Adding a server is enough to get it installed; a new formatter or adapter must also be added to that list. |
| **conform.nvim** | Formatting, on demand via `<leader>f`. Owns formatting exclusively — where a server would also format, that is disabled server-side so there is exactly one formatter per filetype. Save-time formatting is off unless `<leader>uf` enables it. |
| **nvim-lint** | Standalone linters for rules no language server covers (ruff, rubocop, stylelint). Runs on save. JS/TS linting comes from the `eslint` server instead, not from here. |

## Debugging

| Plugin | Purpose |
|---|---|
| **nvim-dap** | The debugger client (Debug Adapter Protocol): breakpoints, stepping, a REPL. F5/F9–F12 and `<leader>D`. Also reads a project's `.vscode/launch.json`. |
| **mason-nvim-dap.nvim** | Gives each debug adapter Mason installs (debugpy, codelldb, netcoredbg, and elixir-ls's debugger) a ready-made adapter definition and launch configuration, so `init.lua` holds no per-language tables. Two handlers fill its gaps: Elixir's adapter name, and starting debugpy attached on Windows. |
| **nvim-dap-view** | The debugger UI: one panel for variables, watches, call stack, breakpoints and the REPL, opening and closing with the session (`<leader>Dv` toggles it). Also shows variable values inline while paused. Pinned to `1.*`. Needs a Neovim nightly recent enough to have the `SessionWritePre` event. |

## Tests

| Plugin | Purpose |
|---|---|
| **vim-test** | Runs the nearest test, the file or the suite with the language's own test command, in a terminal split that is reused between runs. Chosen over neotest because it needs no adapter plugin per language: one plugin covers every language here, Erlang and C# included. |

## Markdown preview

| Plugin | Purpose |
|---|---|
| **live-preview.nvim** | Previews the current markdown or HTML file in the browser (`<leader>up`, `<leader>uP` stops), updating as you type and following the cursor. Renders Mermaid diagrams and KaTeX maths from assets bundled in the plugin, so it works offline. Its server is pure Lua: no Node or Deno. On WSL the page opens in the Windows browser through `wslview`. Why a browser rather than the terminal: [MARKDOWN-PREVIEW.md](MARKDOWN-PREVIEW.md). |

## How the language tooling divides up

The three pieces are deliberately kept from overlapping:

- **LSP** — diagnostics, navigation, hover, code actions.
- **conform** — formatting, and nothing else.
- **nvim-lint** — only lint rules the LSP does not already report.

Language coverage, including deliberate gaps and the reasons for them, is tracked in the comment
block above the `LspAttach` autocmd in `init.lua`.

## Fun

| Plugin | Purpose |
|---|---|
| **donut.nvim** | A spinning ASCII donut on `:Donut`; any keypress dismisses it. Its `timeout` is set to 0 here. The README calls that option milliseconds, but the source counts once per second, so the default 300 would make it a screensaver that claims every window after five minutes idle. Set it back to 300 if that is what you want. |

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
- **No terminal plugin** — `<leader>t` is a small floating terminal written in `init.lua`. It runs
  bash on Linux and WSL, and PowerShell 7 on Windows, set through `'shell'` wherever `pwsh` is
  installed.
- **No Erlang LSP on native Windows** — `erlang_ls` is unmaintained and `elp` ships no Windows
  binary. Linux and WSL get `elp`; on Windows, treesitter still highlights `.erl` files.
- **No in-terminal markdown renderer** — render-markdown.nvim and markview.nvim cannot draw Mermaid
  diagrams; see [MARKDOWN-PREVIEW.md](MARKDOWN-PREVIEW.md).
