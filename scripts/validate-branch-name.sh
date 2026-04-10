#!/usr/bin/env sh

# Branch Name Validation
# Enforces Vanga's branching model: endgame (main) <- warzone (integration) <- feature branches.

current_branch=$(git symbolic-ref --short HEAD 2> /dev/null || echo "")

if [ -z "$current_branch" ]; then
  echo "ERROR: Not on a branch (detached HEAD state)"
  exit 1
fi

# Protected / known branches - always allowed
if echo "$current_branch" | grep -qE "^(endgame|warzone)$"; then
  exit 0
fi

# Preferred: <type>/<TICKET-ID>-<description>
valid_pattern='^(feature|fix|hotfix|release|chore|doc|test|refactor)/[A-Z]+-[0-9]+-[a-z0-9-]+$'

# Alternative: <type>/<description> with >= 3 words
alt_pattern='^(feature|fix|hotfix|release|chore|doc|test|refactor)/[a-z][a-z0-9-]*-[a-z0-9-]*-[a-z0-9-]+$'

if echo "$current_branch" | grep -qE "$valid_pattern"; then
  description=$(echo "$current_branch" | sed 's/^[^\/]*\/[A-Z]*-[0-9]*-//')
  vague_terms="^(fix|update|change|modify|refactor|improve|enhance|work|stuff|things|misc|temp|test|wip)$"
  if echo "$description" | grep -qE "$vague_terms"; then
    echo "ERROR: Branch name too vague: $current_branch"
    exit 1
  fi
  exit 0
elif echo "$current_branch" | grep -qE "$alt_pattern"; then
  description=$(echo "$current_branch" | sed 's/^[^\/]*\///')
  word_count=$(echo "$description" | tr '-' '\n' | wc -l)
  if [ "$word_count" -lt 3 ]; then
    echo "ERROR: Branch name too short: $current_branch (need >= 3 words)"
    exit 1
  fi
  vague_patterns="(fix|update|change|modify|refactor|improve|enhance|work|stuff|things|misc|temp|test|wip)-"
  if echo "$description" | grep -qE "^$vague_patterns"; then
    echo "ERROR: Branch name starts with vague term: $current_branch"
    exit 1
  fi
  exit 0
else
  echo ""
  echo "ERROR: Invalid branch name: $current_branch"
  echo ""
  echo "Branching model:"
  echo "  endgame   - main, PR-only, perfection-gated"
  echo "  warzone   - integration, receives feature PRs"
  echo "  <type>/<desc> - feature branches"
  echo ""
  echo "Formats:"
  echo "  <type>/<TICKET-ID>-<description>"
  echo "  <type>/<at-least-three-kebab-words>"
  echo ""
  echo "Valid types: feature, fix, hotfix, release, chore, doc, test, refactor"
  echo ""
  echo "Examples:"
  echo "  feature/transport-datachannel-bootstrap"
  echo "  fix/signaling-expired-offer-race"
  echo "  doc/phase-0-scope-lock"
  echo ""
  exit 1
fi
