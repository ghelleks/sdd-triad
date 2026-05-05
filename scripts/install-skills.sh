#!/bin/bash

# Install Skills to Cursor and Claude
# Copies to Cursor (doesn't follow symlinks), symlinks to Claude
#
# Usage:
#   ./install-skills.sh              # Install all skills (default)
#   ./install-skills.sh <skill-name>  # Install only the named skill

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURSOR_SKILLS_DIR="$HOME/.cursor/skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
PACKAGES_DIR="$REPO_DIR/packages/skills"

# Optional: install only this skill (e.g. "day-planner" or "shared")
TARGET_SKILL="${1:-}"

# ── Peer check (optional) ─────────────────────────────────────────────────────
# Some skills reference shared modules from optional peer repos (e.g. calendar-research,
# document-extraction, parallel-fetch). These are not required for core functionality.
if [ -f "$CLAUDE_SKILLS_DIR/shared/calendar-research.md" ]; then
  echo "✓ Optional peer modules detected (calendar-research, etc.)"
else
  echo "ℹ  Optional peer modules not found (calendar-research, etc.)"
  echo "   Some skills may have reduced functionality without them."
  echo "   This is fine for standalone use."
fi
echo ""

if [ -n "$TARGET_SKILL" ]; then
  echo "Installing single skill: $TARGET_SKILL"
else
  echo "Installing all skills to Cursor and Claude..."
fi
echo ""

# Create directories
mkdir -p "$CURSOR_SKILLS_DIR"
mkdir -p "$CLAUDE_SKILLS_DIR"
mkdir -p "$PACKAGES_DIR"

COUNT=0
PACKAGE_COUNT=0

# Helper function to copy to Cursor (removes existing first)
copy_to_cursor() {
  local source="$1"
  local target="$2"

  # Remove existing directory or symlink
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -rf "$target"
  fi

  # Copy directory
  cp -R "$source" "$target"
}

# Helper function to symlink to Claude
symlink_to_claude() {
  local source="$1"
  local target="$2"

  # Remove existing symlink or directory
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -rf "$target"
  fi

  # Create symlink
  ln -s "$source" "$target"
}

# If a skills directory is currently a directory symlink (legacy install), convert it to a
# real directory so multiple repos can each install files additively without conflict.
ensure_real_dir() {
  local dir="$1"
  if [ -L "$dir" ]; then
    local target
    target="$(readlink "$dir")"
    echo "  Migrating $dir from directory symlink → real directory..."
    rm "$dir"
    mkdir -p "$dir"
    # Re-populate with per-file symlinks from the old symlink target (if it still exists)
    if [ -d "$target" ]; then
      for f in "$target/"*.md; do
        [ -f "$f" ] || continue
        ln -sf "$f" "$dir/$(basename "$f")"
      done
    fi
  else
    mkdir -p "$dir"
  fi
}

# Helper function to install shared/ files additively (file-by-file, non-destructive).
# Other repos (e.g. workboard-skills) also write into shared/ — don't wipe their files.
install_shared_additive() {
  local source_dir="$1"
  local cursor_shared="$2"
  local claude_shared="$3"

  # Convert legacy directory symlinks to real directories before writing into them
  ensure_real_dir "$cursor_shared"
  ensure_real_dir "$claude_shared"

  for f in "$source_dir/"*.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    cp "$f" "$cursor_shared/$fname"          # Cursor: real copy (no symlink support)
    ln -sf "$f" "$claude_shared/$fname"      # Claude: per-file symlink
  done

  # Also copy lib/ subdirectory (Python utility modules used by skill scripts).
  # Cursor requires real copies; Claude uses per-file symlinks.
  if [ -d "$source_dir/lib" ]; then
    mkdir -p "$cursor_shared/lib"
    mkdir -p "$claude_shared/lib"
    for f in "$source_dir/lib/"*; do
      [ -f "$f" ] || continue
      fname=$(basename "$f")
      cp "$f" "$cursor_shared/lib/$fname"
      ln -sf "$f" "$claude_shared/lib/$fname"
    done
  fi
}

