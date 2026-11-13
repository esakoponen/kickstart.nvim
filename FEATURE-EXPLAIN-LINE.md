# Feature proposal: explain this line, what it does and why

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

- **When someone asks "why is it done like this?", one key on the line shows the answer**, readable
  by everyone on the shared screen.
- **The "why" has to be trustworthy in front of the team.** What comes from recorded history (a
  commit message, a pull request, an issue) is shown as such, and kept apart from anything a model
  infers.
- **Fast.** Recorded facts appear at once. A model's explanation can take seconds, so the facts come
  first, or the explanations are prepared before the meeting.

## Description

With the cursor on a line of code, a toggle shows an explanation of that line:

1. **What it does**: in plain words, in the context of the function around it.
2. **Why it is written this way**: the reasoning behind it. That comes from the commit that
   introduced or last changed the line (its message, its pull request, a linked issue) and from
   comments nearby. Where nothing is recorded, a model's inference, clearly marked as one.

While the toggle is on, moving the cursor updates the explanation, as inline git blame does today.
Turned off, nothing is shown. The explanation appears as a short label at the end of the line, or as
a hovering tooltip; text too long for the space scrolls past briefly.

**Where the "why" can come from:**

| Source | What it gives | Cost |
|---|---|---|
| `git blame`, then the commit message | The author's stated reason, if they wrote one | Instant |
| The line's history (`git log -L`) | How the line evolved, commit by commit | Instant to a few seconds |
| The pull request (description, review comments) | Fuller reasoning and the discussion | Network; needs `gh` signed in |
| An issue or ticket named in the commit message | The requirement behind the change | Network; tracker access |
| Comments and docs near the line | Intent the author wrote down | Instant |
| The language server's hover | What a symbol is: its type and documentation | Instant |
| A language model, for example Claude | "What" in plain words, and an *inferred* "why" | Seconds; sends code to the provider; can be wrong |

## Additional questions

1. **"What it does":** does it need a model, or would the language server's hover plus the
   surrounding code be enough?
2. **"Why":** only from recorded history, or may a model infer it? If it infers, must it cite what it
   based the answer on?
3. **Which AI service is allowed for work code?** Claude Code is already in use; may explanations go
   through it?
4. **Where is the code hosted:** GitHub, Azure DevOps, GitLab? That decides how pull requests are
   looked up. (`gh` is installed on Windows but not in WSL.)
5. **Issue tracker:** do commit messages name tickets, for example Jira keys? Can the machine reach
   the tracker?
6. **Toggle or one-shot?** Should the explanation follow the cursor while toggled on, or appear once
   per key press? Calling a model on every cursor move would be slow and costly.
7. **Display:**
   - an end-of-line label;
   - lines inserted below the code;
   - a floating tooltip;
   - a side panel?
   Is the scrolling text a must, or just a way to fit long text into one line?
8. **Length and language:** one sentence or a paragraph? English, or Finnish for the team?
9. **Scope:** one line only, or also a visual selection and the whole function?
10. **Before a review:** prepare explanations in advance (for example for every line the branch
    changed), or generate them live?

## Similar tooling

**Already in this config**

| Tool | What it shows | Gap |
|---|---|---|
| `K` (LSP hover) | What the symbol under the cursor is: signature and documentation. | About a symbol, not the line; no "why". |
| `<leader>gb` (gitsigns `blame_line`, full) | A popup with the commit that last changed the line: author, date, full message and the hunk. | The recorded "why", if the message gives one. Only the *last* change, which may be a formatting commit. |
| `<leader>ub` (gitsigns current-line blame) | An end-of-line label on the current line (author, date, summary) that follows the cursor. Its text is set by `current_line_blame_formatter`, which can be a function; its position by `virt_text_pos` (end of line, overlay, right-aligned). | Exactly the toggle-and-label shape wanted; the content is blame only. |
| fzf-lua `git_bcommits` / `git_blame` on a visual selection (installed, no key) | The history of the selected lines (`git log -L`) in a picker, with each commit's diff in the preview. | A picker, not a label. |

**Blame and pull-request plugins**

| Tool | What it does |
|---|---|
| trace-pr.nvim | Opens the GitHub pull request that introduced the line (falls back to the commit), through `gh`. |
| gh-blame.nvim | Pull-request blame on cursor hold, and a blame sidebar. GitHub only. |
| git-blame.nvim (f-person) | A blame label with a configurable template; copies the line's pull-request URL. Overlaps gitsigns. |
| blamer.nvim | Blame text inspired by VS Code's GitLens. |

**AI assistants in Neovim**

