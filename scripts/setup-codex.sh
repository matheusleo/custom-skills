#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_HOME="$HOME/.agents/skills"

mkdir -p "$CODEX_HOME" "$SKILLS_HOME"

install_if_missing() {
  local source="$1" target="$2"
  if [ -e "$target" ]; then
    echo "Skipping existing $target"
    return
  fi
  cp -R "$source" "$target"
  echo "Installed $target"
}

install_if_missing "$REPO_ROOT/codex/AGENTS.md" "$CODEX_HOME/AGENTS.md"
install_if_missing "$REPO_ROOT/codex/config.toml" "$CODEX_HOME/config.toml"
install_if_missing "$REPO_ROOT/codex/hooks.json" "$CODEX_HOME/hooks.json"

for skill in "$REPO_ROOT"/skills/global/*; do
  [ -d "$skill" ] || continue
  install_if_missing "$skill" "$SKILLS_HOME/$(basename "$skill")"
done

echo "Codex setup complete. Restart Codex, then use /hooks to review any newly installed hooks."
