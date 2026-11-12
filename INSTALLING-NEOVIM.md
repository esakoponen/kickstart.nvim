# Installing Neovim

This config needs a **Neovim 0.13 nightly** on every machine — Windows, WSL and Arch alike. It
uses APIs that stable releases do not have yet (`vim.hl.hl_op()`, and nvim-dap-view needs the
`SessionWritePre` event), so a stable or distro package loads with errors. Check with:

    nvim --version          # first line must read NVIM v0.13.0-dev-...

Keep the machines on roughly the same nightly; update them together.

## Your config and plugins do not move

Whatever the install method, Neovim reads and writes the same folders, so switching methods keeps
everything:

| | Windows | Linux / WSL |
|---|---|---|
| Config (this repo) | `%LOCALAPPDATA%\nvim` | `~/.config/nvim` |
| Plugins, Mason tools, logs | `%LOCALAPPDATA%\nvim-data` | `~/.local/share/nvim` |
| Sessions, undo history, colorscheme choice | `%LOCALAPPDATA%\nvim-data` | `~/.local/state/nvim` |

## Windows

| Method | Command / file | Nightly? | Where `nvim.exe` ends up | PATH | Updating |
|---|---|---|---|---|---|
| **Official MSI** | `nvim-win64.msi` from the [nightly release](https://github.com/neovim/neovim/releases/tag/nightly) | yes | `C:\Program Files\Neovim\bin` | machine | download the new MSI and run it; it upgrades in place |
| **winget** | `winget install Neovim.Neovim.Nightly` | yes | `C:\Program Files\Neovim\bin` (it runs the official MSI) | machine | `winget upgrade Neovim.Neovim.Nightly` |
| winget, stable | `winget install Neovim.Neovim` | no — too old | `C:\Program Files\Neovim\bin` | machine | — |
| **Official zip** | `nvim-win64.zip` from the nightly release | yes | wherever you unpack it, in `nvim-win64\bin` | none; add it yourself | unpack again |
| **Chocolatey** | `choco install neovim --pre` | yes | `C:\tools\neovim\nvim-win64\bin` | user | `choco install neovim --pre --force` |
| **Scoop** | `scoop bucket add versions`, then `scoop install neovim-nightly` | yes | `%USERPROFILE%\scoop\apps\neovim-nightly\current\bin`, run through `%USERPROFILE%\scoop\shims` | user | `scoop update neovim-nightly` |
| Scoop, stable | `scoop install neovim` | no — too old | `%USERPROFILE%\scoop\apps\neovim\current\bin` | user | — |
| **bob** | `bob use nightly` | yes | `%LOCALAPPDATA%\bob\nvim-bin` | add it yourself | `bob update nightly` |
| **Built from source** | `cmake --install build --prefix <folder>` | yes | the prefix you give; without one CMake picks `C:\Program Files\nvim` | none; add it yourself | rebuild |
| Microsoft Store | — | — | the Neovim project does not publish there | — | — |

Notes:

- **winget is the simplest repeatable route.** Its `Neovim.Neovim.Nightly` manifest is refreshed
  daily with the SHA-256 of that day's MSI, which winget checks before installing. Just after a new
  nightly is built, the manifest can lag behind it for a few hours and the hash check fails; retry
  later.
- **Chocolatey's `--pre` package** downloads whatever the nightly is at install time, but without a
  checksum. Its version label (e.g. `0.12.7-beta`) says nothing about the build inside, and
  `choco upgrade` only fetches again when that label changes — hence `--force`.
- Program Files locations need an administrator prompt; zip, Scoop and bob installs do not.
- **With more than one install, PATH order decides which runs.** Windows searches the machine PATH
  before the user PATH, so an MSI or winget install hides a Chocolatey, Scoop or bob one. Uninstall
  the old one (Settings → Apps → Installed apps → Neovim), then check what remains:

      (Get-Command nvim -All).Source      # every nvim.exe on PATH, in the order Windows tries them

## Linux and WSL

| Method | Command / file | Nightly? | Where `nvim` ends up | Updating |
|---|---|---|---|---|
| Ubuntu apt | `sudo apt install neovim` | no — 24.04 ships 0.9.5 | `/usr/bin/nvim` | — |
| **Official tarball** | `nvim-linux-x86_64.tar.gz` from the nightly release | yes | wherever you unpack it: `/opt/nvim-linux-x86_64`, linked from `/usr/local/bin/nvim` ([LINUX-SETUP.md](LINUX-SETUP.md)); or without sudo, `~/.local/opt/nvim-linux-x86_64`, linked from `~/.local/bin/nvim` | unpack again |
| **Official AppImage** | `nvim-linux-x86_64.appimage` from the nightly release | yes | wherever you put the file | download again |
| Arch pacman | `sudo pacman -S neovim` | no — 0.12 stable | `/usr/bin/nvim` | — |
| **Arch AUR** | `yay -S neovim-nightly-bin` | yes | `/usr/bin/nvim` | `yay -Syu` |
| **bob** | `bob use nightly` | yes | `~/.local/share/bob/nvim-bin` | `bob update nightly` |
| **Built from source** | `make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install` | yes | `/usr/local/bin/nvim` | rebuild |

Notes:

- The tarball steps are in [LINUX-SETUP.md](LINUX-SETUP.md), section 1. Remove the apt package
  first (`sudo apt remove neovim`) so the old `/usr/bin/nvim` cannot shadow the new one.
- The AppImage needs FUSE 2: `sudo apt install libfuse2t64` on Ubuntu 24.04. The tarball needs
  nothing, which is why this setup uses it.
- `aarch64` machines use the `nvim-linux-arm64` files instead.
- Which `nvim` runs: `type -a nvim` lists them in PATH order. After moving an install, `hash -r`
  makes the shell forget the old location.
