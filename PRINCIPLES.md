# Working principles

Neovim is my main, default and only editor. This document says what the editor, and the work
environment around it, are for, so every addition, change or removal of a plugin, tool or setting can
be judged against it. That environment is a custom Arch Linux desktop set up for software
development, with this configuration at its centre; the same configuration also runs on Windows and
WSL.

## What the editor is for

1. **Focus.** The editor protects my focus, and ideally improves it. Getting into focus is easy, and
   staying there takes no effort. Nothing claims my attention unless I asked for it.
2. **Context.** It is easy to stay in the context of the work in hand, and to get back into it after
   an interruption.
3. **The big picture.** It is easy to see and inspect the big picture: how what I am doing fits into
   it, and how the picture changes as I work. Moving between levels of abstraction is easy, the way a
   C4 diagram moves from system context to containers, components and code.

## The skills it should strengthen

My three most important skills as a software developer:

1. **Initiative**: choosing a direction and starting to move towards it.
2. **Problem solving**: analysing an obstacle and finding a way through it.
3. **Determination**: moving towards the target at a steady, sustainable pace, one step at a time.

The work environment should make each of these easier to exercise. It should not exercise them for me.

## Practices that support them

| Skill | Practice |
|---|---|
| Initiative | **A small first step**: break the task down until its first step takes 15 minutes or less. |
| Initiative | **One thing a day** (focus): each morning, write down the one thing to accomplish that day. |
| Initiative | **Hardest first** (alertness): do the most demanding work while alertness and energy are highest. |
| Problem solving | **No interruptions** (focus): notifications off, phone put away. |
| Problem solving | **Quiet time** (focus): reserve uninterrupted time in the calendar. |
| Problem solving | **Breaks**: remember to take them. |
| Determination | **A clear goal**: agree the goal, and what "ready" means. |
| Determination | **Visible status**: make progress visible. |
| Determination | **Energy for the long run**: take breaks, work in periods of 60–90 minutes at most, finish the day at the right time, and sleep. |

Getting tired wears down self-regulation.

## Mastery: keeping the craft

Writing code by hand keeps the most important skill in shape. The brain is not a muscle, but it
behaves like one: it adapts to what it is repeatedly asked to do. Skills that are practised grow
stronger; skills that are not slowly fade, usually unnoticed until they are needed.

Mastery here follows the Japanese view: not a quick talent or a final destination, but a lifelong
practice built on structure, reflection and patience.

| Idea | Meaning |
|---|---|
| *Shuhari* | First learn the form, then break it, then go beyond it. |
| *Shokunin kishitsu* | The craftsperson's pride in doing the work well, every day. |
| *Kaizen* | Small improvements, continuously. |
| *Hansei* | Honest reflection on what could be better. |

Mastery is not something I have, but something I keep, by staying in daily touch with the code rather
than handing the thinking away. The editor's job is to make moving around and staying on top of
things fast, easy and convenient, while the thinking and the writing stay with me.

## What this implies for my Neovim configuration and tooling

### The test for every change

Before adding, changing or removing a plugin, tool, key or setting:

1. **Focus.** Does it interrupt, add noise, or ask for attention I did not request? Anything that
   appears uninvited fails, unless it reports something I must act on now.
2. **Context.** Does it help me stay with the work in hand, or get back to it?
3. **Big picture.** Does it help me see how the work fits, or move between levels?
4. **Mastery.** Does it keep me thinking and writing the code, or does it think and write for me?
5. **Minimal.** Is it worth its keys, its lines in `init.lua` and its start-up time? Could something
   Neovim already has do the job? (The aim, in AGENTS.md: optimal, minimal and powerful.)

A change that is merely convenient, but fails focus or mastery, stays out.

### Focus

Already in place:

- **Quiet by default.** The mouse is off; nothing formats on save; completion documentation opens
  only on `<C-space>`; which-key appears only after a pause; trailing whitespace is marked only
  outside insert mode.
- **No notification plugin.** Messages stay on the command line.
- **Little chrome.** One statusline, no tab or buffer bar, no file tree.
- **Zen mode** on `<leader>uz`.

What follows:

- **One focus toggle.** Zen mode plus hiding inline diagnostics, git signs and inline blame, all
  restored afterwards. The same toggle serves presenting in reviews
  ([FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md)).
- **No text that writes itself.** No AI ghost text or auto-inserted suggestions (see Mastery).
- **Work periods shown quietly.** A 60–90 minute timer in a statusline segment or the desktop bar,
  never a pop-up in the middle of a thought.

### Context

Already in place:

- **Sessions** per directory and git branch, saved on quit and restored on request (`<leader>Ss`).
- **A way back.** The jump list works as a stack and restores the view (`<C-o>`, `<C-i>`); `g;` walks
  the change list; undo history persists, with `<leader>uu` to browse it.
- **A terminal that remembers.** `<leader>t` keeps its shell and scrollback between toggles.

What follows:

- **The task lives next to the code.** A short plain-text note per project or branch holds the day's
  one thing, the next small step, and what "ready" means. One key opens it: `<leader>n` is already
  reserved for notes. Plain markdown with checkboxes; no task-manager plugin.
- **The current task in sight.** The note's first line can show in the statusline, so the context is
  never more than a glance away.
