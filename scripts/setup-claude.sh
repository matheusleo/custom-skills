#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Setting up Claude Code configuration...${NC}"

# Create necessary directories
mkdir -p ~/.claude
mkdir -p ~/.claude/skills

# Copy config files
echo -e "${YELLOW}Copying config files...${NC}"
cp -r "$REPO_ROOT/claude/CLAUDE.md" ~/.claude/ 2>/dev/null || echo -e "${YELLOW}CLAUDE.md already exists, skipping${NC}"
cp -r "$REPO_ROOT/claude/RTK.md" ~/.claude/ 2>/dev/null || echo -e "${YELLOW}RTK.md already exists, skipping${NC}"
cp -r "$REPO_ROOT/claude/COMMUNICATION.md" ~/.claude/ 2>/dev/null || echo -e "${YELLOW}COMMUNICATION.md already exists, skipping${NC}"
cp -r "$REPO_ROOT/claude/SELF_IMPROVEMENT.md" ~/.claude/ 2>/dev/null || echo -e "${YELLOW}SELF_IMPROVEMENT.md already exists, skipping${NC}"
cp -r "$REPO_ROOT/claude/POWER_UPGRADES.md" ~/.claude/ 2>/dev/null || echo -e "${YELLOW}POWER_UPGRADES.md already exists, skipping${NC}"
cp -r "$REPO_ROOT/claude/VAMMO_ENG.md" ~/.claude/ 2>/dev/null || echo -e "${YELLOW}VAMMO_ENG.md already exists, skipping${NC}"

# Copy global skills (shared between claude and opencode)
echo -e "${YELLOW}Installing global skills...${NC}"
cp -r "$REPO_ROOT/skills/global/"* ~/.claude/skills/ 2>/dev/null || true

# Note about project-specific skills
echo -e "${YELLOW}Note: Project-specific skills are in $REPO_ROOT/skills/project/${NC}"
echo -e "${YELLOW}Copy them to your project's .claude/skills/ directory as needed${NC}"

echo -e "${GREEN}✓ Claude Code setup complete!${NC}"
echo -e "${BLUE}Your Claude Code configuration is ready to use${NC}"
