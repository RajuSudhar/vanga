# Package Managers

## Why two lock files

Vanga commits **both** `pnpm-lock.yaml` and `package-lock.json`:

- `pnpm` is the primary dev experience — faster installs, strict hoisting.
- `npm` support means contributors without `pnpm` can still install and run.

Both lock files must stay in sync. This is enforced by the pre-commit hook.

## Primary: pnpm

```bash
pnpm install
pnpm run build
pnpm run watch
pnpm run typecheck
pnpm run validate # format + lint + typecheck
```

Add a dep (after passing the security check and dep policy in `docs/SECURITY.md`):

```bash
./scripts/check-package-security.sh <pkg>
pnpm add -E <pkg>           # -E pins exact version
pnpm run sync:locks         # regenerate package-lock.json
git add package.json pnpm-lock.yaml package-lock.json
```

## Fallback: npm

```bash
npm install
npm run build
```

After any dep change made via npm, sync the pnpm lock:

```bash
./scripts/sync-lock-files.sh
```

## Lock file sync

`scripts/sync-lock-files.sh` detects which lock file is newer and regenerates the other. Running it is idempotent.

Pre-commit hook runs `sync-lock-files.sh` automatically when `package.json` is staged.

## Rules

- Never commit only one lock file. The pre-commit hook will reject it.
- Never hand-edit a lock file.
- Never install globally as a dev requirement — all tooling goes through `devDependencies`.
- Exact versions only (`pnpm add -E`, or manually pin in `package.json`).

## Node version

Node `>= 20.0.0`. Use `.nvmrc` if you switch frequently (not committed; developer preference).

## Uninstalling

```bash
pnpm remove <pkg>
pnpm run sync:locks
```
