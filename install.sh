#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"

uninstall=false
if [[ "${1:-}" == "--uninstall" ]]; then
  uninstall=true
fi

# Check prerequisites
if $uninstall; then
  echo "Uninstalling gsd-superpowers-bridge..."
else
  echo "Installing gsd-superpowers-bridge..."

  if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "Error: $SKILLS_DIR not found. Is Claude Code installed?"
    exit 1
  fi

  gsd_found=$(ls "$SKILLS_DIR"/gsd-do/SKILL.md 2>/dev/null || true)
  if [[ -z "$gsd_found" ]]; then
    echo "Warning: GSD skills not found in $SKILLS_DIR. Install GSD first."
  fi
fi

# Install/uninstall skills
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  target="$SKILLS_DIR/$skill_name"

  if $uninstall; then
    if [[ -d "$target" ]]; then
      rm -rf "$target"
      echo "  Removed skill: $skill_name"
    fi
  else
    mkdir -p "$target"
    cp "$skill_dir"/* "$target/" 2>/dev/null || true
    echo "  Installed skill: $skill_name"
  fi
done

# Install/uninstall agents
for agent_file in "$SCRIPT_DIR"/agents/*.md; do
  [[ -f "$agent_file" ]] || continue
  agent_name=$(basename "$agent_file")
  target="$AGENTS_DIR/$agent_name"

  if $uninstall; then
    if [[ -f "$target" ]]; then
      rm "$target"
      echo "  Removed agent: $agent_name"
    fi
  else
    cp "$agent_file" "$target"
    echo "  Installed agent: $agent_name"
  fi
done

if $uninstall; then
  echo "Uninstall complete. Remove agent_skills config from .planning/config.json if set."
else
  echo "Install complete. Configure modules in .planning/config.json to enable."
fi
