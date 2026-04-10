#!/usr/bin/env sh

# Commit message validation - Conventional Commits

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

conventional_pattern='^(feat|fix|docs|style|refactor|test|chore|ci|build|perf|revert)(\(.+\))?: .{1,}'

if echo "$commit_msg" | grep -qE "^Merge "; then
  exit 0
fi

if echo "$commit_msg" | grep -qE "^Revert "; then
  exit 0
fi

if ! echo "$commit_msg" | grep -qE "$conventional_pattern"; then
  echo ""
  echo "ERROR: Invalid commit message format!"
  echo ""
  echo "Format: <type>(<optional-scope>): <description>"
  echo ""
  echo "Allowed types:"
  echo "  feat, fix, docs, style, refactor, test, chore, ci, build, perf, revert"
  echo ""
  echo "Examples:"
  echo "  feat(transport): add DataChannel backpressure"
  echo "  fix(signaling): handle expired offer"
  echo "  docs: clarify phase-0 scope"
  echo ""
  echo "Your commit message:"
  echo "  $commit_msg"
  echo ""
  exit 1
fi

exit 0
