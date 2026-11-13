# Feature proposal: a commit view inside Neovim

**Status:** proposal, not implemented. One of three:
[FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md) ·
[FEATURE-COMMIT-VIEW.md](FEATURE-COMMIT-VIEW.md) ·
[FEATURE-SEMANTIC-SEARCH.md](FEATURE-SEMANTIC-SEARCH.md)

## The requirement

All three tools serve live code review. In a Teams meeting with a shared screen, the developer jumps
to the relevant code, moves through it, and walks the team through what changed. Finding and
stepping through the changes has to be fast, easy and intuitive, so the audience follows the
explanation, not the tooling.

For this feature that means:

- **Present a commit, or a whole branch**, from the message down, file by file, one key per step.
- **From any hunk, jump into the full file** to show the surrounding code, and come straight back.
- **Readable at a large font on a shared screen.** At that size a unified diff fits; side-by-side
  needs roughly twice the width.
- **Diff colours that survive video compression.**

## Description

Open a whole commit, every changed line in every file, inside Neovim, in the style of tig's or
lazygit's commit view:

- a header with the hash, author, date and full message;
- the list of changed files with their added and removed line counts;
- the diff, which can be walked file by file and hunk by hunk;
- from any diff line, a jump into that file at that line.

```
commit 3f2a9c1e  Author Name  2026-11-12 14:03
    feat: a faint ruler just past the ideal line width

 init.lua        | 31 ++++++++++++++
 KEYBINDINGS.md  |  4 ++
──────────────────────────────────────────────────
diff --git a/init.lua b/init.lua
@@ -260,6 +260,37 @@
+-- [[ Ruler: a faint vertical line just past the ideal maximum line width ]]
 ...
```

The view is for reading. Git actions from inside it (checkout, revert, cherry-pick) are out of scope
unless the questions below say otherwise.

## Additional questions

