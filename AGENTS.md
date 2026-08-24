# AGENTS.md

ALL COMMITS AUTHORED BY DEVELOPER - DO NOT SIGN GIT COMMITS.

## What this is

A personal Neovim config, derived from kickstart.nvim. Keep a single `init.lua`.

Target runtime is Neovim 0.13.* (`nvim --version` to confirm).
Version matters: config may use APIs that do not exist on older versions.
Check installed runtime before assuming an API's availability; deprecation
moves fast on dev builds; check changes against neovim's online documentation
and plugin documentation.

## Verification loop

Verify changes with these instead:

```bash
# Syntax/parse only — does not execute, safe and instant
nvim --headless --clean -c "lua local f,e=loadfile('init.lua'); print(f and 'PARSE OK' or e)" -c "qa"

# Full load with plugins; surfaces runtime errors and deprecation warnings
nvim --headless -c "lua print('LOAD OK')" -c "qa"

# Exercise a specific autocmd/keymap after loading
nvim --headless -c "lua vim.cmd('normal! yy'); print('OK')" -c "qa"
```

A silent `LOAD OK` with nothing before it is the pass condition - deprecation
warnings print to stderr *above* the marker and are easy to miss if you only
check the tail.

Inspect effective state (built-in defaults included) before adding a mapping,
don't redefine something Neovim already provides:

```bash
nvim --headless --clean -c "redir! > out.txt | silent map gr | redir END" -c "qa"
```

Useful in-editor checks: `:checkhealth`, `:checkhealth vim.deprecated`, `:Mason`, `:packupdate`.

## init.lua

`init.lua` is ordered as a load sequence:

1. Leader keys — must precede plugin loading or mappings bind to the wrong leader.
2. Options → keymaps → autocmds — plain Vim settings, no plugin dependency.
3. `vim.pack.add({...})` — a single call listing every plugin. Neovim's native package manager (0.12+).
4. Per-plugin `require(...).setup()` blocks — each immediately followed by its own keymaps, so a plugin and its bindings read as one unit.
5. LSP → mason → conform → lint — the toolchain pipeline (see below).

Two `PackChanged`/`FileType` autocmds drive treesitter: parsers install
asynchronously on first encounter with a filetype, then attach. A parser
missing from the `ts_parsers` list still works — it is fetched on demand.

### LSP toolchain

The three pieces divide responsibility and should not be made to overlap:

- `servers` table → `vim.lsp.config`/`vim.lsp.enable` — diagnostics, navigation, hover.
- conform.nvim — formatting, on demand via `<leader>f`. Where an LSP would also format, formatting is disabled server-side (see `lua_ls`'s `on_init`) so there is exactly one formatter per filetype.
- nvim-lint — only for lint rules no LSP covers. JS/TS lint comes from the `eslint` *server*, not nvim-lint.

`mason-tool-installer` receives `vim.tbl_keys(servers)` plus a hand-listed
set of formatters/linters, so adding a server to the `servers` table is
sufficient to get it installed — but a new formatter or linter must also
be appended to that `vim.list_extend` list.

Language support status, including deliberate gaps and why (e.g. Erlang has
no usable native-Windows LSP), is tracked in the comment block above the
`LspAttach` autocmd. Keep it current when changing language support.

## Conventions

Nordic (Finnish) keyboard is the design constraint.

-  `[` and `]` require AltGr, so `ö` and `ä` are remapped to them with
   `remap = true` (which is what lets plugin-defined pairs like `]c` resolve
   through). When adding any bracket-prefixed mapping, express it as `[x`/`]x`
   and let the remap do the work — never bind `öx` directly.
   Avoid `@`, `{`, `}`, `|`, `\`, `~` and `<C-]>` in new mappings;
   all need AltGr.

Do not redefine Neovim's built-in LSP mappings.

- `grn gra gri grr grt grx gO` are global defaults and `K`/`<C-s>` are set on
  attach. `grd` is defined here because it is the one gap.

Constraints set by the repo owner:

- Single `init.lua`, kept under 1000 lines. Do not split into `lua/` modules.
- Every setting or setting group gets a one-line explanation in init.lua.
- One git commit per independent change. Do not batch unrelated edits;
  do not edit ahead of approval.

## Untracked files

`nvim-pack-lock.json` is `vim.pack`'s lockfile. Upstream recommends
version-controlling it; it currently is not. Do not commit.
