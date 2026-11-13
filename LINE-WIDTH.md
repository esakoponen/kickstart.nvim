# Line width and the ruler

A faint vertical line, Neovim's `'colorcolumn'`, marks where lines should end: text belongs to the
left of it. It is set in the "Ruler" block of `init.lua` (search for `[[ Ruler`).

## Where the line is

| Buffer | Line drawn at column | Width limit | Where the limit comes from |
|---|---|---|---|
| Code and text (the default) | 81 | 80 | Unix/Linux convention; see the history below |
| Markdown | 81 | 80 | the default, set as `textwidth=80` in `init.lua` so `gw` wraps there |
| Commit messages | 73 | 72 | git convention; Neovim's gitcommit ftplugin sets `textwidth=72` |
| Email | 73 | 72 | Neovim's mail ftplugin sets `textwidth=72` |
| Rust | 101 | 100 | rustfmt's `max_width`; Neovim's rust ftplugin sets `textwidth=100` |
| help, oil, quickfix, terminals, pickers, debug panels | none | — | not files you write |

The rule: a buffer whose filetype sets `'textwidth'` gets the line one column past it
(`colorcolumn=+1`); every other file gets column 81. So the line always marks the first column
that is *too far*.

The colour is the colorscheme's background moved 6% towards its text colour, recomputed whenever
the colorscheme changes. It stays a hint in light and dark schemes alike; in tokyonight-night it
is fainter than the cursor line.

Changing it:

    :setlocal colorcolumn=101                 " move the line, this window only
    :setlocal textwidth=100 colorcolumn=+1    " give this file a limit, and the line follows it

The column is picked when a buffer is shown in a window, so setting `textwidth` alone on a file
that had no limit does not move the line; set both, as above.

To change the default for good, edit the `'81'` in the Ruler block of `init.lua`.

Commit messages are also *wrapped* at their limit: `<leader>f` in a commit message rewraps the body
to 72 columns (see the Git section of [KEYBINDINGS.md](KEYBINDINGS.md)).

Markdown is wrapped on request, never while typing: `gwip` rewraps the paragraph under the cursor
to 80 columns, and `gw` on a visual selection rewraps those lines. Do not run it over the whole
file (`gggwG`): it joins every run of non-blank lines, so tables and fenced code blocks collapse
into single lines.

## Where the numbers come from

| Width | Origin | Still used for |
|---|---|---|
| **80** | IBM's 80-column punch card (1928). Terminals copied the width: IBM 3270, DEC VT52 and VT100 were all 80×24, and Unix grew up on them. | Code. The Linux kernel's coding style: "The preferred limit on the length of a single line is 80 columns." Its `checkpatch.pl` only warns past 100 since 2020, but 80 remains the stated preference. |
| **79** | One under 80. | Python code (PEP 8). |
| **78** | RFC 5322 (email): lines "SHOULD be no more than 78 characters, excluding the CRLF". | Email; Vim's own help files (`textwidth=78`). |
| **75** | The kernel's `submitting-patches.rst`: "The body of the explanation, line wrapped at 75 columns". | Linux kernel commit messages. |
| **72** | Fortran on punch cards: columns 73–80 held sequence numbers, so code ended at column 72. | Git commit message bodies: `git log` indents the body by 4, so 72 + 4 still fits in 80. Plain-text email, leaving room for `> ` quoting. Python docstrings and comments (PEP 8). |
| **70** | Emacs's default `fill-column`. | Prose filled in Emacs. |
| **100** | Wider screens and longer identifiers. | rustfmt's default `max_width`; the kernel's checkpatch warning threshold since 2020. |

80 is the default here because it is the Unix convention and the kernel's preference for code.
The narrower widths are for text that something else indents or quotes later — `git log`,
email replies — which is why commit messages use 72.
