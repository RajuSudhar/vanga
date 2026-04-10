#!/usr/bin/env sh

# Sync both package-lock.json (npm) and pnpm-lock.yaml (pnpm)

set -e

echo "Synchronizing lock files..."

if [ ! -d "node_modules" ]; then
  echo "WARNING: node_modules not found. Installing dependencies first..."
  pnpm install
fi

command_exists() {
  command -v "$1" > /dev/null 2>&1
}

if ! command_exists pnpm; then
  echo "ERROR: pnpm is not installed (install with: npm install -g pnpm)"
  exit 1
fi

if ! command_exists npm; then
  echo "ERROR: npm is not installed"
  exit 1
fi

pnpm_modified=0
npm_modified=0

if [ -f "pnpm-lock.yaml" ]; then
  pnpm_modified=$(stat -f %m "pnpm-lock.yaml" 2> /dev/null || stat -c %Y "pnpm-lock.yaml" 2> /dev/null || echo 0)
fi
if [ -f "package-lock.json" ]; then
  npm_modified=$(stat -f %m "package-lock.json" 2> /dev/null || stat -c %Y "package-lock.json" 2> /dev/null || echo 0)
fi

if [ "$pnpm_modified" -gt "$npm_modified" ]; then
  echo "INFO: pnpm-lock.yaml is newer, syncing to package-lock.json..."
  rm -f package-lock.json
  npm install --package-lock-only --ignore-scripts --legacy-peer-deps \
    || npm install --package-lock-only --ignore-scripts --force
elif [ "$npm_modified" -gt "$pnpm_modified" ]; then
  echo "INFO: package-lock.json is newer, syncing to pnpm-lock.yaml..."
  rm -f pnpm-lock.yaml
  pnpm install --lockfile-only --ignore-scripts
else
  echo "INFO: Both lock files are in sync or don't exist yet"
  if [ ! -f "pnpm-lock.yaml" ] && [ ! -f "package-lock.json" ]; then
    pnpm install --lockfile-only --ignore-scripts
    npm install --package-lock-only --ignore-scripts
  fi
fi

[ -f "pnpm-lock.yaml" ] || {
  echo "ERROR: pnpm-lock.yaml missing"
  exit 1
}
[ -f "package-lock.json" ] || {
  echo "ERROR: package-lock.json missing"
  exit 1
}

echo "SUCCESS: Lock files synchronized"
