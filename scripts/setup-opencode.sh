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

echo -e "${BLUE}Setting up opencode configuration...${NC}"

# Create necessary directories
mkdir -p ~/.config/opencode/plugins
mkdir -p ~/.agents/skills
mkdir -p ~/.opencode/bin

# Copy config files
echo -e "${YELLOW}Copying config files...${NC}"
cp -r "$REPO_ROOT/opencode/opencode.jsonc" ~/.config/opencode/ 2>/dev/null || echo -e "${YELLOW}opencode.jsonc already exists, skipping${NC}"
cp -r "$REPO_ROOT/opencode/oh-my-openagent.jsonc" ~/.config/opencode/ 2>/dev/null || echo -e "${YELLOW}oh-my-openagent.jsonc already exists, skipping${NC}"
cp -r "$REPO_ROOT/opencode/instructions.md" ~/.config/opencode/ 2>/dev/null || echo -e "${YELLOW}instructions.md already exists, skipping${NC}"
cp -r "$REPO_ROOT/opencode/tui.json" ~/.config/opencode/ 2>/dev/null || echo -e "${YELLOW}tui.json already exists, skipping${NC}"

# Copy plugins
echo -e "${YELLOW}Copying plugins...${NC}"
cp -r "$REPO_ROOT/opencode/plugins/"* ~/.config/opencode/plugins/ 2>/dev/null || true

# Copy global skills
echo -e "${YELLOW}Installing global skills...${NC}"
cp -r "$REPO_ROOT/skills/global/"* ~/.agents/skills/ 2>/dev/null || true

# Note about project-specific skills
echo -e "${YELLOW}Note: Project-specific skills are in $REPO_ROOT/skills/project/${NC}"
echo -e "${YELLOW}Copy them to your project's .claude/skills/ directory as needed${NC}"

echo -e "${GREEN}✓ Opencode setup complete!${NC}"
echo -e "${BLUE}Run 'opencode' to start using your configured setup${NC}"
