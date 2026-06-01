#!/usr/bin/env bash
# memory-paths.sh - resolve THIS workspace's Claude Code memory locations.
#
# Why this exists: Claude Code keys a workspace's auto-memory pool to a slug
# derived from the workspace's ABSOLUTE PATH. If you ever hand-guess that slug
# and get it wrong, MEMORY.md silently stops loading and memory appears lost.
# So every skill resolves the slug HERE, one way, and VERIFIES the dir exists.
#
# The rule (observed, stable): replace every character in the absolute path that
# is not [A-Za-z0-9] with a hyphen, per Unicode code point. No collapsing, no
# lowercasing. Python's re.sub over the cwd string reproduces it exactly,
# including emoji and spaces.
#
# Usage:
#   source scripts/memory-paths.sh            # exports SLUG, POOL_DIR, MEMORY_MD, FOUND
#   ./scripts/memory-paths.sh                 # prints them
#   ./scripts/memory-paths.sh /some/other/dir # resolve for a different path

set -euo pipefail

_target="${1:-$PWD}"

SLUG="$(python3 - "$_target" <<'PY'
import re, sys
print(re.sub(r'[^A-Za-z0-9]', '-', sys.argv[1]))
PY
)"

POOL_DIR="$HOME/.claude/projects/$SLUG/memory"
MEMORY_MD="$POOL_DIR/MEMORY.md"

# FOUND=1 means Claude Code already has a project dir for this exact path (it
# creates one the moment a session opens here). If FOUND=0 the slug is either
# brand-new or wrong - callers must verify before trusting it.
if [ -d "$HOME/.claude/projects/$SLUG" ]; then
  FOUND=1
else
  FOUND=0
fi

export SLUG POOL_DIR MEMORY_MD FOUND

# When run (not sourced), print the resolution.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  echo "workspace:  $_target"
  echo "slug:       $SLUG"
  echo "pool_dir:   $POOL_DIR"
  echo "memory_md:  $MEMORY_MD"
  echo "found:      $FOUND   (1 = Claude Code already tracks this path; 0 = new or renamed)"
  if [ "$FOUND" = 0 ]; then
    echo ""
    echo "Other project memory dirs that DO exist (a renamed/moved workspace shows up here):"
    ls -1 "$HOME/.claude/projects/" 2>/dev/null | sed 's/^/  /' || true
  fi
fi
