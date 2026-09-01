# opencode global setup

<!-- User profile -->
- **Name**: Matheus
- **Role / team**: Architect/planner — designs implementation plans with a separate planning agent; the assistant implements
- **Engineer**: yes
- **Languages & tone**: English, neutral
- **Current focus**: maestro frontend (Next.js App Router, hexagonal architecture, service orders / parts-return)
- **Setup origin**: adapted from a Claude Code (Guima) setup; the behavioural rules live in `~/.claude/*.md` and are shared across both tools via the `instructions` list in `~/.config/opencode/opencode.jsonc`

## How this setup is organised
The behavioural instructions (communication, engineering workflow, self-improvement, power-upgrades, RTK) are the same files Claude Code loads via `@imports` in `~/.claude/CLAUDE.md`. Edit those files once; both tools pick them up.

## Tool-specific caveats
- The "Superpowers skill discipline" section of `VAMMO_ENG.md` references Claude Code's `superpowers` plugin skills invoked via the Skill tool. opencode does not have those skills — treat that table as Claude-specific and only invoke skills that appear in opencode's available skills.
- `RTK.md` describes the `rtk` token-saving proxy. In opencode, Bash commands are auto-rewritten by the `rtk-hook` plugin (equivalent to Claude's `rtk hook claude`), so `git status` transparently becomes `rtk git status`.
- References to "Claude Code" / the `!` prefix in `COMMUNICATION.md` are Claude-specific; opencode has no `!` bash prefix — run such commands in your own terminal instead.