| Tool | What it does | Gap |
|---|---|---|
| CodeCompanion.nvim | A `/explain` prompt that explains the selected code; an inline assistant; adapters for Anthropic, OpenAI and Ollama. | Answers in a chat buffer, not a label; a large plugin. |
| CopilotChat.nvim | `:CopilotChatExplain`; works on the visual selection, or the current line without one. | Needs a GitHub Copilot subscription. |
| avante.nvim | `:AvanteAsk` about the code or a selection, in a sidebar. | A large, Cursor-style plugin. |
| claudecode.nvim (coder) | Connects Neovim to the Claude Code CLI, as the VS Code extension does; `:'<,'>ClaudeCodeSend` sends a selection. | The answer appears in Claude Code's terminal, not on the line. |
| `claude -p` (Claude Code's print mode; installed on Windows and in WSL) | A one-shot answer on standard output. A few lines of Lua could give it the line, its function, the blame and the commit message. | No plugin needed; takes seconds; uses your Claude account. |

**Tools that explain why code exists**

| Tool | How it works |
|---|---|
| git-why (muin-company) | `git-why file:line`: feeds blame, commit messages and diffs to a model for an explanation. |
| git-why (hexapode), lore | Record AI agents' reasoning at commit time and look it up later. Only covers code written with agents from now on. |
| commit-archaeologist (an agent skill) | Reconstructs why code exists from local git history, and warns that blame ownership is not proof of intent. |
| git-context-mcp | An MCP server giving agents blame, pull-request descriptions and linked issues. |
| semblame | An LLM-powered extension of git blame. |

**In VS Code:** GitLens's hover (blame, commit message and pull-request link on one card) is the model
for the "why" half of this feature.

**Takeaway:** the toggle-and-label UI already exists as gitsigns' current-line blame, and the
recorded "why" is one key away in `<leader>gb`. What is missing is "what it does" in plain words, and
a "why" that looks beyond the last commit to the pull request, the issue and earlier history. Both
need a language model, and its inferences must be kept apart from recorded facts.

## Further design questions

1. **Two layers.** Instant facts (blame, commit summary, pull-request title) in the label as soon as
   the cursor rests; the model's explanation only on a key press.
2. **Which commit holds the "why"?** The last change is often a reformat or a move. Use
   `git blame -w -C -C` to skip whitespace changes and moved code, honour
   `.git-blame-ignore-revs`, or walk the line's history with `git log -L`?
3. **How to call the model.** `claude -p` with no plugin, an AI plugin such as CodeCompanion, or a
   direct API call from Lua (which needs an API key)? The prompt would hold the line, its enclosing
   function (found with treesitter), the commit messages, the pull-request text and the diff, and ask
   the model to separate what is recorded from what it infers.
4. **Display.**
   - End-of-line text, as gitsigns' blame: one line, truncated.
   - Lines below the code: room for several lines, but they push the code down.
   - A floating window, like hover: wraps, can be scrolled, closes when the cursor moves.
   - Scrolling text: a timer moves a one-line label along. Eye-catching, but hard to read, and
     harder still through a video stream. A float that scrolls itself may serve better.
5. **Toggle behaviour.** Per buffer or global? Facts driven by `CursorHold` (250 ms here); model
   calls debounced, and cancelled when the cursor moves on.
6. **Caching.** Key each explanation by file, commit and line content, so repeats are instant.
   Prepare explanations for every line a branch changed before a review, together with the tour in
   [FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md).
7. **Keys.** `<leader>ue` for the toggle (the UI group) and `<leader>ce` for a one-off explanation
   (the code group); both are free.
8. **Readable when shared.** The label must stand out at a large font through video compression;
   the `Comment` colour gitsigns' blame uses is faint.
9. **A privacy guard.** Which repositories may send code to a model? A per-project opt-in, such as a
   marker file in the repository or an environment variable?
10. **Line budget.** `init.lua` is at 1150 of its 1200 lines. A facts-only label is about 15 lines
    (a gitsigns formatter and a key); the model explanation roughly 30–40 more.
11. **Platforms.** `claude` is installed on Windows and in WSL; `gh` only on Windows so far.

## Sources

- gitsigns' blame options were read from the installed source (`lua/gitsigns/config.lua`,
  `actions/blame_line.lua`); fzf-lua's line-range history from `providers/git.lua`.
- [trace-pr.nvim](https://github.com/delphinus/trace-pr.nvim),
  [gh-blame.nvim](https://dotfyle.com/plugins/dlvhdr/gh-blame.nvim),
  [git-blame.nvim](https://erock-neovimcraft-1782466063.pgs.sh/plugin/f-person/git-blame.nvim/),
  [blamer.nvim](https://github.com/psjay/blamer.nvim)
- [CodeCompanion.nvim](https://www.github.com/olimorris/codecompanion.nvim) and its
  [inline assistant](https://codecompanion.olimorris.dev/usage/inline-assistant)
- [CopilotChat.nvim](https://github.com/copilotc-nvim/copilotchat.nvim),
  [avante.nvim commands](https://www.mintlify.com/yetone/avante.nvim/api/commands)
- [claudecode.nvim](https://github.com/coder/claudecode.nvim)
- [git-why (PyPI)](https://pypi.org/project/git-why/),
  [git-why (hexapode)](https://github.com/hexapode/git-why),
  [lore](https://awesome.ecosyste.ms/projects/github.com%2Ftt-a1i%2Flore),
  [commit-archaeologist](https://tessl.io/registry/skills/github/Shubhamsaboo/awesome-llm-apps/commit-archaeologist),
  [git-context-mcp](https://enterprisedna.co/directories/mcp/muhannad-hash-git-context-mcp),
  [semblame](https://awesome.ecosyste.ms/projects/github.com%2Fvasilisp%2Fsemblame)