1. Which parts of tig or lazygit matter?
   - Only the view of one commit?
   - Also the log list for browsing from commit to commit (tig's main view)?
   - The branch graph?
   - Staging?
2. Read-only, or should some actions be available from the view: copy the hash, open the commit on
   GitHub, checkout, revert, cherry-pick?
3. Unified diff (one column, as in tig and `git show`), or side by side (as in diffview and VS Code)?
4. Is the real lazygit or tig, running in a Neovim floating terminal, acceptable? Or must the view be
   an ordinary Neovim buffer, searchable with `/`, yankable, and able to jump into files?
5. Where does a view start: the log picker, a hash under the cursor, the merge view's `<leader>gb`
   popup, or the file list from [FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md)?
6. A jump from a diff line: to your working copy at the matching line, or to the file as it was in the
   commit?
7. Merge commits: show the diff against the first parent?
8. Large commits with hundreds of files: fold each file's diff, and open them one at a time?

### For live review sessions

9. Will you usually present one commit, or a branch's whole change (several commits)?
10. Do you narrate commit by commit (how the change was built) or file by file (the end result)?
11. What font size and window width do you share at? That decides between unified and side-by-side
    diffs.
12. Should the view open with the commit messages as the agenda, before any diff?

## Similar tooling

| Tool | What it shows | Notes |
|---|---|---|
| **gitsigns** `:Gitsigns show_commit <hash> [vsplit\|tabnew]` (installed) | `git show` in a buffer: header, message and the full unified diff. Enter on a diff line opens that file's version at that line; Enter on the `parent` line moves to the parent commit; `<C-o>` / `<C-i>` go back and forward. | Closest to the goal with no new code. One commit only; no file list at the top and no folding per file. |
| **fzf-lua** `git_commits` preview (installed, `<leader>gl`) | Each commit's `git show` in the preview pane while browsing the log. | Preview only; you cannot move into it. |
| `git show` in a scratch buffer (built in) | `:new`, read in `git show <hash>`, `filetype=git`: diff highlighting comes for free. | Jumping into files and folding would be a few lines of Lua each. |
| **nvim.difftool** (built into Neovim 0.12 and later, `:packadd nvim.difftool`) | `:DiffTool {left} {right}` shows a side-by-side directory diff and puts the changed files in the quickfix list. Configured as git's difftool, `git difftool -d <hash>^!` shows a whole commit. | Started from the shell by git, not from a running Neovim. |
| **lazygit** or **tig** in a floating terminal (both installed in WSL) | The real tools: for example `tig show <hash>`, `tig main..HEAD` for a branch's commits, or lazygit's log and commit panels. | Nothing to build or install in Neovim: a float like `<leader>t` running the command. lazygit.nvim and snacks.nvim offer ready-made wrappers. |
| **vim-fugitive** | `:Gedit <hash>` opens the commit as a buffer listing the changed files; `=` expands a file's diff in place; Enter opens it. | The closest to tig inside an ordinary buffer. Vimscript, mature, a large new plugin. |
| **neogit** | A Magit-style git interface. Enter on a log entry opens a commit view in a vertical split. | Actively developed (commits in 2026); needs plenary.nvim; a whole git UI, more than this feature asks for. |
| **diffview.nvim** | A file panel beside side-by-side diffs: `:DiffviewOpen <hash>^!` for a commit, `:DiffviewOpen main...HEAD` for a whole branch, plus `:DiffviewFileHistory`. | The original has had no update since June 2024; a maintained fork exists (dlyongemallo/diffview.nvim). |
| **codediff.nvim** (formerly vscode-diff.nvim) | VS Code-style side-by-side diffs with character-level highlights, a file explorer panel, `:CodeDiff <rev>` and `:CodeDiff history`. | Downloads a prebuilt C binary for its diff algorithm; needs nui.nvim. |

**Takeaway:** `:Gitsigns show_commit` already shows a whole commit in a buffer. What is missing compared
with tig is the file list at the top, moving between files, and folding.

## Further design questions

1. **An ordinary buffer, or an embedded terminal program?**
   - A Neovim buffer can be searched, can use this config's keys, and can share code with the other
     two features.
   - lazygit or tig in a float gives every feature at once, with nothing to build.
2. **Building on gitsigns `show_commit`, or our own `git show` buffer?** gitsigns needs only a key;
   our own buffer could add the file list (`git show --stat`) and per-file folding.
3. **Layout.** One buffer, as tig does; a file panel plus a diff pane, as diffview does; or a tab per
   commit?
4. **Keys inside the view.** Next and previous file, next and previous hunk, open the file, back to the
   parent commit, `q` to close. With the `ö` / `ä` convention, which bracket letters are free?
   `äh` / `öh` (hunks) and `äc` / `öc` (diff changes) already exist.
5. **Folding.** One fold per file, using a fold expression on `diff --git` lines?
6. **Syntax inside hunks.** The treesitter `diff` parser colours the diff's structure (headers, added
   and removed lines), not the code in its own language. Is language highlighting inside hunks worth
   the extra configuration?
7. **One entry point shared with [FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md).** One commit
   picker with two actions.
8. **Merge commits.** `git show --first-parent`, or `-m` for a diff against each parent?
9. **Line budget.** `init.lua` is at 1150 of its 1200 lines. A key for gitsigns' `show_commit` or for
   a terminal float is about 5 lines; our own view with a file list and folding is roughly 40.
10. **Windows.** Check that lazygit and tig are available there if the embedded-terminal route is
    chosen; Windows is the secondary platform.

### For live review sessions

11. **Ranges.** One combined diff for a branch (`git diff main...HEAD`), or commit by commit
    (`git log -p main..HEAD`), or both behind one switch?
12. **Step keys.** One key for the next hunk, continuing into the next file; another for the next
    file. They should be the same keys as the tour in [FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md).
13. **Into the code and back.** Jump to the working copy at the hunk's line to show context, and
    return to the same place in the view with `<C-o>`.
14. **Colours.** The colour scheme's diff colours, or stronger ones that survive video compression at
    a large font?

## Sources

- gitsigns' `show_commit` behaviour was read from the installed source
  (`lua/gitsigns/actions/show_commit.lua`); nvim.difftool from Neovim's `:help difftool`.
- [neogit (NeogitOrg/neogit)](https://github.com/NeogitOrg/neogit)
- [diffview.nvim maintained fork (dlyongemallo)](https://www.libhunt.com/r/dlyongemallo/diffview.nvim)
- [codediff.nvim on dotfyle](https://dotfyle.com/plugins/esmuellert/codediff.nvim) and
  [on ecosyste.ms](https://awesome.ecosyste.ms/projects/github.com%2Fesmuellert%2Fcodediff.nvim)
