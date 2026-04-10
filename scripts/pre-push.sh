#!/usr/bin/env sh

# Pre-push hook script

./scripts/validate-branch-name.sh
if [ $? -ne 0 ]; then
  exit 1
fi

current_branch=$(git symbolic-ref --short HEAD 2> /dev/null || echo "")
if [ "$current_branch" = "endgame" ]; then
  echo "ERROR: Direct pushes to 'endgame' are forbidden. Use a PR from 'warzone'."
  exit 1
fi

exit 0
