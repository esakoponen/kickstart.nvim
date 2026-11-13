# Feature proposal: semantic code search

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

- **When someone asks "where do we handle X?", the answer appears within a second or two.** The
  index is built before the meeting; a query never waits for indexing.
- **Each result shows the construct's name and enough code in the preview** to recognise it before
  jumping.
- **Enter jumps to the code, and `<C-o>` returns** to where the presentation was.

## Description

Search a chosen project by meaning. A query in plain words returns the files, classes, functions and
other constructs that deal with that concept, ranked by how closely they match, even when no
identifier or comment contains the words. Example queries:

- "retry with backoff"
- "where permissions are checked"
- "repository pattern"
- "invoice rounding"
- "the function that formats dates for the API"

It adds to the existing exact searches and replaces none of them:

| Question | Key |
|---|---|
| Which file is called this? | `<leader>sf` |
| Where does this exact text appear? | `<leader>sg`, `<leader>sw` |
| Which symbol has this name? | `<leader>ss`, `<leader>sS`, `<leader>st` |
| **What code deals with this idea?** | new |

**How such tools usually work:**

1. The code is cut into chunks along syntax boundaries, such as functions and classes.
2. A model turns each chunk into an embedding: a vector that places chunks with similar meaning near
   each other.
3. The vectors are stored in an index.
4. A query is turned into a vector the same way, and the nearest chunks come back.

Hybrid engines also mix in keyword ranking (BM25), so exact names still score.

The results appear in a picker showing the file and line, the construct's name and a preview. Enter
jumps to the construct.

## Additional questions

1. **Privacy.** Must code stay on the machine, so the embedding model runs locally? Or is a cloud
   embedding service acceptable for some projects? Work code usually rules the cloud out.
2. **Languages and size.** Which languages and project sizes matter most? This config already covers
   C, C++, C#, Python, Ruby, Elixir, Erlang, Rust, Lua, JavaScript, TypeScript and Bicep.
3. **Hardware and time.** CPU only, on a laptop under WSL? How long may the first index build take,
   and how fast must updates be?
4. **Query styles.** Plain-language queries only, or also "find code like this selection"?
5. **Granularity.** Results per construct (function, class), or whole files ranked?
6. **An LLM in the loop?** Should a language model answer, re-rank or explain results? Or should it be
   pure retrieval, with no model beyond the embeddings?
7. **Install footprint.** What is acceptable: a Rust binary (cargo is installed in WSL), an npm
   package, a Python package, or a local model server such as Ollama (not installed)?
8. **Platforms.** Linux and WSL only (the primary platforms), or Windows too?
9. **Language of the code.** Are comments, docs and domain terms in English, or partly in Finnish? That
   decides which embedding models are suitable.

### For live review sessions

10. Will these searches happen live in meetings, where speed matters more than depth? An AI agent's
    answer usually takes far longer than an indexed search.
11. Should the search also be limited, on request, to the files you changed on the branch being
    reviewed?

## Similar tooling

**Already in this config (exact, not by meaning):** LSP workspace symbols (`<leader>sS`) match symbol
names fuzzily, and ripgrep (`<leader>sg`) matches text.

**Command-line tools that search by meaning.** Each prints file and line results that an fzf-lua
picker can show.

| Tool | How it works | Notes |
|---|---|---|
| **ck** (BeaconBay/ck) | Rust CLI. Local embeddings through fastembed (ONNX models on the CPU): bge-small by default, nomic-v1.5 and jina-code optional. Tree-sitter chunks at function and class boundaries. Regex, semantic and hybrid modes; an MCP server. | `cargo install ck-search`. Skips `.git`, `node_modules`, `target/` and similar folders by default. |
| **osgrep** | npm package; local embeddings through transformers.js. A local-only rewrite inspired by Mixedbread's mgrep. | Young project. |
| **grepai** | Go CLI; embeddings through Ollama, LM Studio or OpenAI. | With OpenAI, code is sent to a third party. |
| **vecgrep** | Embeddings through a local Ollama. | Needs Ollama. |
| **zg** (zvec-grep) | Vector search plus BM25 combined with ripgrep; bundled local models; incremental index updates. | Announced August 2026. |
| **embgrep** | Local embeddings; no API keys and no vector database server. | Python package. |

