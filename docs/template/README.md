# Project Docs Template

Standard documentation, branching, hook, and rules template synthesized from
`synapse-vault-private`, `atlassian-bitbucket-mcp`, `nr-latch`, `vanga`, and
`go-type-generater`. Use this as the canonical starting point for any new
project; copy and tailor where needed.

## What this gives you

| Area                  | Path(s)                                                 |
| --------------------- | ------------------------------------------------------- |
| Branch management     | `docs/BRANCH-MANAGEMENT.md`, `claude-ref/branching.md`  |
| Project structure     | `docs/ARCHITECTURE.md`                                  |
| Project rules         | `docs/CODING-STANDARDS.md`, `docs/SECURITY.md`, `docs/PACKAGE-MANAGERS.md` |
| Idea / R&D docs       | `private/co-work/{0-ideas,1-architecture,2-plan,3-reference}/` |
| Private workspace     | `private/` (gitignored)                                  |
| Plans / live tracking | `docs/plans/{README.md,TRACK.md,phase-N/feat-<slug>/PLAN.md}` |
| Decisions             | `docs/decisions/ADR-template.md`                        |
| Agent routing         | `CLAUDE.md`, `claude-ref/`                              |
| Git hooks             | `hooks/{pre-commit,commit-msg,pre-push}`                |
| Hook scripts          | `scripts/*.sh`                                          |

## How to apply

1. Copy `CLAUDE.md`, `INSTRUCTIONS.md`, the `docs/` tree, and `claude-ref/`
   into the target repo root.
2. Copy `private/` into the target repo root and ensure `.gitignore` excludes
   `private/` content (`!private/.gitkeep` if you want the dir tracked).
3. Copy `hooks/*` into `.husky/` and `scripts/*` into `scripts/`. Wire up
   Husky (`pnpm dlx husky-init` or equivalent) so the hooks fire.
4. Replace every `<placeholder>` token in each file. Search for
   `<project>`, `<TYPE>`, `<phase>`, `<slug>`.
5. Pick the branching model (PR-only main + integration vs. trunk + feature)
   and trim `BRANCH-MANAGEMENT.md` accordingly.
6. Initialise `docs/plans/TRACK.md` with the real first phase.

## Conventions baked in

- TypeScript: `type` only, no `interface` (except class extension / decl
  merging); shared types in `types/` at repo root; no `any`; centralized
  logger; no `console.*`; no emojis anywhere.
- Branch naming: `<type>/<TICKET-ID>-<description>` or
  `<type>/<>=3-kebab-words>`. Allowed types: `feature`, `fix`, `hotfix`,
  `release`, `chore`, `doc`, `test`, `refactor`. Rejected aliases: `feat`,
  `bugfix`, `perf`, `docs`.
- Commits: Conventional Commits, imperative, no trailing period, no emojis.
- Dependencies: hard cap; security-check before add; pinned exact versions;
  both lock files in sync (when applicable).
- Phases: scoped strictly, no cross-phase work, `TRACK.md` is the source of
  truth for status.
- Secrets: never log or surface raw keys, tokens, or PII.
