# Global Instructions

## Commits

- Use Conventional Commits: `type(scope): subject`, with scope optional. Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `style`, `revert`.
- Subject line only. No body, no trailers.
- Lowercase, imperative mood, no trailing period, under ~72 chars.

## Browser QA

- Use the `browser-control` skill to QA anything in a browser: verifying UI changes, clicking through flows, checking console and network.
- Prefer it over the Playwright MCP plugin or claude-in-chrome unless the task calls for those.

## Writing

- Before writing or editing prose (docs, READMEs, PR descriptions, release notes, comments meant for people, UI copy), read `~/.claude/skills/unslop/SKILL.md` and apply its rules.
- The skill can't be invoked through the Skill tool (`disable-model-invocation`), so read the file directly.

## Herdr

I run Claude Code inside Herdr, a terminal workspace manager for coding agents. When `HERDR_ENV=1`, use `herdr` proactively where it improves the workflow. No need to wait for me to mention it.

- Run `herdr --skill` once per session before the first control command; it is the reference for syntax and IDs. Treat the installed CLI as the authority (`herdr <group>` prints a group's commands).
- Good uses:
  - Run long-lived processes (dev servers, watchers, log tails) in a herdr tab instead of a background shell, so I can see them.
  - Read output from neighboring panes (`herdr pane read`) when debugging something I'm running.
- Never split my current tab. Put your processes in a separate tab so my view stays clean:
  - Create it in the background with a short label naming the project and what runs there (e.g. `goatside: vite`, `goatside: sqld`):
    `herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd <dir> --label "<label>" --no-focus`
  - Start the process with `herdr pane run <root_pane.pane_id> '<command>'`, using the pane ID from the create response.
  - For related processes, split panes inside that tab, not in mine.
  - Before creating a tab, check `herdr tab list` and reuse one you already made for the same purpose.
  - Close your tabs when the work is done, unless I'm still using the server.
  - Use `herdr worktree` for isolated parallel work.
  - Send a `herdr notification show` when a long task finishes or needs my input.
- Target your own pane with `--current` or `$HERDR_PANE_ID`. An omitted target may hit the pane I'm focused on.
- Never run bare `herdr`; it attaches the TUI.
- Don't close panes, tabs, or workspaces you didn't create, and don't send input to my panes or other agents unless I ask.