**Tools built for Neovim**

| Tool | How it works | Notes |
|---|---|---|
| **VectorCode** | Python. Tree-sitter chunks, a Chroma vector store, a CLI, a Lua API and an MCP server. Integrates with CodeCompanion.nvim and minuet-ai.nvim. | Built mainly to feed context to LLM assistants rather than for a person searching. Pre-1.0 and labelled beta; the latest release I could confirm is from 2025. |
| **codebase-semantic-search** (jiangyinzuo) | A CLI, a Neovim plugin and an MCP server; local models or an OpenAI-compatible API. | Tree-sitter chunking for Python and C++ only. |

**Asking an AI agent instead (no index):** Claude Code (already in use) or CodeCompanion.nvim can
answer "where is X handled?" in plain language by searching with grep and the language server. That
is slower and costs tokens, but it also explains what it found.

Most of the command-line tools are young projects from 2025–2026; check their activity before
choosing one.

## Further design questions

1. **Engine inside or outside Neovim?** An external CLI keeps `init.lua` small: a picker that runs
   the tool is roughly 15 lines. A Neovim-native index with an embedding server would not fit the
   single-file rule.
2. **Embedding model.** A small general model (bge-small), a code-specific one (jina-code), or a
   larger one through Ollama? Compare quality and CPU speed on your own queries.
3. **Chunking.** Syntax-aware chunks (functions, classes) or fixed-size windows? Should each chunk's
   text include its file path, class name and docstring?
4. **Ranking.** Vectors alone, hybrid with BM25, or a re-ranking model on top?
5. **The index.**
   - Where it lives: inside the project (which then needs a `.gitignore` entry) or under `~/.cache`.
   - When it updates: on demand, on save, or from a git hook.
   - It should respect `.gitignore`.
6. **Interface.** An fzf-lua picker (`fzf_exec`) with file:line entries and the standard previewer.
   Enter jumps, `alt-q` sends the results to the quickfix list. The key belongs under `<leader>s`:
   `<leader>sm` ("meaning") and `<leader>sc` ("concept") are both free.
7. **Choosing the project.** By default the current git root; also a way to pick another project?
8. **Query from a selection.** In visual mode, search for code similar to the selected lines.
9. **Installing the tool.** If it is in Mason's registry, mason-tool-installer can install it like
   the language servers. Otherwise document it in [LINUX-SETUP.md](LINUX-SETUP.md).
10. **Judging quality.** Keep a short list of queries with the locations they should find, per
    project, to compare tools and models.
11. **Line budget.** `init.lua` is at 1150 of its 1200 lines.

### For live review sessions

12. **Indexing ahead of time.** Update on save or with a key before the meeting, never on the query
    path.
13. **Readable results.** At a large font the picker must show the construct's name and path on one
    line, with the code in the preview.
14. **Scope switch.** The whole project, or only the files changed on the branch.
15. **Getting back.** `<C-o>` returns to where you were presenting, and `<leader>sr` reopens the last
    results.

## Sources

- [ck documentation](https://beaconbay.github.io/ck/features/semantic-search.html),
  [ck FAQ](https://beaconbay.github.io/ck/guide/faq.html),
  [ck on Linux Links](https://www.linuxlinks.com/ck-semantic-code-search/)
- [osgrep](https://www.sourcepulse.org/projects/19356928)
- [grepai](https://pkg.go.dev/github.com/yoanbernabeu/grepai)
- [vecgrep](https://pkg.go.dev/github.com/abdul-hamid-achik/vecgrep@v0.4.0)
- [zg, "From rg to zg: Local Search Beyond Keywords"](https://zvec.org/en/blog/2026-08-28-zvec-grep-open-source/)
- [embgrep](https://pypi.org/project/embgrep/)
- [VectorCode](https://github.com/davidyz/vectorcode),
  [its CodeCompanion extension](https://codecompanion.olimorris.dev/extensions/vectorcode),
  [VectorCode on PyPI](https://pypi.org/project/VectorCode/)
- [codebase-semantic-search](https://gxx.netlify.app/jiangyinzuo/codebase-semantic-search)
