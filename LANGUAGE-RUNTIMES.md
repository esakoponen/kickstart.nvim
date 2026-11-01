# Language runtimes

Mason installs the language servers, but five of them run on top of a toolchain that Mason does
not install. Without it the server either fails to install or installs and never attaches. Install
only the languages you work in; nothing else in the config depends on them.

| Language | Mason installs | Needs from you |
|---|---|---|
| Ruby | `ruby-lsp` (+ `ruby-lsp-rails`), `rubocop` | Ruby with headers and a C compiler — both are gems, and some dependencies compile C extensions |
| C# | `csharp-ls` | **.NET 10 SDK** — csharp-ls 0.24 targets `net10.0`, so an 8.0-only install cannot run it |
| Elixir | `elixir-ls` | **Elixir ≥ 1.16 on Erlang/OTP ≥ 26** — ElixirLS 0.31 dropped older versions |
| Erlang | `elp` (Linux/WSL only) | Erlang/OTP, plus **rebar3 ≥ 3.24** for rebar3 projects |
| Rust | `rust-analyzer` | A rustup toolchain with `rustfmt`, `clippy` and `rust-src` |

The minimums are those of the servers Mason installed in late 2026. If a server later stops
starting after `:MasonToolsUpdate`, check its release notes for a raised minimum first.

## Ruby

    # Windows: RubyInstaller "Ruby+Devkit" (x64) from https://rubyinstaller.org/downloads/
    #          The Devkit is MSYS2, which compiles native gems; add it later with `ridk install`.

    # Ubuntu / WSL
    sudo apt install ruby ruby-dev

    # Arch (pulls in rubygems)
    sudo pacman -S ruby

The C compiler comes from `build-essential` / `base-devel` in [LINUX-SETUP.md](LINUX-SETUP.md).

## C#

    # Windows
    winget install Microsoft.DotNet.SDK.10

    # Ubuntu / WSL — 10.0 is in Ubuntu's own archive for 24.04, no PPA needed
    sudo apt install dotnet-sdk-10.0

    # Arch
    sudo pacman -S dotnet-sdk

Check with `dotnet --list-sdks`: a `10.x` line must be present. Older SDKs can stay alongside it.

## Elixir

ElixirLS needs Elixir ≥ 1.16 on OTP ≥ 26, and each Elixir build is compiled for one OTP major.

    # Windows: Erlang installer from https://www.erlang.org/downloads, then the matching
    #          elixir-otp-<OTP major>.exe from https://elixir-lang.org/install/

    # Ubuntu / WSL — apt has Elixir 1.14 on OTP 25, both too old. Use the official script
    # with the current versions shown on https://elixir-lang.org/install/, e.g.:
    curl -fsSO https://elixir-lang.org/install.sh
    sh install.sh elixir@1.20.5 otp@29.1
    # then add the two `export PATH=...` lines it prints to ~/.bashrc
    export PATH=$installs_dir/otp/29.1/bin:$PATH
    export PATH=$installs_dir/elixir/1.20.5-otp-29/bin:$PATH
    iex

    # Arch (pulls in erlang)
    sudo pacman -S elixir

`mix format`, which conform uses for Elixir, ships with Elixir.

## Erlang

`elp` is enabled only where `has('win32')` is 0, so this applies to WSL and Arch. On Windows
there is no Erlang server; see the note above the `LspAttach` autocmd in `init.lua`.

- **Erlang/OTP** — the Elixir step above already installs it (on Ubuntu, use the script even
  if you only write Erlang; apt's OTP 25 is too old). Mason's `elp` is built on OTP 27.3; the
  ELP docs say running it on a newer OTP is fine.
- **rebar3 ≥ 3.24** — ELP reads rebar3 projects through it. Without it, completion and
  go-to-definition degrade.

      # Ubuntu / WSL — apt has 3.19, too old
      curl -fsSL -o ~/.local/bin/rebar3 https://s3.amazonaws.com/rebar3/rebar3
      chmod +x ~/.local/bin/rebar3

      # Arch
      sudo pacman -S rebar3

## Rust

    # Windows: rustup-init.exe from https://rustup.rs — it offers to install the
    #          Visual Studio C++ build tools that the MSVC toolchain links with

    # Ubuntu / WSL
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

    # Arch
    sudo pacman -S rustup
    rustup default stable

    # Every platform
    rustup component add rustfmt clippy rust-src

- **rustfmt** — conform formats Rust with it.
- **clippy** — rust-analyzer's check command is `clippy` instead of plain `cargo check`.
- **rust-src** — the standard library's source; without it rust-analyzer cannot complete or
  jump into `std`.

## Checking it works

Install the runtime first, then restart Neovim: mason-tool-installer retries anything missing on
startup (or run `:MasonToolsInstall`). Then:

    :Mason                  " the server is listed as installed, with no error
    :checkhealth vim.lsp    " with a file of that language open: the server is an active client

Open a file inside a real project (a `Gemfile`, `.csproj`, `mix.exs`, `rebar.config` or
`Cargo.toml` next to it) — most of these servers do little with a lone file.
