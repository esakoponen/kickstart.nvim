# oil.nvim

## The idea

A directory is just a **buffer**. The lines in it are the filenames. You edit those lines with
ordinary Vim commands, and **nothing happens on disk until you `:w`**.

That single fact is the whole mental model. There are no dedicated "new file" or "rename"
commands to memorise, because creating a file is typing a line and renaming one is changing a
word. Everything you already know about editing text applies to managing files.

Press `-` to open the parent directory of the current file, with the cursor on that file's name.
Press `-` again to go further up. `<CR>` enters a directory or opens a file.
To leave without opening anything, press `<C-c>`; `:b#` switches to previous
buffer as a fallback, though it leaves the oil buffer loaded rather than closing it properly.
Note the cursor returns to the top of the file rather than where you were;
`` `` `` (backtick twice) or `'"` jumps back to your last position.

## The four operations

| Goal | What you do |
|---|---|
| **Create a file** | `o` for a new line, type `name.txt`, `:w` |
| **Create a directory** | `o`, type `name/` — with the trailing slash — `:w` |
| **Rename** | edit the filename like any text (`cw`, `A`, `ciw`), `:w` |
| **Delete** | `dd` the line, `:w` |

The trailing slash is the only syntax you need to remember: `notes` makes a file, `notes/` makes a
directory.

Nested paths work in one step. Typing `src/utils/helpers.lua` creates `src/` and `src/utils/`
along the way if they do not exist. Same for `a/b/c/` as a directory chain.

## Moving and copying

This is where oil beats a file tree, and it follows from the buffer model: **`dd` is cut and `p`
is paste**, across directories.

- **Move a file elsewhere**: `dd` its line, navigate to the target directory (`-`, `<CR>`), `p`, `:w`.
- **Copy a file**: `yy`, go to the target, `p`, `:w`.
- **Duplicate in place**: `yy`, `p`, then edit the pasted name — two identical names in one
  directory is a conflict oil will refuse.
- **Move several at once**: visual-select the lines, `d`, then `p` at the destination.

Oil tracks entries by an internal id, not by name, so a `dd` in one directory followed by `p` in
another is understood as a **move** — the file keeps its contents and is not deleted and recreated.

Keeping two oil buffers open in a split makes this genuinely pleasant: `<C-w>v`, open a different
directory in each, and shuffle files between them.

## Batching, review and undo

Because it is a buffer, nothing is irreversible until you write:

- Make many changes at once — rename three files, delete two, create a directory — then `:w` once.
- On `:w`, oil lists **every** operation it is about to perform and asks you to confirm. Read this
  dialog; it is the last checkpoint.
- Changed your mind before writing? `u` undoes edits like any buffer.
- Want to discard everything? `:e!` reloads the directory from disk.

The bulk-editing consequence is the real trick: since filenames are text, **`:%s///` renames in
bulk**. To strip a prefix from every file in a directory, `:%s/^old_//` then `:w`. Visual block
mode, macros and `:g` all work the same way.

## Navigation and other keys

Oil's defaults, all active in this config. `g?` shows this list inside oil at any time.

Three ways to be reminded, in order of detail: press **`g`** for the `g`-prefixed commands,
**`<leader>?`** for every mapping this buffer added, or **`g?`** for oil's own full help.

| Key | Action |
|---|---|
| `-` | parent directory; at a drive root, pick from the drives instead |
| `_` | open the current working directory |
| `<CR>` | open file / enter directory |
| `<C-p>` | preview the entry under the cursor in a split |
| `<C-s>` / `<C-h>` / `<C-t>` | open in vertical split / horizontal split / new tab |
| `gx` | open with the system default application |
| `g.` | toggle hidden files (this config starts with them **shown**) |
| `gs` | change sort order |
| `<C-l>` | refresh the listing |
| `<C-c>` | close oil |
| `g?` | help |
| `` ` `` / `g~` | `:cd` / `:tcd` to this directory |
| `g\` | toggle the trash view |

Commands: `:Oil` opens the cwd, `:Oil /some/path` a specific directory, `:Oil --float` in a
floating window.

## Two things to watch on this setup

**Inside an oil buffer, `<C-h>` and `<C-l>` are not window navigation.** Oil's buffer-local
mappings win, so `<C-h>` opens the entry in a horizontal split and `<C-l>` refreshes the listing.
Use `<C-w>h` and `<C-w>l` to change window while in oil.

**Three of oil's keys are awkward on a Finnish layout.** `` ` `` is Shift+´ and `g~` needs
AltGr+¨, both dead keys requiring a following space; `g\` needs AltGr+`<`. The `:cd` and `:tcd`
commands do the same job as the first two. If you use them often, remapping is easy — add to the
`oil.setup()` call:

```lua
keymaps = {
  ['gc'] = { 'actions.cd', mode = 'n' },        -- instead of `
  ['gt'] = { 'actions.toggle_trash', mode = 'n' }, -- instead of g\
},
```

## Recommended change: send deletes to the Recycle Bin

`delete_to_trash` is currently `false`, which means **`dd` plus `:w` deletes permanently** — no
Recycle Bin, and `u` does not help once written. Oil supports the Windows Recycle Bin properly
(it drives it through PowerShell), so this is worth turning on:

```lua
require('oil').setup({
  view_options = { show_hidden = true },
  delete_to_trash = true,
})
```

With it enabled, `g\` browses the Recycle Bin as just another oil directory, and restoring a file
is moving it back out with `dd` and `p`.

## Tips

- `-` from a file puts the cursor **on that file**, so `-` then `dd` then `:w` deletes the file
  you were just editing.
- Oil replaces netrw, so `:e some/directory` opens oil rather than the old file explorer.
- `<C-p>` preview is a fast way to skim files without opening them properly.
- Oil can edit remote directories over SSH: `:Oil ssh://user@host/path`.
- Deleting a directory line removes it and its contents — the confirmation dialog is where you
  notice that, so read the count it reports.
- `skip_confirm_for_simple_edits = true` removes the dialog for single unambiguous operations.
  Faster, but it removes the checkpoint; not recommended until the workflow is second nature.