# Helper function to package skill as zip
package_skill() {
  local skill_name="$1"
  local source_dir="$2"
  local temp_dir=$(mktemp -d)
  
  # Copy skill files to temp directory
  cp -R "$source_dir" "$temp_dir/$skill_name"
  
  # Create zip archive (cd to temp dir to avoid absolute paths)
  cd "$temp_dir"
  zip -r "$skill_name.zip" "$skill_name" > /dev/null 2>&1
  
  # Move zip to packages directory
  mv "$skill_name.zip" "$PACKAGES_DIR/"
  
  # Clean up temp directory
  rm -rf "$temp_dir"
  
  cd "$REPO_DIR"
}

# Install shared directory first (if it exists and we're doing all or targeting shared)
# Uses file-level additive install — other repos (e.g. workboard-skills) also write into
# shared/, so we install per-file rather than wiping and replacing the whole directory.
if [ -d "$REPO_DIR/shared" ] && { [ -z "$TARGET_SKILL" ] || [ "$TARGET_SKILL" = "shared" ]; }; then
  echo "Installing shared patterns (additive)..."
  install_shared_additive "$REPO_DIR/shared" "$CURSOR_SKILLS_DIR/shared" "$CLAUDE_SKILLS_DIR/shared"
  echo "  ✓ Copied to Cursor (per-file)"
  echo "  ✓ Symlinked to Claude (per-file)"
  package_skill "shared" "$REPO_DIR/shared"
  echo "  ✓ Packaged for deployment"
  PACKAGE_COUNT=$((PACKAGE_COUNT + 1))
  echo ""
fi

# Helper: install all entries from a source directory that have SKILL.md or .install
install_from_dir() {
  local source_root="$1"
  local label="$2"  # "skill" or "agent resource"

  [ -d "$source_root" ] || return 0

  for dir in "$source_root"/*/; do
    SKILL_NAME="$(basename "$dir")"

    # Single-skill mode: only install the requested entry
    if [ -n "$TARGET_SKILL" ] && [ "$SKILL_NAME" != "$TARGET_SKILL" ]; then
      continue
    fi

    if [ -f "$dir/SKILL.md" ] || [ -f "$dir/.install" ]; then
      if [ -f "$dir/.install" ]; then
        echo "Installing $SKILL_NAME (agent resource)..."
      else
        echo "Installing $SKILL_NAME..."
      fi

      copy_to_cursor "$source_root/$SKILL_NAME" "$CURSOR_SKILLS_DIR/$SKILL_NAME"
      echo "  ✓ Copied to Cursor"

      symlink_to_claude "$source_root/$SKILL_NAME" "$CLAUDE_SKILLS_DIR/$SKILL_NAME"
      echo "  ✓ Symlinked to Claude"

      package_skill "$SKILL_NAME" "$source_root/$SKILL_NAME"
      echo "  ✓ Packaged for deployment"

      COUNT=$((COUNT + 1))
      PACKAGE_COUNT=$((PACKAGE_COUNT + 1))
      echo ""

      if [ -n "$TARGET_SKILL" ]; then
        return 0
      fi
    fi
  done
}

# If targeting only "shared", skip the skill/resource loops
if [ "$TARGET_SKILL" = "shared" ]; then
  :
else
  # Install skills (SKILL.md) from skills/
  install_from_dir "$REPO_DIR/skills" "skill"

  # Install agent resource packages (.install) from resources/
  install_from_dir "$REPO_DIR/resources" "agent resource"

  # Single-skill mode: ensure we found the requested entry (shared is handled above)
  if [ -n "$TARGET_SKILL" ] && [ "$TARGET_SKILL" != "shared" ] && [ "$COUNT" -eq 0 ]; then
    echo "❌ No skill or resource found: $TARGET_SKILL (expected a directory with SKILL.md or .install marker in skills/ or resources/)"
    exit 1
  fi
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Installed $COUNT skill(s) to both platforms"
echo "✓ Created $PACKAGE_COUNT deployment package(s)"
echo ""
echo "Skills are now available at:"
echo "  Cursor: $CURSOR_SKILLS_DIR (copies - run install script after changes)"
echo "  Claude: $CLAUDE_SKILLS_DIR (symlinks - changes auto-reflected)"
echo ""
echo "Deployment packages created at:"
echo "  $PACKAGES_DIR"
echo ""
echo "Note: Cursor requires re-running this script after skill changes."
echo "      Claude changes are immediately reflected via symlinks."
echo "      Deployment packages are suitable for Claude Desktop/Cowork."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
