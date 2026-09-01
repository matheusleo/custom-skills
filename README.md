# Custom Skills & Config

Personal configuration repository for opencode and Claude Code tools, including skills, plugins, and behavioral instructions.

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
├── skills/
│   ├── global/         # Skills available across all projects
│   │   ├── meeting-transcriber
│   │   ├── peon-ping-config
│   │   ├── peon-ping-log
│   │   ├── peon-ping-toggle
│   │   ├── peon-ping-use
│   │   └── status-tracker
│   └── project/        # Project-specific skills (copy as needed)
│       ├── e2e-testing-patterns
│       ├── find-skills
│       ├── next-best-practices
│       └── vammo-ui
└── scripts/
    ├── setup-opencode.sh       # Setup script for opencode
    └── setup-claude.sh         # Setup script for Claude Code
```

## Setup

### Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated
- [opencode](https://opencode.ai/) installed (for opencode setup)
- [Claude Code](https://docs.claude.com/en/docs/claude-code) installed (for Claude setup)

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

### What the scripts do

Both scripts will:
- Create necessary directories (`~/.config/opencode`, `~/.claude`, `~/.agents/skills`)
- Copy configuration files to their appropriate locations
- Install global skills
- Leave project-specific skills in the repo for manual copying

**Note:** The scripts will skip files that already exist to avoid overwriting your local changes.

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
