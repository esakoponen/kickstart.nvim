# Code navigation

How to move through code and build a picture of an unfamiliar codebase.

## The three questions, and their keys

| Question | Key |
|---|---|
| What is this? | `K` |
| Where is it defined? | `grd` |
| Where is it used? | `grr`, or `<leader>cr` for a preview |

That is the whole core loop - everything below is refinement.

`<C-o>` returns from any jump, so `grd` then `<C-o>` is a round trip with no bookkeeping.

## Reading a symbol

| Key | Shows |
|---|---|
| `K` | signature and documentation, in a float |
| `<C-s>` (insert) | signature help while typing arguments |
| `grd` | jump to the definition |
| `gri` | implementations — on an interface member, the classes implementing it |
| `grt` | type definition — on a variable, jump to its type |

## Who calls this

Three tools, increasingly powerful. Reach for the cheapest that answers the question.

| Key | Gives | Use when |
|---|---|---|
| `grr` | references in the quickfix window | a handful of hits, want to walk them in place |
| `<leader>cr` | references in a picker with preview | many hits, want to filter or skim before jumping |
| `<leader>ci` | **incoming calls** — the call hierarchy | tracing upward through layers |

The difference between references and incoming calls matters. References tell you every place the
name appears, flat. Incoming calls tell you **which methods** contain those calls, so you can press
`<leader>ci` again on a caller and keep walking up. That is how you find the entry point that
reaches a function buried five layers down.

`<leader>co` is the mirror image: what does this function call? Useful for grasping what a method
actually does without reading it line by line.

### Walking the quickfix list from `grr`

`grr` opens a quickfix window at the bottom. You do not have to stay in it:

| Key | Action |
|---|---|
| `äq` / `öq` | next / previous hit, **without** focusing the window |
| `<CR>` | in the window, jump to the hit under the cursor |
| `:cclose` / `:copen` | hide / reopen the same list |

`grr` then `äq` repeatedly is the fastest way to visit every call site in order.

## Finding something by name

| Key | Scope |
|---|---|
| `<leader>sS` | symbols across the **project** — the "where is class X" key |
| `<leader>ss` | symbols in **this file** |
| `<leader>st` | symbols from treesitter — works with no language server |
| `gO` | this file's symbols into the location list |
| `<leader>sf` | files by name |
| `<leader>sg` | file **contents**, project-wide (ripgrep) |
| `<leader>sw` | the word under the cursor, as text, project-wide |

Three different questions, easy to conflate: `<leader>sf` searches **file names**, `<leader>sS`
searches **symbol names**, `<leader>sg` searches **file contents**.

### Semantic versus textual, and why you want both

`grr` and `<leader>cr` are semantic: the language server resolves what the symbol actually is, so
they ignore comments, strings, and same-named methods on unrelated types.

`<leader>sw` and `<leader>sg` are textual: ripgrep over the files. Slower to read, but they find
things the server will not — occurrences in comments, in documentation, in config files, in
generated code, in a language with no server attached at all.

Use the semantic ones by default. Fall back to text when the project will not load, when the server
is still starting, or when you *want* the comments.

## Moving within a file

| Key | Action |
|---|---|
| `äm` / `öm` | next / previous function start |
| `äM` / `öM` | next / previous function end |
| `;` / `,` | repeat that jump forward / backward |
| `za` / `zR` / `zM` | fold: toggle this one / open all / close all |
| `öd` / `äd` | previous / next diagnostic |
| `%` | jump to the matching bracket |

`zM` then `zR` is an underrated way to meet a new file: close every fold to see the shape — just the
class and method signatures — then open the one part you care about.

`daF` deletes an entire function, `yaF` copies one, `vaF` selects one. `aF` is the enclosing
function as a textobject, so it works with any operator.

## Getting back

Navigation is only comfortable if returning is free.

| Key | Returns to |
|---|---|
| `<C-o>` / `<C-i>` | previous / next jump |
| `''` | position before the latest jump — one key, there and back |
| `` `. `` | the last edit |
| `g;` / `g,` | previous / next **change** — a different list from jumps |
| `<leader><leader>` | switch buffer |

`g;` is the one to remember when you have wandered off and want to return to what you were actually
writing. `:jumps` prints the jump list if you lose track.

## Reviewing a change

| Key | Action |
|---|---|
| `<leader>gg` | changed files — the place to start a review |
| `äh` / `öh` | next / previous hunk in this file |
| `<leader>gp` | preview the hunk inline |
| `<leader>gb` | blame this line, with the commit message |
| `<leader>gd` | diff this file in a split |
| `<leader>gL` | this file's history |
| `<leader>gl` | the repository's history |
| `<leader>q` | this file's diagnostics into the location list |
| `<leader>sd` | diagnostics across the whole project |

A review pass that works: `<leader>gg` to list what changed, `<CR>` into a file, `äh` to walk the
hunks, `<leader>gp` on anything unclear, `<leader>gb` when you need the *why* rather than the what.
On a hunk that touches a function, `<leader>cr` shows every other caller — which is where the
breakage nobody noticed usually is.

`dih` discards the hunk under the cursor and `<leader>gs` stages it, so a review can also be a
cleanup pass.

## Building understanding of an unfamiliar codebase

An order that works, from the outside in:

1. **Shape of the tree** — `-` and walk it. Directory names carry most of the architecture.
2. **Entry points** — `<leader>sS` for `Main`, `Startup`, `Program`, `Configure`. Start where the
   process starts.
3. **Vocabulary** — `<leader>sS` and type a domain noun you saw in the directory names. The classes
   that come back are the domain model.
4. **Shape of one file** — open it, `zM` to collapse everything, read the signatures, `zR` when you
   have the outline.
5. **One path, end to end** — pick an interesting function, `<leader>co` to see what it calls, `grd`
   into whichever call looks important, `<C-o>` back out. Repeat. This traces a real path through
   the system rather than reading files in isolation.
6. **Reverse the direction** — on a function that looks central, `<leader>ci` and keep pressing it.
   You are walking up to the entry points, which tells you what the code is *for*.
7. **Where the work happens** — `<leader>gl` for recent commits, or `<leader>gL` on a file that
   keeps appearing. Churn marks the parts that matter.
8. **Where it breaks** — `<leader>sd` for project diagnostics. Existing warnings are a map of the
   codebase's rough edges.

Steps 5 and 6 are the pair that does the real work: `<leader>co` goes down into detail,
`<leader>ci` comes back up to purpose.

## C# specifics

`csharp_ls` needs a `.sln` or `.csproj` discoverable from the project root. Without one it attaches
but resolves nothing.

**It also needs time.** The server registers several capabilities only after it has loaded the
project, so `grd`, `grr` and `<leader>ci` return nothing at all for the first several seconds and
look broken. Wait, then retry. Verified on a test project: requests issued too early returned zero
results, while identical requests after the project loaded returned correct ones.

To check whether it is ready:

```vim
:lua =vim.lsp.get_clients({ bufnr = 0 })[1]:supports_method('textDocument/definition')
```

Use `supports_method`, **not** `server_capabilities`. csharp_ls registers capabilities dynamically,
so `server_capabilities.definitionProvider` stays `nil` even when go-to-definition works perfectly.

Confirmed working on a real project: references, definition, implementations, document symbols,
workspace symbols, and call hierarchy in both directions.

## When the language server is not available

Erlang has no server in this config, and any server takes time to start. These still work:

- `<leader>st` — treesitter symbols, instantly, no server
- `<leader>sg` / `<leader>sw` — ripgrep over contents
- `äm` / `öm`, `aF`, folds — all parser-based
- `gO` needs a server; `<leader>st` is the substitute
