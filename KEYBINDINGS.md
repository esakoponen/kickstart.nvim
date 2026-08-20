# Keybindings

Leader is `<Space>`. Press `<Space>` and wait to see the menu (which-key), or `<leader>sk` to
search all mappings. `<leader>?` lists only what the current buffer added.

## Start here: eight keys

You do not need the rest of this file to work. These cover most of a session, and everything else
can be found with which-key when you need it.

1. `-` open the directory, `<C-c>` back to the file
2. `<leader>sf` find a file · `<leader><leader>` switch buffer
3. `<leader>sg` grep the project
4. `K` hover · `grd` definition · `grr` references
5. `öd` / `äd` previous / next diagnostic
6. `<leader>f` format the buffer
7. `äh` / `öh` next / previous git hunk · `<leader>gp` preview it · `<leader>gs` stage it
8. `<leader>` and **wait** — the menu shows everything else

## Nordic layout: ö and ä

`[` and `]` need AltGr on a Finnish keyboard, so **`ö` = `[`** and **`ä` = `]`** in normal, visual
and operator-pending mode. Everything below written as `[x`/`]x` is typed `öx`/`äx`. Press `ö` or
`ä` and wait to browse the whole set. As a rule, lowercase steps and **uppercase jumps to the
first/last**.

| Pair | Moves between | From |
|---|---|---|
| `öd` `äd` | diagnostics (`öD` `äD` = first/last) | Neovim |
| `öq` `äq` / `öl` `äl` | quickfix / location list entries | Neovim |
| `öb` `äb` | buffers | Neovim |
| `öa` `äa` / `öt` `ät` | arglist files / tags | Neovim |
| `ö<Space>` `ä<Space>` | add a blank line above / below | Neovim |
| `öh` `äh` | git hunks (`öH` `äH` = first/last) | gitsigns |
| `öm` `äm` | function starts (`öM` `äM` = ends) | treesitter |
| `ön` `än` (visual) | select prev/next syntax node (`öN` `äN` = sibling) | Neovim |

Everything under `ö`/`ä` comes from Neovim itself, gitsigns or treesitter — there is no fourth
source to remember.

Other Nordic substitutes: **`Q`** replays macro `q` (avoids AltGr `@`).

## Files, search, buffers

| Key | Action |
|---|---|
| `-` | open parent directory in oil (editable buffer; `:w` applies renames/deletes) |
| `<leader>sf` / `<leader>s.` | find files / recent files |
| `<leader>sg` / `<leader>sw` | live grep / grep word under cursor |
| `<leader>ss` / `<leader>sS` | symbol names — functions, classes — in this file / in the project |
| `<leader>st` | symbol names from treesitter, no language server needed |
| `<leader><leader>` | switch buffer |
| `<leader>sh` / `<leader>sk` | search help / search keymaps |
| `<leader>sd` / `<leader>sr` | workspace diagnostics / resume last picker |
| `<leader>sp` | list all fzf-lua pickers |
| `<leader>bd` / `<leader>bD` | close buffer keeping layout / discard changes |
| `<leader>w` | write buffer |

Three different questions: `<leader>sf` searches **file names**, `<leader>ss`/`<leader>sS` search
**symbol names**, `<leader>sg` searches **file contents**.

## Configuration — `<leader>r`

`r` as in vim**rc**. Everything that edits or maintains this configuration lives here, so the whole
set can be browsed by pressing `<leader>r` and reading the menu.

| Key | Action |
|---|---|
| `<leader>rc` | edit init.lua |
| `<leader>rv` | edit init.lua in a vertical split (opens right) |
| `<leader>rr` | write and re-source the current buffer — apply an edit without restarting |
| `<leader>rd` | open the config directory in oil |
| `<leader>rp` | update plugins (`:packupdate`) |
| `<leader>rm` | Mason — servers, formatters, linters |
| `<leader>rh` | `:checkhealth` |

`rd` exists because `-` opens the parent of the *current file*, which only reaches the config
directory when a config file is already open. `rd` gets there from any project.

The natural loop: `rv` to open it beside your work, edit, `rr` to apply.

