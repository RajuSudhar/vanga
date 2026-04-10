#!/usr/bin/env sh

# Pre-commit hook script
# Runs code quality checks before allowing a commit

if ! command -v tsc &> /dev/null; then
  echo "Skipping pre-commit checks (TypeScript not installed yet)"
  exit 0
fi

echo "Running pre-commit checks..."

# 0. Sync lock files if package.json changed
if git diff --cached --name-only | grep -q "^package\.json$"; then
  echo "[0/8] Syncing lock files (package.json changed)..."
  ./scripts/sync-lock-files.sh
  if [ $? -ne 0 ]; then
    echo "ERROR: Lock file sync failed!"
    exit 1
  fi
  git add package-lock.json pnpm-lock.yaml 2> /dev/null || true
fi

# 1. Validate branch name
echo "[1/8] Validating branch name..."
./scripts/validate-branch-name.sh
if [ $? -ne 0 ]; then
  echo "ERROR: Branch name validation failed!"
  exit 1
fi

# 2. Protect direct commits to endgame
echo "[2/8] Checking branch protection (endgame is PR-only)..."
current_branch=$(git symbolic-ref --short HEAD 2> /dev/null || echo "")
if [ "$current_branch" = "endgame" ]; then
  echo "ERROR: Direct commits to 'endgame' are forbidden."
  echo "Flow: feature branch -> warzone -> endgame (via PR only)."
  exit 1
fi

# 3. Verify lock files are in sync
echo "[3/8] Verifying lock files are in sync..."
if [ -f "package-lock.json" ] && [ -f "pnpm-lock.yaml" ]; then
  npm_count=$(grep -c '"resolved":' package-lock.json 2> /dev/null || echo "0")
  pnpm_count=$(grep -c 'resolution:' pnpm-lock.yaml 2> /dev/null || echo "0")
  if [ "$npm_count" = "0" ] || [ "$pnpm_count" = "0" ]; then
    echo "WARNING: Lock files may not be in sync (run: pnpm run sync:locks)"
  fi
else
  echo "ERROR: Both lock files must exist (package-lock.json and pnpm-lock.yaml)"
  echo "Run: pnpm run sync:locks"
  exit 1
fi

# 4. Format code
echo "[4/8] Formatting code..."
pnpm run format
if [ $? -ne 0 ]; then
  echo "ERROR: Formatting failed!"
  exit 1
fi

# 5. Lint markdown
echo "[5/8] Linting markdown..."
pnpm run lint:md:fix
if [ $? -ne 0 ]; then
  echo "ERROR: Markdown linting failed!"
  exit 1
fi

# 6. Lint code
echo "[6/8] Linting code..."
pnpm run lint
if [ $? -ne 0 ]; then
  echo "ERROR: Linting failed!"
  exit 1
fi

# 7. Type check
echo "[7/8] Type checking..."
pnpm run typecheck
if [ $? -ne 0 ]; then
  echo "ERROR: Type check failed!"
  exit 1
fi

# 8. Build
echo "[8/8] Building..."
pnpm run build
if [ $? -ne 0 ]; then
  echo "ERROR: Build failed!"
  exit 1
fi

echo "SUCCESS: All pre-commit checks passed!"
exit 0
