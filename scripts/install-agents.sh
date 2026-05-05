#!/bin/bash

# Install Agent Definitions to Cursor and Claude
# Copies to Cursor (doesn't follow symlinks), symlinks to Claude
#
# Usage:
#   ./install-agents.sh              # Install all agents (default)
#   ./install-agents.sh <agent-name> # Install only the named agent (with or without .md)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_AGENTS_DIR="$HOME/.cursor/agents"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
PACKAGES_DIR="$REPO_DIR/packages/agents"

# Optional: install only this agent (e.g. "daily-briefer" or "daily-briefer.md")
TARGET_AGENT="${1:-}"

if [ -n "$TARGET_AGENT" ]; then
  # Normalize: strip .md if present for matching
  TARGET_BASE="${TARGET_AGENT%.md}"
  echo "Installing single agent: $TARGET_BASE"
else
  echo "Installing all agent definitions..."
fi
echo ""

# Create agent directories if they don't exist
mkdir -p "$CURSOR_AGENTS_DIR"
mkdir -p "$CLAUDE_AGENTS_DIR"
mkdir -p "$PACKAGES_DIR"

# Counter for agents installed
COUNT=0
PACKAGE_COUNT=0

# Check if agents directory exists
if [ ! -d "$REPO_DIR/agents" ]; then
  echo "❌ No agents directory found in repository"
  exit 1
fi

# Helper function to copy to Cursor
copy_to_cursor() {
  local source="$1"
  local target="$2"

  # Remove existing file or symlink
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -f "$target"
  fi

  # Copy file
  cp "$source" "$target"
}

# Helper function to symlink to Claude
symlink_to_claude() {
  local source="$1"
  local target="$2"

  # Remove existing symlink or file
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -f "$target"
  fi

  # Create symlink
  ln -s "$source" "$target"
}

# Helper function to package agent as zip
package_agent() {
  local agent_file="$1"
  local source_file="$2"
  local agent_name="${agent_file%.md}"
  local temp_dir=$(mktemp -d)
  
  # Create agent directory structure in temp
  mkdir -p "$temp_dir/$agent_name"
  cp "$source_file" "$temp_dir/$agent_name/"
  
  # Create zip archive (cd to temp dir to avoid absolute paths)
  cd "$temp_dir"
  zip -r "$agent_name.zip" "$agent_name" > /dev/null 2>&1
  
  # Move zip to packages directory
  mv "$agent_name.zip" "$PACKAGES_DIR/"
  
  # Clean up temp directory
  rm -rf "$temp_dir"
  
  cd "$REPO_DIR"
}

# Find and install agent definition files (all or single target)
cd "$REPO_DIR/agents"
FOUND=0
for agent_file in *.md; do
  # Skip README
  if [ "$agent_file" = "README.md" ]; then
    continue
  fi

  # Check if file exists (handles case where no .md files exist)
  if [ ! -f "$agent_file" ]; then
    continue
  fi

  agent_base="${agent_file%.md}"

  # Single-agent mode: only install the requested agent
  if [ -n "$TARGET_AGENT" ] && [ "$agent_base" != "$TARGET_BASE" ]; then
    continue
  fi

  echo "Installing $agent_file..."

  # Copy to Cursor
  copy_to_cursor "$REPO_DIR/agents/$agent_file" "$CURSOR_AGENTS_DIR/$agent_file"
  echo "  ✓ Copied to Cursor"

  # Symlink to Claude
  symlink_to_claude "$REPO_DIR/agents/$agent_file" "$CLAUDE_AGENTS_DIR/$agent_file"
  echo "  ✓ Symlinked to Claude"

  # Package for deployment (use absolute path; package_agent changes cwd)
  package_agent "$agent_file" "$REPO_DIR/agents/$agent_file"
  cd "$REPO_DIR/agents"
  echo "  ✓ Packaged for deployment"

  ((COUNT++))
  ((PACKAGE_COUNT++))
  FOUND=1
  echo ""

  # Single-agent mode: we're done
  if [ -n "$TARGET_AGENT" ]; then
    break
  fi
done

if [ -n "$TARGET_AGENT" ] && [ "$FOUND" -eq 0 ]; then
  echo "❌ No agent found: $TARGET_AGENT (expected a .md file in agents/ e.g. $TARGET_BASE.md)"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Installed $COUNT agent(s) to both platforms"
echo "✓ Created $PACKAGE_COUNT deployment package(s)"
echo ""
echo "Agents are now available at:"
echo "  Cursor: $CURSOR_AGENTS_DIR (copies - run install script after changes)"
echo "  Claude: $CLAUDE_AGENTS_DIR (symlinks - changes auto-reflected)"
echo ""
echo "Deployment packages created at:"
echo "  $PACKAGES_DIR"
echo ""
echo "Note: Cursor requires re-running this script after agent changes."
echo "      Claude changes are immediately reflected via symlinks."
echo "      Deployment packages are suitable for Claude Desktop/Cowork."
echo ""
echo "Usage:"
echo "  'Use [agent-name] agent to [task]'"
echo ""
echo "Example:"
echo "  'Use meeting-analyzer agent to analyze my staff meeting'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