## Windows and movement

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | move to the split left/down/up/right |
| `<C-d>` / `<C-u>` | half page down/up, recentred |
| `n` / `N` | next/prev search hit, recentred, folds opened |
| `;` / `,` | repeat the last `äm`-style jump **or** the last `f`/`t`, forward/backward |
| arrow keys | disabled in normal mode (prints a reminder) |
| `<Esc>` | clear search highlight |

Inside an oil buffer `<C-h>` and `<C-l>` belong to oil, not to window movement — use `<C-w>h` and
`<C-w>l` there.

## Folds

Folds follow the syntax tree, so a fold is a real function or block. Files open unfolded. These are
all Neovim defaults, nothing is remapped.

| Key | Action |
|---|---|
| `za` | toggle the fold under the cursor |
| `zo` / `zc` | open / close it |
| `zR` / `zM` | open every fold / close every fold |
| `zj` / `zk` | move to the next / previous fold |

## Editing

| Key | Action |
|---|---|
| `J` | join lines, cursor stays put |
| `<` / `>` (visual) | shift and keep the selection, so it repeats |
| `<leader>p` (visual) | paste over selection without losing the register |
| `<leader>d` | delete into the black hole register (clipboard untouched) |
| `<leader>cw` | strip trailing whitespace from the buffer (also `:TrimWhitespace`) |
| `gcc` / `gc` (visual) | toggle comment (Neovim built-in) |

Deletes and yanks go to the **Windows clipboard**. `"0p` pastes the last *yank*, ignoring deletes.

Trailing whitespace is marked with a pastel pink block as you work — never on the line you are
typing, and not at all in insert mode. `<leader>uw` turns that marking off, `<leader>cw` removes
the whitespace itself: **`uw` to stop seeing it, `cw` to clean it.**

## Textobjects

Use with any operator: `d`, `c`, `y`, `v`. `a` = around (includes delimiters), `i` = inside.

| Object | Selects | From |
|---|---|---|
| `aF` `iF` | whole function definition / its body | treesitter |
| `aC` `iC` | class, module, struct | treesitter |
| `ao` `io` | block: `if`, `case`, `for`, `while` | treesitter |
| `af` `if` | function **call**, e.g. `foo(bar)` | mini.ai |
| `aa` `ia` | argument | mini.ai |
| `at` `it` | HTML/XML tag | mini.ai |
| `a)` `i'` `a"` … | brackets and quotes | mini.ai |
| `ih` | git hunk (`dih` discards a change) | gitsigns |
| `a?` `i?` | prompts for custom delimiters | mini.ai |

Surround: `sa` add (`saiw)` = wrap word in parens), `sd` delete (`sd'`), `sr` replace (`sr'"`),
`sf`/`sF` find, `sh` highlight.

## LSP

Mostly Neovim built-ins, so they work the same in any modern config.

| Key | Action |
|---|---|
| `K` / `<C-s>` (insert) | hover documentation / signature help |
| `grd` / `gri` / `grr` / `grt` | go to definition / implementation / references / type |
| `grn` / `gra` / `grx` | rename / code action / run codelens |
| `gO` | document symbols into the location list — `<leader>ss` is the picker version |
| `<leader>e` / `<leader>q` | diagnostic float / diagnostics to location list |
| `<leader>f` | format buffer (also visual) |
| `<leader>ca` / `<leader>cA` | swap this parameter with the next / previous |

The symbol under the cursor gets underlined after a moment, showing its other references.

## Git

`<leader>g` holds two different scopes. Knowing which is which saves confusion:

**Repo-wide pickers** — always available:

| Key | Action |
|---|---|
| `<leader>gg` | changed files (stage/unstage from the picker) |
| `<leader>gl` / `<leader>gL` | log for the repo / for this file |
| `<leader>gB` | branches |

**Actions on the change under the cursor** — only in files git tracks, so they simply will not
appear in an untracked file or a scratch buffer:

| Key | Action |
|---|---|
| `<leader>gs` / `<leader>gr` | stage / discard the hunk (visual: exactly the selection) |
| `<leader>gS` / `<leader>gR` | stage / discard the whole buffer |
| `<leader>gp` / `<leader>gb` | preview hunk inline / blame this line |
| `<leader>gd` | diff this file in a split |

`<leader>gs` toggles: run it on a staged hunk to unstage. Note `<leader>gd` is git **d**iff, while
`grd` is **g**o to definition — different `d`, different prefix.

## Completion (insert mode)

