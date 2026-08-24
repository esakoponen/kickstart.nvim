# Linux / WSL setup

The same `init.lua` runs on Windows, WSL and Linux. Platform differences are handled inside it by
`has("win32")` and `has("wsl")` guards, so there is nothing to edit.

## 1. Neovim

Needs **0.13-dev or newer** (`vim.pack`, `vim.hl.hl_op`). Distro packages are far too old — Ubuntu
24.04 ships 0.9.5. Build nightly, or use the prebuilt tarball:

    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    sudo ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

## 2. Config

    git clone <this-repo> ~/.config/nvim

`nvim-pack-lock.json` pins plugin revisions, so both machines get identical versions.

## 3. Packages

    # Debian / Ubuntu
    sudo apt install build-essential git curl unzip fzf ripgrep fd-find

    # Arch
    sudo pacman -S base-devel git curl unzip fzf ripgrep fd

`build-essential` is required: treesitter compiles parsers on first use.

Ubuntu names the fd binary `fdfind`; link it so fzf-lua finds it:

    mkdir -p ~/.local/bin && ln -s "$(which fdfind)" ~/.local/bin/fd

## 4. WSL only

    sudo apt install wl-clipboard wslu

- **wl-clipboard** — makes `clipboard=unnamedplus` share the Windows clipboard. WSLg sets
  `$WAYLAND_DISPLAY`, which is the first provider Neovim looks for.
- **wslu** — provides `wslview`, which `<leader>up` uses to open the markdown preview in your
  Windows browser. On plain Linux this is unnecessary; the config falls back to `default`.

## 5. First run

    nvim

Plugins install themselves, then mason fetches the servers and formatters. Then:

    :checkhealth        " or <leader>rh

## 6. Language runtimes, as needed

| Language | Needs |
|---|---|
| JS/TS, prettier | `nodejs npm` |
| Python | `python3 python3-venv` |
| Ruby | `ruby ruby-dev` |
| Rust | `rustup` + `rustup component add rustfmt clippy` |
| C# | `dotnet-sdk-8.0` (or newer) |
| Elixir | `elixir` (brings `mix format`) |
| Erlang | `erlang` — **elp is enabled here**, unlike on Windows |

## What differs from Windows

- **Erlang gets a language server.** `elp` ships Linux binaries only, so `init.lua` enables it
  whenever `has("win32")` is 0 — WSL included. On Windows there is still no Erlang server.
- **The shell is bash**, not PowerShell; the pwsh block skips itself.
- **Sessions, undo history and the remembered colorscheme are per-machine** — they live in
  `stdpath("state")`, so the two installs keep separate state. Expected, not a fault.
- **Icons stay ASCII** unless you point the terminal at a Nerd Font, then set
  `mini.icons` `style = "glyph"`.
