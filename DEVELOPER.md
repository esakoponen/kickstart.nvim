# Everyday development

How this configuration handles four everyday tasks: lists of places to visit (the quickfix list),
errors while typing Python, the files a branch changed, and the commit behind a line. The examples
use a FastAPI backend in WSL, `~/code/aalto-ai/aalto-ai-assistant-backend`; the counts and results
quoted come from running the commands there on 2026-11-16, with this configuration.

## The quickfix list

### What it is

A list of places: file, line, column and a line of text for each. A tool writes the list, and you
walk through it. Search results, linter errors, language-server references and the files a branch
changed all fit the same list, so the same keys move through all of them.

There is one quickfix list for the whole editor. Neovim keeps the last ten, so a new search does not
lose the previous list. Each window can also have its own list, the location list; `<leader>q` puts
the current buffer's diagnostics there, so they do not replace the quickfix list you are working
through.

### How it is filled

| Source                           | How                                                                | In the backend                                                                       |
| -------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| The language server's references | `grr` on a name                                                    | on `create_app` in `app/main.py`: 9 places, from its definition to the test fixtures |
| A search                         | `:grep -w "async def" app`                                         | 520 matches                                                                          |
| Any fzf-lua list                 | select lines with `Tab`, or all of them with `alt-a`, then `alt-q` | `<leader>sg`, type, `alt-a`, `alt-q`                                                 |
| A linter or type checker         | `:compiler <tool>`, then `:make`                                   | ruff and mypy, below                                                                 |
| Diagnostics                      | `:lua vim.diagnostic.setqflist()`                                  | every diagnostic in the open buffers                                                 |
| Uncommitted changes              | `:Gitsigns setqflist all`                                          | one entry per changed hunk, in every changed file                                    |
| Any command's output             | `:cgetexpr systemlist('<command>')`                                | the files a branch changed, below                                                    |

Without a selection, `alt-q` sends only the line under the cursor. `alt-Q` sends to the location
list instead.

`:grep` runs ripgrep with `-uu`, which also searches hidden and git-ignored files. Name a directory,
`app` here, or the search also goes through `.venv` and the caches.

`:make` runs the program in `'makeprg'` and reads its output with `'errorformat'`; `:compiler` sets
both for a known tool. Neovim ships compilers for ruff, mypy, pyright, pylint and pytest. Two need
adjusting for this project:

```vim
" ruff: the compiler adds --preview, which turns on ruff's unfinished rules. With it,
" 5 findings the project's own `ruff check` never reports; without it, none.
:let g:ruff_makeprg_params = ''
:compiler ruff
:make

" mypy: the compiler's default is --strict on the current directory. The project runs
" `mypy app` with its own settings from pyproject.toml, inside the virtualenv.
:compiler mypy
:setlocal makeprg=uv\ run\ mypy\ --show-column-numbers\ app
:make
```

On the branch checked out when this was written, mypy took 2.8 seconds and found nothing ("Success:
no issues found in 194 source files").

### Working through it

| Key                          | Does                                                                                                                                    |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `<leader>xq`                 | show or hide the quickfix window                                                                                                        |
| `äq` / `öq`                  | next / previous entry; opens the file at that place, whether the window is open or not                                                  |
| `äQ` / `öQ`                  | last / first entry                                                                                                                      |
| `j` / `k`, `Enter`           | in the window: move, and open the entry in the window you came from; the list stays open                                                |
| `:cc 5`                      | entry 5                                                                                                                                 |
| `:colder` / `:cnewer`        | the previous / next of the last ten lists; `:chistory` lists them                                                                       |
| `:FzfLua quickfix`           | search the entries by typing                                                                                                            |
| `:Cfilter /text/`            | keep only the entries whose file or text matches; `:Cfilter! /tests/` drops them instead; `:Lfilter` does the same to the location list |
| `:cdo s/old/new/g \| update` | run a command at every entry, and save                                                                                                  |
| `:cfdo <command>`            | run a command once in every file of the list                                                                                            |

Habits that make it pay off:

- **One list per task.** Fill it, then walk it with `äq` until the task is done. The window does
  not need to stay open.
- **Narrow it first.** `:Cfilter` leaves only what matters, such as `:Cfilter! /tests/` to drop the
  tests.
- **Rename symbols with `grn`, other text with `:cdo`.** The language server renames a function and
  its callers safely; strings, comments and settings keys are what `:grep` + `:cdo` is for.
- **Go back.** After a new search, `:colder` returns the list you were working through.

## Errors and warnings while typing Python

Three tools check Python, at three different moments:

| Tool                      | Checks                             | When the result appears                        |
| ------------------------- | ---------------------------------- | ---------------------------------------------- |
| pyright (language server) | types, names, imports              | when you leave insert mode, after every change |
| ruff (through nvim-lint)  | the lint rules in `pyproject.toml` | when you save                                  |
| mypy                      | types, with the project's settings | only when you run it: `:make` as above         |

Pyright analyses the file as you type, but Neovim shows the new results when you leave insert mode
(`update_in_insert` is off), so a half-typed line does not flash red.

Where results appear:

- a letter in the sign column, and the message at the end of the line;
- `<leader>e`: the full messages for the cursor's line, in a floating window (nothing happens on a
  line without any);