| Key | Action |
|---|---|
| `<C-y>` | accept the selected item |
| `<C-n>` / `<C-p>` | next / previous item |
| `<C-space>` | show menu, then toggle documentation |
| `<Tab>` / `<S-Tab>` | jump between placeholders of an expanded snippet |
| `<C-b>` / `<C-f>` | scroll the documentation window |
| `<C-e>` | cancel |

The documentation window does not open by itself — `<C-space>` shows it when wanted. Snippets come
from friendly-snippets through Neovim's own `vim.snippet`; there is no separate snippet engine.
`<Tab>` also completes in `:` and `/`.

## Terminal, toggles and sessions

| Key | Action |
|---|---|
| `<leader>t` | floating terminal, toggles; PowerShell 7, keeps running when hidden |
| `<Esc><Esc>` (terminal) | leave terminal mode — then `<leader>t` hides the window |
| `<leader>up` / `<leader>uP` | markdown preview in the browser: start / stop |
| `<leader>uc` | change colorscheme (live preview, remembered across restarts) |
| `<leader>uz` | zen mode |
| `<leader>uw` | trailing-whitespace marking, the pink blocks (**on** by default) |
| `<leader>ul` | all invisible characters — tabs, trailing dots, nbsp (off by default, this window) |
| `<leader>uf` | format on save (off by default, session only) |
| `<leader>uh` / `<leader>ub` | inlay hints (this buffer only) / inline git blame |
| `<leader>Ss` / `<leader>Sl` / `<leader>Sf` | restore session: this directory / last / pick |
| `<leader>Sd` | do not save the session on exit |

`uw` and `ul` overlap but are not the same: **`uw`** marks only trailing whitespace, in pink, and is
on; **`ul`** reveals every invisible character including tabs and non-breaking spaces, and is off.

`<leader>up` serves the current file and reloads it as you type. Mermaid diagrams and KaTeX maths
render, and both ship inside the plugin, so neither needs a network connection.

Sessions are **saved automatically on quit**, per directory and git branch; restoring is manual.

## Why the keys are where they are

**Most of what you press is Neovim's own.** `grd grr grn gra grx gO K`, the whole `ö`/`ä` bracket
family, every `z*` fold key, `gcc`. That knowledge transfers to any config, any tutorial and
`:help` — it is not specific to this setup.

**The prefixes are namespaces**, not arbitrary letters:

| Prefix | Means |
|---|---|
| `<leader>s` | **s**earch for something |
| `<leader>g` | **g**it |
| `<leader>u` | **u**I toggle |
| `<leader>b` | **b**uffer |
| `<leader>c` | **c**ode |
| `<leader>r` | **r**c / config |
| `<leader>S` | **S**ession |

**Known rough edges, kept on purpose.** These are real, and changing them would cost more than it
saves once the keys are learned:

- `<leader>s` and `<leader>S` differ only by Shift — Search versus Session.
- Shift carries meaning in several pairs: `bd`/`bD`, `gl`/`gL`, `gs`/`gS`, `ss`/`sS`, `ca`/`cA`.
  This follows LazyVim's convention, so it is at least a common one.
- `<leader>e` and `<leader>q` are inherited from kickstart; the letters describe the action less
  well than the rest, and `q` produces a **loc**ation list rather than a quickfix list.

## Reserved for future use

Decided in advance so that adding a plugin later never forces a key you already know to move.

| Reserved | For |
|---|---|
| `<leader>r` | **configuration only** — see the section above; the letters are already fixed |
| `<leader>x` | diagnostics and lists, e.g. trouble.nvim (`<leader>xx`, `<leader>xq`) |
| `<leader>T` | test runner — keeps `<leader>t` as the terminal |
| `<leader>a` | AI / agent tooling |
| `<leader>n` | notes or notifications |
| `<leader>m` | marks, or make / build |

Still free beyond those: `<leader>` + `h i j k o v y z` and most capitals.

Features removed earlier left their keys free, so re-adding them needs no remapping: `<A-hjkl>`
(mini.move), `gS` (mini.splitjoin), and the unused `öX`/`äX` letters (mini.bracketed).

**The rule when a convention collides with an existing key: add, do not move.** If a new plugin
wants `<leader>xx` and something similar already lives on `<leader>q`, bind the new key as well and
keep both. One extra line, and nothing already learned breaks.
