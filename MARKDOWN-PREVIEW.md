# Previewing markdown

**Recommendation: use the browser preview that is already installed, live-preview.nvim.** In this
setup (WSL inside Windows Terminal, plus Arch), it is the only option that draws Mermaid diagrams
correctly. If you also want rendered markdown inside the terminal, add an in-editor renderer
alongside it (option B below), but diagrams still need the browser.

## Using it

| Key | Action |
|---|---|
| `<leader>up` | start the preview: opens the current file in the browser |
| `<leader>uP` | stop the preview |

- The page updates as you type, without saving, and scrolls to follow the cursor.
- Mermaid diagrams and KaTeX maths render. Mermaid, KaTeX and the markdown renderer ship inside
  the plugin, so no network connection is needed.
- The server listens on `127.0.0.1` only and runs only while a preview is open.
- For a side-by-side layout, snap the terminal and the browser next to each other with
  Win+← and Win+→.
- On WSL the page opens in the Windows browser through `wslview` (from the `wslu` package; see
  [LINUX-SETUP.md](LINUX-SETUP.md)). On Windows and plain Linux the system default browser opens.
- Other files: `:LivePreview pick` chooses one with the fzf-lua picker.

The setup is in `init.lua`; search for `livepreview`.

## Why a browser and not the terminal

Showing a diagram inside the terminal means showing an image, and the terminal decides which image
protocols work:

- Windows Terminal, where WSL runs, supports **Sixel** but not the **Kitty graphics protocol**.
  Its v1.25 release added Kitty's *keyboard* protocol, not the image one.
- Every Neovim plugin that draws Mermaid inside the terminal needs the Kitty protocol, or
  Überzug++, which needs X11 or Wayland.
- Neovim's own image API, `vim.ui.img`, is experimental, takes PNG only and draws through the
  Kitty protocol only.

So in Windows Terminal, Mermaid can be seen properly only in a browser. Kitty, WezTerm and Ghostty
do support the Kitty protocol, which is what option C relies on.

## The candidates

Activity and GitHub stars as of November 2026.

| Plugin | Where it renders | Mermaid | Needs | Activity |
|---|---|---|---|---|
| **live-preview.nvim** (installed) | browser | yes, tested | nothing; written entirely in Lua | active (Oct 2026), 448 stars |
| selimacerbas/markdown-preview.nvim | browser | yes, with zoom, pan and export | Lua, plus its helper plugin `kitehost.nvim` | active (Oct 2026), 247 stars |
| Vivify + vivify.vim | browser | yes | a separate `viv` program (AUR, Homebrew) | active (Oct 2026), 153 stars |
| iamcco/markdown-preview.nvim | browser | yes | a Node.js build step | **inactive since Jul 2024**, 8k stars |
| peek.nvim | its own window | yes | Deno | **inactive since Aug 2024** |
| **render-markdown.nvim** | inside the buffer | no, shown as a code block | treesitter | active (Nov 2026), 5.2k stars |
| **markview.nvim** | inside the buffer, or a side-by-side split | no, shown as a code block | treesitter | active (Oct 2026), 3.7k stars |
| md-render.nvim | floating window or tab | yes, as images through `mmdc` | a Kitty-protocol terminal | active (Oct 2026) |
| image.nvim + diagram.nvim | images in the buffer | yes, through `mmdc` | the Kitty protocol, or Überzug++ on X11/Wayland | active (Sep 2026) |
| mermaid-ascii (command line) | text in the terminal | flowcharts and sequence diagrams only, as ASCII art | a Go binary | active (Oct 2026) |
| glow.nvim | terminal float | no | — | **archived 2025** |

## The options

**A. live-preview.nvim in the browser (recommended, in use).** Nothing to change. The one
competitor worth a look is selimacerbas/markdown-preview.nvim, if interactive zoom, pan and export
of diagrams would be useful; it has not been tested here, and whether it also works without a
network connection was not checked.

**B. A rendered view inside the terminal, without diagrams (optional, not installed).** This is
the "side panel in the same terminal" idea:

- **markview.nvim's split view** shows the raw markdown on the left and the rendered version on
  the right.
- **render-markdown.nvim** draws headings, tables, lists and code blocks in place, in the buffer
  you are editing.

With either one, a Mermaid block stays a code block, so diagrams still go through A.

**C. Real diagrams inside the terminal, only in a different terminal.** On Arch with Kitty,
WezTerm or Ghostty, md-render.nvim can show Mermaid as pictures in a Neovim float. It cannot work in
Windows Terminal until Windows Terminal supports the Kitty graphics protocol.

## What was tested

In November 2026, live-preview.nvim ran in WSL on a page with a table, a sequence diagram and a
flowchart. The page was opened from Windows, both with `curl.exe` and in Edge. The table and both
diagrams rendered, and all assets came from the plugin, with no requests to the internet.

None of the other candidates was installed or tested; their rows come from their READMEs and
repository activity.

## Sources

- Plugin READMEs and repository activity on GitHub:
  [live-preview.nvim](https://github.com/brianhuster/live-preview.nvim),
  [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim),
  [markview.nvim](https://github.com/OXY2DEV/markview.nvim),
  [md-render.nvim](https://github.com/delphinus/md-render.nvim),
  [image.nvim](https://github.com/3rd/image.nvim),
  [diagram.nvim](https://github.com/3rd/diagram.nvim),
  [mermaid-ascii](https://github.com/AlexanderGrooff/mermaid-ascii),
  [Vivify](https://github.com/jannis-baum/Vivify),
  [peek.nvim](https://github.com/toppair/peek.nvim),
  [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [selimacerbas/markdown-preview.nvim](https://awesome.ecosyste.ms/projects/github.com%2Fselimacerbas%2Fmarkdown-preview.nvim)
- [Windows Terminal graphics support (ucs-detect)](https://ucs-detect.readthedocs.io/sw_results/windowsterminal.html)
- [Kitty vs Windows Terminal (Terminal Trove)](https://terminaltrove.com/compare/terminals/kitty-vs-windows-terminal/)
- [Windows Terminal v1.25 release notes](https://newreleases.io/project/github/microsoft/terminal/release/v1.25.622.0)
- [Kitty graphics protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)
