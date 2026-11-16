# Pickers: fzf-lua, harpoon, fzf.vim and Telescope

fzf-lua, the finder this configuration uses, and three well-known plugins
weighed against it. For each, what it was made for, the thinking behind it, and
how to use it well. Then how each fits the daily workflow, and one requirement
in particular:

> Find a commit by its hash, list the files it changed, and preview each file's
> diff.

The last section compares their keys.

**Status:** analysis only. Nothing is installed or changed; the one proposed
change is under [The commit requirement](#the-commit-requirement). Researched on
2026-11-15 from each project's README and source, and from the installed
fzf-lua.

## Verdict

| Plugin | What it is | For this configuration |
|---|---|---|
| **fzf-lua** | A finder over fzf, in Lua, for Neovim only | **Selected**, and in use: files, grep, symbols, buffers, git and help from one plugin |
| **harpoon** (`harpoon2` branch) | A short, hand-picked file list per project, each file one key away | Not needed: Neovim's argument list, saved in every session, does the same job |
| **fzf.vim** | The original fzf integration for Vim, in Vimscript | Not needed: fzf-lua is its Lua successor and is already installed |
| **Telescope** | A fuzzy-finder framework in Lua: finders, sorters, previewers, actions | Not needed: it would be a second finder doing fzf-lua's job |

For the commit requirement, none of the three beats what is installed:
`<leader>gl`, then `ctrl-d`, lists a commit's files with each file's diff in the
preview. One snag makes it awkward, and a change of about ten lines in
`init.lua` removes it. The change was tested, but not applied; see
[The commit requirement](#the-commit-requirement).

## fzf-lua

[ibhagwan/fzf-lua](https://github.com/ibhagwan/fzf-lua): the picker this
configuration uses, and the one selected.

### Original purpose

"Improved fzf.vim written in lua", in the repository's own description. Its
README credits fzf.vim, and nvim-fzf, a Lua library for running fzf from Neovim,
"which started this endeavour". From fzf.vim's set of commands it grew to cover
most of what Neovim keeps as a list: files, grep, buffers, LSP symbols,
references and calls, diagnostics, treesitter, git, help, keymaps, marks,
registers, the quickfix list and nvim-dap.

### Philosophy

- **fzf does the filtering**, as in fzf.vim: in its own process, fast on large
  inputs, with fzf's search syntax.
- **"As plug and play as possible with sane defaults"** (README). An empty
  `setup({})` gives every picker with its preview and keys, and that is exactly
  what this configuration calls.
- **Neovim only, in Lua.** Each picker is a Lua function that takes a table of
  options; the same options work on the command line, as in
  `:FzfLua files cwd=~/.config`. Previews are Neovim buffers, highlighted by
  treesitter.
- **Profiles instead of rewriting.** One argument to `setup` copies another
  finder's look and keys: `fzf-vim`, `telescope`, `fzf-native`, `ivy` and
  others.
- **Coming back is part of the design.** In the default profile `Esc` hides
  the list rather than closing it, so `resume` restores the query, the cursor
  and the marked entries.
- **Few hard dependencies:** Neovim 0.9 or later, and fzf newer than 0.36. rg
  and fd are optional, and icons are optional too.

### Using it effectively

- **Find the pickers.** `<leader>sp` lists all of them, `:FzfLua <Tab>`
  completes their names, and `F1` inside any list shows its keys. The keys
  bound here are in [Quick keys](#quick-keys).
- **The search syntax** (fzf's). Words separated by spaces must all match, in
  any order. `'word` matches exactly, `^` anchors to the start of the line, `$`
  to the end, and `!` excludes.
- **Grep, then narrow.** In `<leader>sg` the query is a ripgrep regex, run again
  on every keystroke. Text after ` -- ` filters the files by glob:
  `setup -- *.lua` searches Lua files only, and `setup -- !*_spec.rb` leaves
  spec files out.
  `ctrl-g` switches to fuzzy filtering of the results found so far, and back.
- **Many results to work through.** `tab` marks entries and `alt-a` marks them
  all; Enter with entries marked, or `alt-q`, sends them to the quickfix list,
  to step through with `]q`.
- **Leave and come back.** `Esc` hides the list; `<leader>sr` reopens it as it
  was. Useful when one look at the code answers a question and the search goes
  on.
- **The preview.** `shift-down` / `shift-up` scroll it a page at a time, `F4`
  hides it and `F2` makes the list full screen, which helps on a shared screen.
- **Git from the list.** In `<leader>gg`, `left` stages the file and `right`
  unstages it. In `<leader>gl`, `ctrl-d` lists a commit's files and `ctrl-y`
  copies its hash. Some git keys change the repository; see Fit, below.
- **Coming from fzf.vim.** Its commands do not exist here: `:BLines` fails with
  `E492: Not an editor command`. What replaces each:

  | fzf.vim | Here |
  |---|---|
  | `:Files` | `<leader>sf` |
  | `:Rg` / `:RG` | `:FzfLua grep` (asks for a pattern) / `<leader>sg` |
  | `:BLines` / `:Lines` | `:FzfLua blines` / `:FzfLua lines` |
  | `:Buffers` | `<leader><leader>` |
  | `:History` / `:History:` | `<leader>s.` / `:FzfLua command_history` |
  | `:GFiles?` | `<leader>gg` |
  | `:Commits` / `:BCommits` | `<leader>gl` / `<leader>gL` |
  | `:Helptags` / `:Maps` | `<leader>sh` / `<leader>sk` |

  `:FzfLua setup_fzfvim_cmds` creates fzf.vim's command names, running fzf-lua,
  for the rest of the session. It is not called at startup here, so that each
  picker has one name.

### Fit with this configuration

- **Installed and in use.** 21 keys call it, and so do two pieces of
  `init.lua`: oil's drive list at a drive root (`fzf_exec`), and live-preview's
  picker setting. Its options are the defaults.
- **The same on Arch, WSL and Windows.** It needs fzf newer than 0.36: WSL has
  0.44.1 and Windows 0.74.1. Its Windows README advises fzf 0.52.1 or later on
  Windows, which is met. The commit workflow below was tested on WSL and
  Windows.
- **No Lua dependencies** and no build step: no plenary.nvim, no compiled
  sorter.
- **Activity:** pushes to the repository in November 2026; the installed copy
  is from 2026-07-26, and `<leader>rp` updates it.
- **Keys that change the repository** (the ones to avoid in a live review):
  - `<leader>gl`: Enter checks out the commit, after a Yes/No prompt;
  - `<leader>gB`: Enter switches to the branch with no prompt; `ctrl-x`
    deletes the branch after a Yes/No prompt; `ctrl-a` creates a branch named
    by the query;
  - `<leader>gg`: `ctrl-x` discards a file's changes after a Yes/No prompt
    (`git checkout HEAD --`, or `git clean -f` for an untracked file).
- **Finnish layout:** its keys are Ctrl, Alt and function keys, and none needs
  AltGr. `alt-Q` is Alt+Shift+q.

## harpoon

[ThePrimeagen/harpoon, branch `harpoon2`](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)

### Original purpose

"Getting you where you want with the fewest keystrokes." The README names the
problem: in any codebase you keep returning to a small set of files, and a fuzzy
finder, `:bnext` / `:bprev` and the alternate file all cost too many keys. A
second problem it addresses is running project commands, or reaching persistent
terminals, with a single key.

### Philosophy

- **A short list chosen by hand**, not a history. You decide which three or four
  files matter for the task in hand, and each gets a fixed slot.
- **The list is a buffer.** The quick menu shows it as lines of text: reorder
  the lines to change the slots, delete a line to drop a file.
- **Per project and persistent.** Lists are keyed by the working directory and
  saved to disk.
- **Hooks, not features.** Harpoon 2 generalises the idea into any number of
  named lists, each with its own add, select and display functions, so a list
  can hold commands or terminals as well as files. From the README: "I don't
  want Harpoon *solving* specific issues, I want it to create the proper hooks
  to solve any problem."
- **Your keys, not the author's.** The README's keys are "designed with dvorak
  in mind" and meant to be replaced.

### Using it effectively

- Call `harpoon:setup()`. It is required, because it creates the autocmds.
- Bind four kinds of key:
  - one to add the current file: `harpoon:list():add()`;
  - one for the quick menu: `harpoon.ui:toggle_quick_menu(harpoon:list())`;
  - four to jump to slots 1–4: `harpoon:list():select(n)`;
  - optionally, previous and next: `harpoon:list():prev()` and `:next()`.
- Keep the list short and in priority order, so slot 1 is always the task's main
  file. Reorder it by editing the menu as text.
- `harpoon:extend()` adds split and tab keys inside the menu, and
  `extensions.builtins.highlight_current_file()` marks where you are.

### Fit with this configuration

- **Installed from a branch.** `master` is the frozen Harpoon 1. The README says
  `harpoon2` "will become `master` within the next few months"; it has not, and
  its last commit was on 2025-10-31. It needs plenary.nvim, which nothing else
  here uses.
- **Its suggested keys collide.** Here `<C-h>` moves to the left window, `<C-s>`
  splits in oil and shows signature help in insert mode, `<C-e>` is Neovim's
  scroll, and `<leader>a` is reserved for AI tooling. If harpoon ever comes in,
  `<leader>m`, reserved for marks, is its natural home.
- **Neovim already has the job covered:**
  - **The argument list** is a hand-picked, ordered list of files:
    - `:argadd` (`:arga`) adds the current file and `:args` shows the list;
    - `]a` / `[a` step through it, `[A` / `]A` go to the first and last file,
      and `:2argu` opens the second;
    - `:FzfLua args` lists it with previews;
    - `:mksession`, which persistence.nvim uses, saves the list, so it comes
      back per directory and branch with `<leader>Ss`. Tested: the session file
      holds `$argadd` lines.
  - **Global marks:** `mA` sets one and `'A` jumps to it (`'` is an unshifted
    key on the Finnish layout; `` ` `` is a dead key). They remember the line
    as well, but they are global, not per project.
  - `<leader><leader>` (buffers), `<C-^>` (the alternate file) and `<leader>s.`
    (recent files).
- **For live reviews**, a hand-ordered list is genuinely useful: the files of a
  change, in the order you want to present them. `:args a.lua b.lua c.lua`, then
  `]a`, does exactly that.

## fzf.vim

[junegunn/fzf.vim](https://github.com/junegunn/fzf.vim)

### Original purpose

fzf is a command-line program; its main repository ships only a basic Vim
wrapper (`fzf#run`, `fzf#wrap`), leaving users to write their own commands.
fzf.vim adds the ready-made commands that users of other finder plugins expect:
files, git files, buffers, ripgrep, lines, tags, marks, history, commits,
commands, maps and help tags.

### Philosophy

- **fzf does the filtering**, in its own process and asynchronously: in the
  README's words, "orders of magnitude faster than similar Vim plugins" on large
  inputs.
- **Thin Vimscript.** Every command is a small function over `fzf#run`. You make
  variations by calling those functions with your own options; the README builds
  `ProjectFiles` and `GGrep` that way.
- **Vim and Neovim alike.**

### Using it effectively

These commands exist only where fzf.vim is installed; it is not installed here.
[fzf-lua](#fzf-lua) lists what replaces each.

- Learn the core commands:
  - `:Files`, `:GFiles?` (changed files), `:Buffers` and `:History`;
  - `:Rg` and `:BLines` for searching text;
  - `:Commits` and `:BCommits` for history;
  - `:History:` (command history) and `:Helptags`.
- Inside any list:
  - `CTRL-T`, `CTRL-X` and `CTRL-V` open the item in a tab, split or vertical
    split;
  - `ALT-ENTER` inserts it into the buffer (a path, a line or a hash);
  - `CTRL-O` opens it but keeps the list open (fzf 0.74.4 or later, not on
    Windows);
  - `TAB` multi-selects; in `:Rg`, `:Lines` and `:Tags` that fills the
    quickfix list.
- The bang form of a command (`:Rg!`) runs it full screen.
- One dictionary holds the settings: `g:fzf_vim`, covering the preview window,
  per-command fzf options and the `git log` format for commits.
- Write your own commands with `fzf#vim#files`, `fzf#vim#grep` and
  `fzf#vim#with_preview`.

### Fit with this configuration

- **fzf-lua is its successor in Lua.** fzf-lua's README credits fzf.vim, and
  nvim-fzf "which started this endeavour". It ships a `fzf-vim` profile that
  copies fzf.vim's look, and `:FzfLua setup_fzfvim_cmds` creates fzf.vim's
  `:Files` and `:Rg` commands. Installing fzf.vim would duplicate every picker
  already here.
- **It needs fzf 0.54 or newer.** WSL's fzf from apt is 0.44.1. Windows has
  0.74.1, and Arch tracks the latest.
- **`:Commits` needs vim-fugitive**, and its source switches the preview off on
  Windows (`with_preview = !s:is_win`).
- **It is Vimscript configured through global variables**, where the rest of
  this configuration is Lua.

## Telescope

[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

### Original purpose

"A highly extendable fuzzy finder over lists", written in Lua for Neovim only,
"built on the latest awesome features from neovim core" and "centered around
modularity".

### Philosophy

- **Swappable parts.** Every picker is built from four pieces:
  - a *finder* produces the entries;
  - a *sorter* ranks them against the query;
  - a *previewer* shows the selected entry;
  - *actions* run on the selection.
- **Configuration at two levels.** Settings apply to every picker
  (`setup({ defaults = … })`) or to one (`pickers = { find_files = … }`).
  Themes (`dropdown`, `ivy`, `cursor`) change the layout.
- **An ecosystem.** Extensions add pickers (`:Telescope <extension>
  <picker>`), and many plugins ship one.
- **Everything inside Neovim.** Sorting runs in Lua; the README "strongly
  suggests" the native fzf sorter, built from C, for speed. Previews are Neovim
  buffers with treesitter highlighting.

### Using it effectively

- Run `:checkhealth telescope` after installing; `:Telescope` lists every
  picker.
- Bind the core pickers: `find_files`, `live_grep`, `buffers`, `help_tags`,
  `oldfiles`, `lsp_references`, `diagnostics` and `resume`.
- Inside a picker:
  - `<C-/>` (insert mode) or `?` (normal mode) lists the picker's actions;
  - `<C-x>`, `<C-v>` and `<C-t>` open the entry in a split, vertical split or
    tab;
  - `<Tab>` multi-selects, and `<C-q>` sends the results to the quickfix list;
  - after `<Esc>`, `j`, `k`, `gg` and `G` move as in a buffer.
- `builtin.resume` reopens the last picker with its query and selection, and
  `builtin.pickers` lists the recent ones.
- Install telescope-fzf-native, for sorting speed and fzf's query syntax.
- Write your own pickers from `pickers.new`, `finders`, `previewers` and
  `actions`; the README points to its `developers.md` for this.

### Fit with this configuration

- **It does fzf-lua's job.** 21 keys and two pieces of `init.lua` code use
  fzf-lua: an `fzf_exec` list, and live-preview's picker setting. Switching
  means rewriting them; keeping both means two finders.
- **Dependencies:**
  - plenary.nvim;
  - for good sorting, telescope-fzf-native, built with `make`, which needs a C
    toolchain on Windows as well;
  - Neovim 0.11.7 or later, built with LuaJIT. Only the latest stable release
    and nightly are supported.
- **Activity:** latest release v0.2.1 (2025-12-31), and pushes to the
  repository in November 2026.
- **Its git pickers change the repository.** In `git_commits`, Enter runs
  `git checkout` with no confirmation. `<C-r>m`, `<C-r>s` and `<C-r>h` reset
  (mixed, soft, hard) after a `[Y/n]` prompt whose default is Yes. In a live
  review, one wrong key changes the working tree.
- **Finnish layout:** `/` is Shift+7, so `<C-/>` may not reach Neovim at all;
  `?` in normal mode works.

## Side by side

fzf-lua is included as the baseline: it is what the configuration uses now.

| | harpoon | fzf.vim | Telescope | fzf-lua (installed) |
|---|---|---|---|---|
| Kind | file list on keys | finder over fzf | finder in Lua | finder over fzf |
| Language | Lua | Vimscript | Lua | Lua |
| Needs | plenary.nvim | fzf ≥ 0.54 and fzf's Vim plugin; fugitive for commits | plenary.nvim; fzf-native (a C build) advised | fzf, rg, fd (installed) |
| Arch / WSL / Windows | yes / yes / yes | yes / no (fzf 0.44) / no commit preview | yes / yes / C build for fzf-native | yes / yes / yes |
| Last activity | 2025-10 | 2026-11 | 2026-11 | 2026-11; installed copy 2026-07 |
| Overlaps with | argument list, marks, buffers | fzf-lua, entirely | fzf-lua, entirely | — |
| Search commits by hash | — | `:Commits` | `git_commits` | `<leader>gl` |
| Commit → its files | — | Enter opens the commit in fugitive | not built in: a custom picker | `ctrl-d` |
| Each file's diff in a preview | — | no; fugitive's buffers instead | not built in | yes |
| Enter on a commit | — | opens it in fugitive | `git checkout`, no prompt | `git checkout`, after a Yes/No prompt |
| Work to meet the requirement | — | two plugins (fzf.vim, fugitive) | a plugin, plenary, and a picker of roughly 30 lines (estimate) | about 10 lines (tested) |
| Clashes with keys here | `<C-h>`, `<C-s>`, `<C-e>`, `<leader>a` | none forced: commands | `<C-/>` hard to type | — |

Against [PRINCIPLES.md](PRINCIPLES.md)'s test for every change:

| Test | harpoon | fzf.vim | Telescope | fzf-lua |
|---|---|---|---|---|
| Focus | quiet: keys only | quiet | quiet | quiet: opens only on a key, and `Esc` hides it |
| Context | helps: the task's files one key away | same as fzf-lua | same as fzf-lua | helps: every match previewed in its code, and `<leader>sr` returns to the list |
| Big picture | no | same as fzf-lua | same as fzf-lua | helps: project symbols, call hierarchy and the git log |
| Mastery | neutral | neutral | neutral | neutral: it finds, it does not write |
| Minimal | fails: the argument list does it | fails: duplicates fzf-lua | fails: duplicates fzf-lua | passes: one plugin, no Lua dependencies, does the work of several |

The three alternatives fail on the minimal test, and fzf-lua passes it. Of the
three, harpoon is the only one that would add something new; that something is
already built into Neovim.

## The commit requirement

> A list that searches through git commits based on commit id; when I select
> the commit, it shows the files changed in that commit in a list that I can
> use to select and preview changes (diff) per file.

### Today, with no change

1. `<leader>gl` lists the current branch's commits, newest first, as
   `hash (age) subject <author>`. The preview shows the selected commit's
   `git show`.
2. Type the start of a hash: `945b79a` narrowed 407 commits to one. `^945b`
   anchors the search to the start of each line, so only hashes match.
3. `ctrl-d` lists the files that commit changed
   (`git diff --name-only <hash>~ <hash>`).
4. **`ctrl-u`** clears the search box. Without it the file list looks empty
   (`0/2`): the hash is still the query, and no file name contains it.
5. `ctrl-n` / `ctrl-p` (or the arrow keys) move between files, and the preview
   shows each file's diff in that commit. `shift-down` / `shift-up` scroll the
   preview, and `F4` hides it.
6. From the file list:
   - Enter opens the file as it is in your working copy;
   - `ctrl-d` lists that file's hunks;
   - `ctrl-q` returns to the commit list;
   - `<leader>sr` reopens the last list after it has closed.

How it was tested: Neovim with this configuration, driven in a terminal on
2026-11-15. WSL (fzf 0.44.1) was checked screen by screen, Windows (fzf 0.74.1)
from its screen output. Both behaved the same.

### Snags

| Snag | Effect |
|---|---|
| The hash stays in the search box after `ctrl-d` | The file list looks empty until `ctrl-u` |
| Enter on a commit runs `git checkout`, after a Yes/No prompt | The obvious key does the risky thing; a stray Enter and `y` in a live session detaches HEAD |
| The list shows short hashes only | A full 40-character hash pasted from a pull request matches nothing (`0/407`); paste only as many characters as the list shows (7 here) |
| `git log` runs without `--all` | Commits on other branches are not listed |
| Enter on a file opens the working copy | Not the file as it was in that commit |
| `<hash>~` on the repository's first commit | That commit has no parent, so its file list fails |

### Proposed change: Enter lists the files

Not applied: it needs approval and its own commit. In `init.lua`, the empty
`require('fzf-lua').setup({})` (line 465) becomes:

```lua
-- <leader>gl: Enter on a commit lists the files it changed, each file's diff in the preview.
-- It replaces fzf-lua's default Enter, git checkout, which stays a terminal command.
require('fzf-lua').setup({
  git = { commits = { actions = {
    ['enter'] = function(selected)
      local hash = selected[1] and selected[1]:match('^%S+')
      if hash then require('fzf-lua').git_diff({ ref = hash, ref1 = hash .. '~', query = '' }) end
    end,
  } } },
})
```

Tested as a prototype on WSL and Windows, loaded on top of this configuration:

- Enter on a commit opens its file list with an empty search box and the first
  file's diff in the preview.
- `ctrl-q` returns to the log, and Enter there lists files again. No checkout
  prompt appears anywhere.
- `ctrl-d` and `ctrl-y` (copy the hash) keep working.
- Back in the log, the cursor starts at the top, not on the commit you came
  from.

The cost:

- **init.lua:** 9 lines more.
- **Documentation:** a KEYBINDINGS.md row, and a new cheatsheet version from
  `cheatsheet/keybindings.json`, as AGENTS.md requires.

### Smaller additions, not tested

- **Any hash, full or short.** `:FzfLua git_diff ref=<hash> ref1=<hash>~` lists
  the files of any commit without going through the log.
  [FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md) proposes a key for it.
- **Other branches.** A `cmd` for `git.commits` with `--all` added to fzf-lua's
  default `git log` command.
- **Syntax colours inside the diffs.** fzf-lua pipes previews through delta
  whenever `delta` is on the PATH; it checks with `vim.fn.executable`. No
  machine has delta now. It is `git-delta` on Arch and Ubuntu, and
  `winget install dandavison.delta` on Windows.

### Where this leads

[FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md) goes further: it highlights a
commit's lines in the full file and tours every change across files.
[FEATURE-COMMIT-VIEW.md](FEATURE-COMMIT-VIEW.md) shows a whole commit as one
buffer. Both start from the same commit picker, so the change above is a first
step for either.

## Sources

- fzf-lua: the installed copy:
  - `README.md` (usage, profiles, credits), `README-Win.md` and `OPTIONS.md`
    (`grep.rg_glob`);
  - `lua/fzf-lua/defaults.lua`: the `keymap` table, `actions.files`, and the
    `git` and `grep` pickers;
  - `actions.lua`: `git_checkout`, `git_switch`, `git_reset` and
    `git_branch_del`;
  - `profiles/default.lua` and `profiles/hide.lua`;
  - `make_entry.lua` (`glob_parse`).
- fzf: `fzf --man` (fzf 0.74.1), its default key bindings.
- harpoon: the
  [README on `harpoon2`](https://github.com/ThePrimeagen/harpoon/blob/harpoon2/README.md)
  and `lua/harpoon/buffer.lua` (the quick menu's keys).
- fzf.vim: the [README](https://github.com/junegunn/fzf.vim/blob/master/README.md)
  and `autoload/fzf/vim.vim` (`s:commits`, `s:commits_sink`, `:Buffers`).
- Telescope: the
  [README](https://github.com/nvim-telescope/telescope.nvim/blob/master/README.md),
  `lua/telescope/mappings.lua`, `lua/telescope/builtin/__git.lua`,
  `lua/telescope/builtin/__internal.lua` (`buffers`) and
  `lua/telescope/actions/init.lua` (`git_checkout`,
  `git_checkout_current_buffer`, `git_reset_branch`).
- Activity dates: GitHub's API, 2026-11-15.

## Quick keys

The keys of the four, side by side. fzf-lua's column is this configuration as
it is. harpoon and Telescope bind no keys of their own outside their lists:
their columns show the keys their READMEs suggest, or the picker's name, which
runs as `:Telescope <name>`. fzf.vim has commands only. Inside a list, every
column is the plugin's defaults; fzf.vim and fzf-lua also get fzf's own.

| Action | harpoon | fzf.vim | Telescope | fzf-lua (here) |
|---|---|---|---|---|
| **Open a list** | | | | |
| Files | — | `:Files` | `<leader>ff` | `<leader>sf` |
| Grep the project | — | `:Rg`, `:RG` | `<leader>fg` | `<leader>sg` |
| The word under the cursor | — | — | `grep_string` | `<leader>sw` |
| Lines of this file | — | `:BLines` | `current_buffer_fuzzy_find` | `:FzfLua blines` |
| Buffers | — | `:Buffers` | `<leader>fb` | `<leader><leader>` |
| Recent files | — | `:History` | `oldfiles` | `<leader>s.` |
| Help | — | `:Helptags` | `<leader>fh` | `<leader>sh` |
| Keymaps | — | `:Maps` | `keymaps` | `<leader>sk` |
| Changed files | — | `:GFiles?` | `git_status` | `<leader>gg` |
| Commits | — | `:Commits` | `git_commits` | `<leader>gl` |
| This file's commits | — | `:BCommits` | `git_bcommits` | `<leader>gL` |
| Branches | — | — | `git_branches` | `<leader>gB` |
| Reopen the last list | — | — | `resume` | `<leader>sr` |
| Every picker | — | — | `:Telescope` | `<leader>sp` |
| **A hand-picked file list** | | | | **built in: the argument list** |
| Add the current file | `<leader>a` | — | — | `:argadd` |
| Show the list | `<C-e>` | — | — | `:args`, `:FzfLua args` |
| Go to file 1, 2, 3, 4 | `<C-h>`, `<C-t>`, `<C-n>`, `<C-s>` | — | — | `:1argu` … `:4argu` |
| Previous / next file | `<C-S-P>` / `<C-S-N>` | — | — | `[a` / `]a` |
| **Inside a list** | | | | |
| Next / previous entry | `j` / `k` (the menu is a buffer) | `ctrl-j` / `ctrl-k`, `ctrl-n` / `ctrl-p` | `<C-n>` / `<C-p>`; `j` / `k` in normal mode | `ctrl-j` / `ctrl-k`, `ctrl-n` / `ctrl-p` |
| Open | `<CR>` | `enter` | `<CR>` | `enter` |
| Open in a split | `<C-x>`¹ | `ctrl-x` | `<C-x>` | `ctrl-s` |
| Open in a vertical split | `<C-v>`¹ | `ctrl-v` | `<C-v>` | `ctrl-v` |
| Open in a tab | `<C-t>`¹ | `ctrl-t` | `<C-t>` | `ctrl-t` |
| Mark entries | — | `tab` / `shift-tab` | `<Tab>` / `<S-Tab>` | `tab` / `shift-tab` |
| Mark all | — | `alt-a` (`:Rg`, `:Ag`) | — | `alt-a` (toggles) |
| To the quickfix list | — | `enter` with entries marked (`:Rg`, `:Lines`, `:Tags`) | `<C-q>` all, `<M-q>` the marked | `alt-q` the marked; `enter` with entries marked |
| Insert into the buffer | — | `alt-enter` | — | — |
| Open, keeping the list open | — | `ctrl-o` (fzf 0.74.4+, not on Windows) | — | — (`Esc`, then `<leader>sr`) |
| Close a buffer (buffer list) | — | `ctrl-alt-x` | `<M-d>` | `ctrl-x` |
| Clear the query | — | `ctrl-u` | — (`<C-u>` scrolls the preview) | `ctrl-u` |
| Scroll the preview | — | `shift-up` / `shift-down` (a line) | `<C-u>` / `<C-d>` | `shift-up` / `shift-down` (a page) |
| Show or hide the preview | — | `ctrl-/` | — | `F4` |
| Full screen | — | the command with `!`: `:Rg!` | — | `F2` |
| List the keys | — | — | `<C-/>`; `?` in normal mode | `F1` |
| Close | `q`, `<Esc>` | `esc`, `ctrl-c` | `<C-c>`; `<Esc>` in normal mode | `esc` hides it for `<leader>sr`; `alt-esc` closes |
| **Git lists** | | | | |
| Enter on a commit | — | opens it in fugitive | `git checkout`, no prompt | `git checkout`, after Yes/No |
| A commit's files, each diff in the preview | — | — | — | `ctrl-d` |
| Copy the hash | — | `ctrl-y` | — | `ctrl-y` |
| Enter on one of this file's commits | — | opens the commit in fugitive | `git checkout <commit> -- <file>`, no prompt | opens the file as it was in that commit |
| Diff this file against the commit | — | `ctrl-d` | — | — |
| Reset the branch to a commit | — | — | `<C-r>m`, `<C-r>s`, `<C-r>h` (mixed, soft, hard), after `[Y/n]` | — |
| Stage / unstage a file | — | — | `<Tab>` toggles | `left` / `right` |
| Discard a file's changes | — | — | — | `ctrl-x`, after Yes/No |
| Enter on a branch | — | — | `git checkout`, no prompt | `git switch`, no prompt |
| Create / delete a branch | — | — | `<C-a>` / `<C-d>` | `ctrl-a` (named by the query) / `ctrl-x`, after Yes/No |

¹ Only after adding them with `harpoon:extend()`, as its README shows.

The git keys that check out, switch, reset, stage, discard, or create or delete
a branch change the repository or the working tree. In a live review, those are
the ones to avoid.
