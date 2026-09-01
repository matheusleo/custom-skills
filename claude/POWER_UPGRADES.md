# Power-user upgrades

These are recommendations, not required. Mention them in the onboarding setup checklist (one line each) and offer to walk through any on request.

## If you're on Claude Desktop: switch to Claude Code

Claude Desktop is great for chat, but Claude Code unlocks the full setup:
- File edits, Bash, and MCP servers
- Persistent memory across sessions
- Slash commands and custom skills
- Plugins (frontend-design, superpowers, feature-dev, …)
- Hooks that fire on every tool call / session event
- Status line, voice mode, parallel subagents

**Install:** see https://docs.claude.com/en/docs/claude-code (official docs). Quickstart for macOS:

```
brew install --cask claude-code
claude        # first run sets up auth
```

**Use this same prompt:** paste it into `~/.claude/CLAUDE.md` (global, applies to every project) or `.claude/CLAUDE.md` inside a specific repo (project-only scope).

## Recommended plugins (Claude Code)

Install via the `/plugin` slash command (or `claude plugin install <name>@<marketplace>`):

- **superpowers** — essential. Unlocks the skill discipline in the engineering rules.
- **claude-md-management** — audit and improve `CLAUDE.md` files.
- **commit-commands** — `/commit`, `/commit-push-pr` shortcuts.
- **feature-dev** — guided feature dev with codebase analysis.
- **frontend-design** — distinctive UIs without generic AI aesthetics. (Yes, even backend folks will use this someday.)
- **claude-hud** — statusline with cost / context usage / git state. Install from the `jarrodwatts/claude-hud` marketplace.

## Recommended companion tools

- **RTK (Rust Token Killer)** — CLI proxy that rewrites common dev commands into token-cheap forms (60–90% savings on file/git ops). Hook-based; once installed, it's transparent.
- **Warp.Dev terminal** — modern terminal with native Claude Code integration via the `warp@claude-code-warp` plugin. Worth trying if you live in the terminal.
- **Chief** (https://chiefloop.com) — orchestrates Claude Code (and other agents) to break work into tasks and ship one-commit-per-task. Install: `brew install minicodemonkey/chief/chief`.
- **browser-harness** — direct browser control via CDP for tasks that need real navigation (forms behind auth, scraping, doc rendering). Useful when a screen-reading MCP can't do the job.

## Optional quality-of-life
- **Voice mode** (`hold` recommended) — talk to Claude instead of typing.
- **`effortLevel: "xhigh"`** in `~/.claude/settings.json` for hard tasks (more compute, slower, deeper).
- **Custom statusline** (claude-hud handles this).
- **Sound notifications** — peon-ping or similar — fun and useful for long-running work where you want an audio cue when Claude finishes.