- **Leave a first step for tomorrow.** Before stopping, write down the next step, so the next session
  starts small.

### The big picture and levels of abstraction

| C4 level | Question | Tools here |
|---|---|---|
| System context | What is the system for, and who and what does it talk to? | Diagrams as code in the repository, in Mermaid (which has C4 diagram types, marked experimental), previewed with `<leader>up` |
| Containers | Which applications, services and data stores make it up? | The same diagrams; `-` (oil) to walk the repository's structure |
| Components | Which modules live inside a container, and how do they depend on each other? | `<leader>sS` (project symbols), `<leader>ci` / `<leader>co` (call hierarchy), semantic search ([FEATURE-SEMANTIC-SEARCH.md](FEATURE-SEMANTIC-SEARCH.md)) |
| Code | How does this part work? | `K`, `grd`, `grr`, `gO`, `äm` / `öm`, textobjects, folds |

- **Zooming out:** `zM` (signatures only), `gO` or `<leader>ss` (the file's outline), `-` (up a
  directory), `<C-o>` (back where you came from).
- **Zooming in:** `grd`, `<CR>`, `zo`.
- **How the picture changes:** `<leader>gl` and `<leader>gL` for history; a branch compared with
  `main` through gitsigns; the commit views proposed in
  [FEATURE-COMMIT-FILES.md](FEATURE-COMMIT-FILES.md) and [FEATURE-COMMIT-VIEW.md](FEATURE-COMMIT-VIEW.md).

What follows:

- **Architecture diagrams live as text in each repository**, next to the code they describe, so they
  are reviewed and changed along with it.
- **Zoom keys over permanent panels.** An outline or file tree always on screen costs focus; keys that
  zoom on demand do not.

### Initiative

- **Low friction to start.** Neovim starts fast; sessions and recent files (`<leader>s.`) put the work
  back in front of me.
- **The next step is written down.** The task note's top line is the next step of 15 minutes or less.
- **Hardest work first.** Sessions are restored by hand, never automatically, so the day can open on
  the most demanding task rather than on whatever was open last.

### Problem solving

- **The tools for an obstacle are within reach:** exact searches, the language server's navigation
  and call hierarchy, the debugger (`F5`, `<leader>D`), tests (`<leader>T`), git history and blame,
  and the undo tree for comparing attempts. Semantic search is proposed.
- **Writing the problem down clarifies it.** The task note doubles as a place to think.
- **AI as a sparring partner, on request.** For explaining, reviewing and questioning, called on
  explicitly, with inferred answers labelled as such
  ([FEATURE-EXPLAIN-LINE.md](FEATURE-EXPLAIN-LINE.md)).

### Determination and visible progress

- **"Ready" is a checklist** in the task note; progress is the ticked items.
- **Small commits, one per change**, as AGENTS.md already requires. The git log is the visible trail
  (`<leader>gl`).
- **Tests as the progress signal.** `<leader>Tl` reruns the last test from anywhere.
- **Work periods and the end of the day**, as under Focus.

### Mastery

- **Writing by hand stays the default.** Completion offers what the language server and snippets
  know, and inserts only on `<C-y>`. Nothing writes code into the buffer unasked.
- **AI on request, for understanding.** Explaining, reviewing and searching, invoked explicitly;
  never generating code silently.
- **Shuhari.** Learn Neovim's own forms first. Most keys here are Neovim's own, and new ones follow its
  conventions (KEYBINDINGS.md, "Why the keys are where they are"). Break the form knowingly, one
  change at a time.
- **Shokunin kishitsu.** The tools of quality are always at hand and quiet: format on demand,
  linters on save, the ruler, tests, the debugger.
- **Kaizen.** One small improvement at a time, one commit each.
- **Hansei.** Review the configuration regularly. Remove what is not used; PLUGINS.md's "Things
  intentionally not installed" records what was taken out and why. After each new feature, ask
  whether it served focus, context and the big picture.

### The Arch Linux desktop around it

Some of this belongs to the desktop, not the editor:

- **Do not disturb** in the notification daemon during work periods. The editor cannot stop chat
  pop-ups.
- **The work-period timer and break reminder** in the desktop's status bar, visible over every
  application, not only Neovim.
- **One workspace per context**: editor, browser preview and terminal together, so switching context
  is a deliberate act.
- **Terminal font and colours** chosen for long sessions, and legible when the screen is shared.
- **One configuration everywhere.** Neovim's configuration stays the same on Arch, WSL and Windows;
  platform differences stay inside `init.lua`.

### Candidate changes

None of these is implemented; each needs its own approval and its own commit.

| Change | Serves | Rough size in `init.lua` |
|---|---|---|
| A focus toggle: zen mode, and inline diagnostics, signs and blame hidden | Focus, presenting | 10 lines |
| A task note per project or branch on `<leader>n` | Initiative, context, determination | 10 lines |
| The current task in the statusline | Context | 5 lines |
| A work-period timer, in the statusline or (better) the desktop bar | Determination, energy | 15 lines, or none on the desktop |
| Architecture diagrams as Mermaid in each repository | The big picture | none |
| The four feature proposals (`FEATURE-*.md`) | The big picture, presenting | see each |

`init.lua` is at 1150 of its 1200 lines.
