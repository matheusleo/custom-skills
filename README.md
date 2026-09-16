# Custom Skills & Config

Personal configuration repository for Codex, opencode, and Claude Code tools, including skills, plugins, and behavioral instructions.

## Structure

```
.
├── opencode/           # Opencode configuration
│   ├── opencode.jsonc          # Main config (plugins, permissions, instructions)
│   ├── oh-my-openagent.jsonc   # Custom agent fallbacks
│   ├── instructions.md         # Opencode-specific instructions
│   ├── tui.json                # TUI configuration
│   └── plugins/                # Custom plugins
│       ├── peon-ping.ts
│       └── rtk-hook.ts
├── claude/             # Claude Code configuration (shared with opencode)
│   ├── CLAUDE.md               # Main entry point
│   ├── RTK.md                  # Token-saving proxy guide
│   ├── COMMUNICATION.md        # Communication defaults
│   ├── SELF_IMPROVEMENT.md     # Self-improvement rules
│   ├── POWER_UPGRADES.md       # Recommended tools & plugins
│   └── VAMMO_ENG.md            # Vammo engineering conventions
├── codex/              # Codex configuration
│   ├── AGENTS.md               # Global working agreement
│   ├── config.toml             # Portable model and TUI defaults
│   └── hooks.json              # Orca and peon-ping lifecycle hooks
├── skills/
│   ├── global/         # Skills available across all projects
│   │   ├── find-skills
│   │   ├── humanizer
│   │   ├── meeting-transcriber
│   │   ├── peon-ping-config
│   │   ├── peon-ping-log
│   │   ├── peon-ping-toggle
│   │   ├── peon-ping-use
│   │   ├── my-custom-review
│   │   ├── orchestration
│   │   └── status-tracker
│   └── project/        # Project-specific skills (copy as needed)
│       ├── e2e-testing-patterns
│       ├── find-skills
│       ├── next-best-practices
│       └── vammo-ui
└── scripts/
    ├── setup-opencode.sh       # Setup script for opencode
    ├── setup-claude.sh         # Setup script for Claude Code
    └── setup-codex.sh          # Setup script for Codex
```

## Setup

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- [opencode](https://opencode.ai/) installed (for opencode setup)
- [Claude Code](https://docs.claude.com/en/docs/claude-code) installed (for Claude setup)
- [Codex](https://developers.openai.com/codex/cli/) installed (for Codex setup)

### Quick Start

1. Clone this repository:
```bash
git clone https://github.com/matheusleo/custom-skills.git
cd custom-skills
```

2. Run the setup scripts:

**For opencode:**
```bash
./scripts/setup-opencode.sh
```

**For Claude Code:**
```bash
./scripts/setup-claude.sh
```

**For Codex:**
```bash
./scripts/setup-codex.sh
```

### What the scripts do

Both scripts will:
- Create necessary directories (`~/.config/opencode`, `~/.claude`, `~/.agents/skills`)
- Copy configuration files to their appropriate locations
- Install global skills
- Leave project-specific skills in the repo for manual copying

**Note:** The scripts will skip files that already exist to avoid overwriting your local changes.

The Codex setup installs global instructions in `~/.codex/AGENTS.md`, portable
model and TUI defaults in `~/.codex/config.toml`, lifecycle hooks in
`~/.codex/hooks.json`, and global skills in `~/.agents/skills`. Project trust
entries, auth, history, and hook trust hashes remain local to each machine.

## Maintenance

When you add new skills or modify configs:

1. Update the files in this repository
2. Commit and push:
```bash
git add .
git commit -m "feat: add new skill X"
git push
```

3. On other machines, pull and re-run the setup scripts:
```bash
git pull
./scripts/setup-opencode.sh
./scripts/setup-claude.sh
./scripts/setup-codex.sh
```

## Adding New Skills

### Global Skills (available everywhere)

1. Create a new directory under `skills/global/`
2. Add your skill files (typically `SKILL.md`)
3. Run the setup scripts on all machines

### Project-Specific Skills

1. Create a new directory under `skills/project/`
2. Copy it to your project's `.claude/skills/` or `.opencode/skills/` directory
3. Commit the skill to this repo for backup and sharing

## License

Personal use only.
