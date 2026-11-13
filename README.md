# Neovim configuration

A personal Neovim configuration in a single, commented `init.lua`. It started as a fork of
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and has since been rewritten around
Neovim's built-in package manager, `vim.pack`.

The same files run unchanged on WSL (Ubuntu), Arch Linux and Windows 11. Linux is the main
platform; the few platform differences are handled inside `init.lua`.

## Requirements

- **Neovim 0.13 nightly** on every machine. Stable releases lack APIs this config uses. Ways to
  install it: [INSTALLING-NEOVIM.md](INSTALLING-NEOVIM.md).
- `git`, `curl`, `unzip`, a C compiler (treesitter builds its parsers), `fzf`, `ripgrep` and `fd`.
  Package lists for Ubuntu, WSL and Arch: [LINUX-SETUP.md](LINUX-SETUP.md).
- The toolchain of each language you work in, for its language server:
  [LANGUAGE-RUNTIMES.md](LANGUAGE-RUNTIMES.md).
- No Nerd Font: icons are ASCII letters.

## Install

    # Linux and WSL
    git clone <this-repo> ~/.config/nvim

    # Windows (PowerShell)
    git clone <this-repo> "$env:LOCALAPPDATA\nvim"

Start `nvim`. vim.pack lists the plugins it is about to install; answer **Yes**. Mason then installs
the language servers, formatters, linters and debug adapters in the background. When it has
finished, `:checkhealth` (or `<leader>rh`) reports anything still missing.

To update: `<leader>rp` (`:packupdate`) for plugins, `:MasonToolsUpdate` for Mason's tools.

## What it does

- **Languages**: language servers for C, C++, Python, Ruby and Rails, Elixir and HEEx, C#, Rust,
  Lua, HTML, CSS, JavaScript, TypeScript and Bicep, plus Erlang on Linux and WSL. Formatting on
  demand with `<leader>f`; linters run on save.
- **Debugging and tests**: nvim-dap for Python, C, C++, Rust, C# and Elixir; vim-test runs the
  nearest test, the file or the suite in any of those languages.
- **Finding things**: fzf-lua for files, grep, symbols, buffers, git and help; oil.nvim edits
  directories as text.
- **Git**: gitsigns for hunks, blame and staging; a three-pane `git mergetool` view whose side
  panes show each conflicting line's commit and author; commit messages wrap at 72 columns.
- **Markdown**: a live browser preview that renders Mermaid diagrams and KaTeX maths, offline.
- **Keyboard**: designed for a Finnish layout, where `[` and `]` need AltGr: `ö` and `ä` stand in
  for them.

## Documentation

| File | Covers |
|---|---|
| [PRINCIPLES.md](PRINCIPLES.md) | what the editor is for (focus, context, the big picture, keeping the craft), and the test every change must pass |
| [KEYBINDINGS.md](KEYBINDINGS.md) | every key, grouped by task, including merge conflicts, debugging and tests |
| [CODE-NAVIGATION.md](CODE-NAVIGATION.md) | moving through code and learning an unfamiliar codebase |
| [OIL.md](OIL.md) | managing files with oil.nvim |
| [PLUGINS.md](PLUGINS.md) | each plugin, what it is for, and what was deliberately left out |
| [LINUX-SETUP.md](LINUX-SETUP.md) | setting up WSL or Arch from scratch |
| [INSTALLING-NEOVIM.md](INSTALLING-NEOVIM.md) | install methods for a Neovim nightly, and where each puts it |
| [LANGUAGE-RUNTIMES.md](LANGUAGE-RUNTIMES.md) | Ruby, .NET, Elixir, Erlang and Rust toolchains |
| [LINE-WIDTH.md](LINE-WIDTH.md) | the ruler at column 81, and where the usual line widths come from |
| [MARKDOWN-PREVIEW.md](MARKDOWN-PREVIEW.md) | why markdown is previewed in the browser, and the alternatives compared |
| [AGENTS.md](AGENTS.md) | conventions and the verification loop for changing `init.lua` |

## Files from kickstart.nvim

`lua/kickstart/`, `lua/custom/` and `doc/kickstart.txt` are upstream files, kept so that merging
from kickstart.nvim stays simple. `init.lua` loads none of them; only `:checkhealth` still runs
kickstart's basic check from `lua/kickstart/health.lua`. kickstart.nvim's MIT licence is in
[LICENSE.md](LICENSE.md).
