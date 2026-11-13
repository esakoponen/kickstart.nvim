# Feature proposal: the files a commit changed

**Status:** proposal, not implemented. One of four:
[FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md) ·
[FEATURE-COMMIT-VIEW.md](FEATURE-COMMIT-VIEW.md) ·
[FEATURE-SEMANTIC-SEARCH.md](FEATURE-SEMANTIC-SEARCH.md) ·
[FEATURE-EXPLAIN-LINE.md](FEATURE-EXPLAIN-LINE.md)

## The requirement

All four tools serve live code review. In a Teams meeting with a shared screen, the developer jumps
to the relevant code, moves through it, and walks the team through what changed. Finding and
stepping through the changes has to be fast, easy and intuitive, so the audience follows the
explanation, not the tooling.

For this feature that means:

- **"What I changed" is often more than one commit**: a branch's commits since `main`, or work not
  yet committed. The input should take a range as well as a single hash.
- **One key moves to the next changed block**, continuing into the next file when a file is done, so
  a review is one walk from start to end.
- **The highlights must survive a compressed video stream** at a large font: clearly stronger than
  the ruler's faint 6% tint.
- **Little else on screen.** Signs, inline blame and diagnostics compete for attention; zen mode
  (`<leader>uz`) already narrows the view.

## Description

Given a git commit hash, list every file that commit changed. Picking a file opens it with each line
the commit added or changed highlighted, so the commit's work can be read in the context of the whole
file rather than as a diff.

1. **Start from a hash**: typed or pasted, the word under the cursor, or a commit picked from the log.
2. **A picker lists the changed files**, with their status (added, modified, deleted, renamed) and a
   diff preview of each.
3. **Enter opens the file** with the commit's lines highlighted, and a key steps from one changed
   block to the next.

"Changed" means the lines the commit added or modified, compared with its parent. Lines it deleted no
longer exist in the file, so at most they can be marked where they used to be.

## Additional questions

1. Where does the hash usually come from: pasted from a pull request or ticket, the merge view's
   `<leader>gb` popup, `git log` in a terminal, or the log picker (`<leader>gl`)?
2. Which version of the file should open?
   - **The file as it was in that commit**: read-only, and the highlights are exact.
   - **Your working copy**: editable, but later commits may have moved or removed the commit's lines,
     so only the lines that survive can be highlighted.
3. Should deleted lines be shown (a marker, or the removed text as virtual lines), or only added and
   changed lines?
4. Highlight style: a full-line background, sign-column marks, or both? It must not be confused with
   gitsigns' own signs, which mark *uncommitted* changes.
5. How long should the highlights stay: until the buffer closes, until a toggle key, or until
   another commit is picked?
6. Merge commits: compare with the first parent (what the merge brought in), or leave them out?
7. Is the main use reading history, or reviewing someone else's commit?

### For live review sessions

8. What does "what I changed" usually cover: one commit, every commit on a branch since `main` (a
   pull request), or uncommitted work as well?
9. In a review, do you go through the files in the order git lists them, or in an order you choose,
   such as the core change first and the tests last?
10. How do you share: the whole terminal window, at what font size, with which colour scheme? The
    highlights have to stay visible after Teams compresses the video.
11. Should one key switch on a presentation mode that hides gitsigns' signs, inline blame,
    diagnostics and the ruler, and switch it all back afterwards?

## Similar tooling