- `äd` / `öd`: the next / previous diagnostic;
- `<leader>sd`: every diagnostic in the project, as a list to search;
- `<leader>q`: this buffer's diagnostics in the location list;
- the counts in the status line.

### Pyright needs the project's virtualenv

Pyright finds the project's packages only through the Python it is given. Started from a plain
shell, it uses the system's Python 3.12, which has none of them: `app/main.py` then shows three
errors, starting with `Import "fastapi" could not be resolved`. With the project's `.venv` (Python
3.14, with every dependency) it shows none.

Activate the virtualenv before starting Neovim:

```sh
cd ~/code/aalto-ai/aalto-ai-assistant-backend
source .venv/bin/activate
nvim
```

Or, in a Neovim that is already open:

```vim
:LspPyrightSetPythonPath .venv/bin/python
```

### Possible changes, not made

- **Ruff as you type**: ruff's own language server would show lint results after each change
  instead of after each save. It would replace the nvim-lint entry for Python, so ruff does not
  report everything twice.

## The files a branch changed

Two ways, for different jobs. The examples use `feat/app-version`, one commit and 9 files since it
left `dev`.

### As a quickfix list: work through the files

```vim
:cgetexpr map(systemlist('git diff --name-only --diff-filter=d dev...feat/app-version'), {_, f -> f .. ':1: changed'}) | copen
```

The list stays until you replace it: move with `j` / `k` in its window and open a file with
`Enter`, or step through the files from anywhere with `äq` / `öq`. `<leader>xq` hides and shows it.

- `dev...feat/app-version` (three dots) is what the branch changed since it left `dev`; commits that
  reached `dev` later stay out. For the branch you are on, `dev...` is enough: on
  `feat/hosted-code-interpreter` it lists 48 files.
- `--diff-filter=d` leaves out deleted files, which have nothing to open.
- `:1: changed` turns each name into `file:line: text`, the shape the quickfix list reads.
- The files open as they are in your working tree. To read a branch's own version, check it out
  first.

### As a picker: review the changes

```vim
:exe 'FzfLua git_diff ref=feat/app-version ref1=' .. trim(system('git merge-base dev feat/app-version'))
```

The same 9 files, each with its diff in the preview. `Enter` opens a file and `ctrl-d` lists its
hunks. Opening a file closes the picker; `<leader>sr` brings it back where you left it. fzf-lua does
not accept `dev...feat/app-version` itself, hence the merge base: the commit where the branch left
`dev`.

Use the picker to read what changed, and the quickfix list to visit each file in turn.
[FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md) proposes a key for this.

## The commit behind a line or a file

| Want                                 | Key or command                                    | Shows                                                                                                                                                                                |
| ------------------------------------ | ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| The commit behind the cursor's line  | `<leader>gb`                                      | a floating window: hash, author, date and the full message                                                                                                                           |
| The author of each line as you move  | `<leader>ub`                                      | at the end of the cursor's line: author, how long ago, the summary (no hash)                                                                                                         |
| The whole file, line by line         | `:Gitsigns blame`                                 | a split beside the file, scrolling with it: hash, author and date for each line. In it, `s` shows the line's commit and `r` blames again as of that commit; `Enter` lists these keys |
| The same, as a list to search        | `:FzfLua git_blame`                               | `Enter` jumps to the line, `ctrl-y` copies the hash; the preview shows the commit                                                                                                    |
| The file's history                   | `<leader>gL`                                      | the commits that changed the file, newest first, with each change in the preview. `ctrl-y` copies the hash; `Enter` opens the file as it was in that commit                          |
| The repository's history             | `<leader>gl`                                      | every commit. `ctrl-y` copies the hash and `ctrl-d` lists its files. `Enter` checks the commit out after asking, so answer No unless you mean it                                     |
| The commit behind a conflicting line | `<leader>gb` in the side panes of `git mergetool` | the full commit, in a floating window                                                                                                                                                |

`:!git log -1 --oneline -- %` prints the hash and summary of the last commit that changed the
current file.
