# CLAUDE.md — <project>

Authoritative instruction set for Claude working in this repository. Be
concise, token-efficient, and type-safe. When rules here conflict with
anything else, this file wins.

Source docs (verbose, human-readable): `README.md`, `INSTRUCTIONS.md`,
`docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md`,
`docs/BRANCH-MANAGEMENT.md`, `docs/SECURITY.md`,
`docs/PACKAGE-MANAGERS.md`. Prefer `claude-ref/` for execution.

## Project

One paragraph. What it is, primary stack, deployment surface.

Layout: `src/` (product code), `types/` at root (all shared types),
`scripts/`, `docs/`, `.husky/`. Update `docs/ARCHITECTURE.md` when adding
new top-level dirs.

## Hard rules (always)

- `type` only, never `interface` (except class extension / declaration
  merging).
- Shared types live in `types/` at repo root; import via `@types`.
- Centralized `log()` from `src/logger.ts`; no `console.*` in product code.
- Never log or surface raw keys, tokens, PII, or secrets.
- No `any` — use `unknown` + narrowing or a precise type.
- No emojis anywhere — code, scripts, logs, commits, docs.
- No `--no-verify`. No force push to protected branches.
- Exact pinned deps; security-check before add; lock files in sync.
- Strict TS; validate every external input at module boundaries.

## Phase discipline (hard rule)

Each phase is scoped strictly. Do **NO MORE** and **NO LESS** than what is
defined for the current phase. Cross-phase work is forbidden without
explicit instruction. Confirm scope before any change; if unsure, stop and
flag.

| Phase | Scope summary |
| ----- | ------------- |
| 1     | <...>         |
| 2     | <...>         |
| 3     | <...>         |

Plans live at `docs/plans/phase-<n>/feat-<slug>/PLAN.md`. Status at
`docs/plans/TRACK.md`.

## Routing — read the matching ref before acting

| Task                                          | Ref                                       |
| --------------------------------------------- | ----------------------------------------- |
| Adding/editing types, naming, imports         | `claude-ref/coding.md`                    |
| Any log statement, critical path              | `claude-ref/logging.md`                   |
| Branch name, commit message                   | `claude-ref/branching.md`                 |
| Adding a dep, token handling                  | `claude-ref/security.md`                  |
| Lockfile ops, package manager                 | `claude-ref/packages.md`                  |
| Writing/running tests                         | `claude-ref/testing.md`                   |
| Starting a feature                            | `docs/plans/TRACK.md` → phase dir         |

⚠ On conflict: **plan > ref > convention > preference**.

## Branching & PR flow

- Protected/main branch is PR-only. Direct commits/pushes are blocked by
  hooks.
- Feature branches → integration branch via small, independently reviewable
  PRs.
- Branch format: `<type>/<TICKET-ID>-<description>` or
  `<type>/<>=3-kebab-words>`.
- Allowed types: `feature`, `fix`, `hotfix`, `release`, `chore`, `doc`,
  `test`, `refactor`. Rejected: `feat`, `bugfix`, `perf`, `docs`.
- Commits: Conventional Commits. Imperative. No trailing period. No emojis.

See `docs/BRANCH-MANAGEMENT.md` for the full rules.

## Commands

```bash
pnpm install
pnpm run build
pnpm run typecheck
pnpm run lint:all
pnpm run format:all
pnpm run validate            # format + lint + typecheck
pnpm run sync:locks
pnpm run validate:branch
pnpm run branch:create
./scripts/check-package-security.sh <pkg>
```

## What NOT to do

- Do not introduce `interface`, `any`, `console.*`, emojis, or raw
  `process.env` reads outside a dedicated config module.
- Do not add deps without the security check AND the dep policy.
- Do not do cross-phase work.
- Do not commit to the main branch directly. Do not skip hooks
  (`--no-verify`). Do not force-push protected branches.
- Do not log keys, tokens, or full request bodies.
- Do not commit only one lock file (when both are tracked).
- Do not create new top-level directories without updating
  `docs/ARCHITECTURE.md`.

## When unsure

Read `docs/ARCHITECTURE.md` for structure/design,
`docs/CODING-STANDARDS.md` for style/logging,
`docs/BRANCH-MANAGEMENT.md` for git workflow, `docs/SECURITY.md` for dep
hygiene, `docs/PACKAGE-MANAGERS.md` for lockfile ops. The original
research brief lives in `INSTRUCTIONS.md`.