| Tool | What it already does | What it lacks for this feature |
|---|---|---|
| **fzf-lua** `git_commits`, `ctrl-d` (installed, `<leader>gl`) | `ctrl-d` on a commit lists the files it changed (`git diff --name-only <hash>~ <hash>`) with a diff preview. `ctrl-d` on a file then lists that file's hunks. Enter opens the working copy. | No highlights once the file is open. The commit has to be found in the log; a hash cannot be typed. Enter on a commit (not `ctrl-d`) runs `git checkout`. |
| **fzf-lua** `git_diff` / `git_hunks` (installed, no key) | `:FzfLua git_diff ref=<hash> ref1=<hash>~` gives the same file list for any hash. `:FzfLua git_diff ref=main` lists every file that differs from `main`, uncommitted work included. | Same as above. Compares with `main` as it is now, not with the point where the branch left it. |
| **gitsigns** (installed) | `:Gitsigns change_base <hash>~` marks every line that differs from the commit's parent. `:Gitsigns show <hash>` opens the file as it was in the commit. `:Gitsigns diffthis <hash>~` opens a split diff. | `change_base` also marks everything changed *after* the commit, and replaces the normal base until reset. |
| **gitsigns** with a branch as the base (installed) | `:Gitsigns change_base main true` makes every open file mark what differs from `main`. `äh` / `öh` then step through those changes and `<leader>gp` previews each one. `:Gitsigns reset_base true` undoes it. | Already a branch review with no new code, one file at a time. No list of the changed files; `main` as it is now, not the merge base. |
| **`vim.text.diff()`** (built into Neovim) | Returns the changed line ranges between two texts (`result_type = 'indices'`). | A building block, no UI. |
| **`git blame --porcelain`** (already used by this config's merge view) | Tells which commit last changed each line of the working copy. | A building block: highlight the lines whose commit is the hash. |
| **mini.diff** (in mini.nvim, not enabled) | `MiniDiff.set_ref_text()` shows a diff overlay against any reference text. | Would run alongside gitsigns, which already owns change signs. |
| **vim-fugitive** | `:Git difftool <hash>^!` puts every hunk of the commit into the quickfix list; `--name-only` lists the files instead. | A new plugin; quickfix entries, not highlights. |
| **diffview.nvim** | `:DiffviewOpen <hash>^!` shows a file panel and side-by-side diffs. | A new plugin, and a diff view rather than highlights. The original has had no update since June 2024; a maintained fork exists (dlyongemallo/diffview.nvim). |
| **git** itself | `git show --stat <hash>`, `git diff-tree -r --name-status <hash>`. | Text output only. |

**Takeaway:** fzf-lua already produces the file list, and gitsigns can already mark a branch's
changes. The missing pieces are highlights for exactly one commit (or range) once a file is open, and
one key that walks through every change across files.

## Further design questions

1. **Entry points and keys.** A new action in the `<leader>gl` picker, a command such as
   `:CommitFiles <hash>`, and a key that prompts for a hash with the word under the cursor as the
   default. `<leader>gc` is free.
2. **Picker.** Reuse fzf-lua's `git_diff` with a custom Enter action, or a small `fzf_exec` list of
   our own?
3. **Finding the lines.**
   - Parse the hunk headers of `git diff -U0 <hash>~ <hash> -- <file>`.
   - Or run `vim.text.diff()` on the two versions of the file.
   - Or, for the working copy, use `git blame` and keep the lines whose commit is the hash.
4. **Drawing them.** Our own extmark namespace with a line highlight, as the merge view already does,
   or gitsigns `change_base`, or mini.diff?
5. **Stepping through them.** The location list (`äl` / `öl`), or a buffer-local pair? `äh` / `öh`
   already step through gitsigns hunks, so reusing them would clash.
6. **Clearing them.** A buffer-local key, or cleared automatically when another commit is picked.
7. **Renamed and deleted files.** Open the old path? A deleted file can only be shown from
   `<hash>~:path`.
8. **Shared code with [FEATURE-COMMIT-VIEW.md](FEATURE-COMMIT-VIEW.md).** One commit picker with two
   actions: list the files (this feature) or open the whole commit (that one).
9. **Line budget.** `init.lua` is at 1158 of its 1200 lines. Hand-written, this feature is roughly
   30–40 lines. Raise the limit, or choose designs that are mostly configuration?
10. **Windows.** The git commands are the same; check path handling in temporary revision buffers.

### For live review sessions

11. **Ranges, not only hashes.** Accept `main...HEAD` (the branch since it left `main`) and the
    working tree. `git diff --name-only main...HEAD` compares with the merge base, so commits that
    landed on `main` later stay out of the list.
12. **A tour.** One pair of keys steps through every changed block in every file, in order. For
    example, the quickfix list holding one entry per block, walked with `äq` / `öq`.
13. **Highlight colours.** Strong enough for video, for example the colour scheme's `DiffAdd` and
    `DiffChange`, rather than a subtle tint of our own.
14. **A presentation toggle.** One key that turns on zen mode and hides signs, blame and diagnostics,
    then restores them. Font size stays the terminal's job (Windows Terminal: `Ctrl+=` / `Ctrl+-`).

## Sources

- fzf-lua's pickers and default keys were read from the installed source (`lua/fzf-lua/defaults.lua`,
  `providers/git.lua`); gitsigns' commands from `lua/gitsigns/actions.lua`; `vim.text.diff()` from
  Neovim's `:help vim.text.diff()`.
- [diffview.nvim maintained fork (dlyongemallo)](https://www.libhunt.com/r/dlyongemallo/diffview.nvim)
  and its [v0.10 release notes](https://newreleases.io/project/github/dlyongemallo/diffview.nvim/release/v0.10)
