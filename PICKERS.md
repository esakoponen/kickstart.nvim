# Pickers: harpoon, fzf.vim and Telescope

Three well-known plugins, weighed against this configuration, which already has
one finder: fzf-lua. For each, what it was made for, the thinking behind it, and
how to use it well. Then how each fits the daily workflow, and one requirement
in particular:

> Find a commit by its hash, list the files it changed, and preview each file's
> diff.

**Status:** analysis only. Nothing is installed or changed; the one proposed
change is at the end. Researched on 2026-11-15 from each project's README and
source, and from the installed fzf-lua.

## Verdict

| Plugin | What it is | For this configuration |
|---|---|---|
| **harpoon** (`harpoon2` branch) | A short, hand-picked file list per project, each file one key away | Not needed: Neovim's argument list, saved in every session, does the same job |
| **fzf.vim** | The original fzf integration for Vim, in Vimscript | Not needed: fzf-lua is its Lua successor and is already installed |
| **Telescope** | A fuzzy-finder framework in Lua: finders, sorters, previewers, actions | Not needed: it would be a second finder doing fzf-lua's job |

For the commit requirement, none of the three beats what is installed:
`<leader>gl`, then `ctrl-d`, lists a commit's files with each file's diff in the
preview. One snag makes it awkward, and a change of about ten lines in
`init.lua` removes it. The change was tested, but not applied; see
[The commit requirement](#the-commit-requirement).

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
| Last activity | 2025-10 | 2026-11 | 2026-11 | installed copy 2026-07 |
| Overlaps with | argument list, marks, buffers | fzf-lua, entirely | fzf-lua, entirely | — |
| Search commits by hash | — | `:Commits` | `git_commits` | `<leader>gl` |
| Commit → its files | — | Enter opens the commit in fugitive | not built in: a custom picker | `ctrl-d` |
| Each file's diff in a preview | — | no; fugitive's buffers instead | not built in | yes |
| Enter on a commit | — | opens it in fugitive | `git checkout`, no prompt | `git checkout`, after a Yes/No prompt |
| Work to meet the requirement | — | two plugins (fzf.vim, fugitive) | a plugin, plenary, and a picker of roughly 30 lines (estimate) | about 10 lines (tested) |
| Clashes with keys here | `<C-h>`, `<C-s>`, `<C-e>`, `<leader>a` | none forced: commands | `<C-/>` hard to type | — |

Against [PRINCIPLES.md](PRINCIPLES.md)'s test for every change:

| Test | harpoon | fzf.vim | Telescope |
|---|---|---|---|
| Focus | quiet: keys only | quiet | quiet |
| Context | helps: the task's files one key away | same as fzf-lua | same as fzf-lua |
| Big picture | no | same as fzf-lua | same as fzf-lua |
| Mastery | neutral | neutral | neutral |
| Minimal | fails: the argument list does it | fails: duplicates fzf-lua | fails: duplicates fzf-lua |

All three fail on the minimal test. Of the three, harpoon is the only one that
would add something new; that something is already built into Neovim.

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

- **init.lua:** 9 lines more, which takes it from 1158 to 1167 of its 1200.
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

- harpoon: the
  [README on `harpoon2`](https://github.com/ThePrimeagen/harpoon/blob/harpoon2/README.md).
- fzf.vim: the [README](https://github.com/junegunn/fzf.vim/blob/master/README.md)
  and `autoload/fzf/vim.vim` (`s:commits`, `s:commits_sink`).
- Telescope: the
  [README](https://github.com/nvim-telescope/telescope.nvim/blob/master/README.md),
  `lua/telescope/builtin/__git.lua` and `lua/telescope/actions/init.lua`
  (`git_checkout`, `git_reset_branch`).
- fzf-lua: the installed source, `lua/fzf-lua/defaults.lua` (`git.commits`,
  `git.diff`, the `fzf` keymap) and `actions.lua` (`git_checkout`), and its
  README (profiles, credits).
- Activity dates: GitHub's API, 2026-11-15.
