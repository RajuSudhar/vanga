# Branch Management

## Model

```text
feature branches ──▶ warzone ──(phase perfected)──▶ endgame
```

- **`endgame`** — main branch. PR-only. Direct commits/pushes are blocked by pre-commit and pre-push hooks. Every merge must come from `warzone`, and only after the full phase is perfected.
- **`warzone`** — integration branch. Every feature branch targets `warzone`. PRs to `warzone` are small and independently reviewable.
- **feature branches** — short-lived, one concern per branch, one PR per concern.

## Rules

- Do not commit to `endgame` directly.
- Do not force-push `endgame` or `warzone`.
- Do not skip hooks (`--no-verify`).
- One PR = one concern. Large features are broken into modular PRs.
- A PR to `endgame` is raised only after **all** planned work for the current phase has landed on `warzone` and been validated.
- Cross-phase PRs are rejected.

## Branch naming

### Format

- **Preferred:** `<type>/<TICKET-ID>-<description>`
- **Alternative:** `<type>/<at-least-three-kebab-words>`

### Valid types

| Type       | Purpose               | Example                                   |
| ---------- | --------------------- | ----------------------------------------- |
| `feature`  | New feature           | `feature/transport-datachannel-bootstrap` |
| `fix`      | Bug fix               | `fix/signaling-expired-offer-race`        |
| `hotfix`   | Urgent production fix | `hotfix/endgame-sdp-cap-regression`       |
| `release`  | Release preparation   | `release/v0.1.0`                          |
| `chore`    | Maintenance           | `chore/bump-typescript-5-9`               |
| `doc`      | Documentation         | `doc/phase-0-scope-lock`                  |
| `test`     | Tests                 | `test/chunking-resume-bitfield`           |
| `refactor` | Refactor              | `refactor/extract-signaling-serializer`   |

Not allowed (hook will reject with guidance): `feat` (use `feature`), `bugfix` (use `fix`), `perf` (use `refactor` or `feature`), `docs` (branch type is `doc`; commit type is `docs`).

### Validation

`scripts/validate-branch-name.sh` runs pre-commit and pre-push. It:

- Allows `endgame` and `warzone` unconditionally.
- Rejects vague descriptions (`fix`, `update`, `change`, `wip`, etc. without context).
- Requires at least 3 hyphen-separated words in the description when no ticket ID is present.
- Enforces lowercase-kebab descriptions.

## Commit messages

Conventional Commits. Enforced by `scripts/commit-msg.sh`.

```text
<type>(<optional-scope>): <description>
```

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `build`, `perf`, `revert`.

Rules:

- Imperative mood (`add`, not `added` / `adds`).
- No trailing period.
- No emojis.
- Subject is a single line; body is optional and separated by a blank line.

Examples:

```text
feat(transport): add DataChannel backpressure via bufferedamountlow
fix(signaling): reject offer when fingerprint mismatches QR payload
docs(architecture): lock phase-0 scope to ui/signaling/transport/chunking
chore(deps): vendor paulmillr/qr v1.x
```

## PR checklist (warzone)

- Branch name passes `pnpm run validate:branch`.
- `pnpm run validate` passes (format + lint + typecheck).
- `pnpm run build` passes.
- Change is in scope for the current phase.
- No new top-level dir without updating `docs/ARCHITECTURE.md`.
- No new dep without `./scripts/check-package-security.sh` and dep policy review.
- Both lock files updated (`pnpm run sync:locks`).

## PR checklist (endgame)

Same as warzone, plus:

- The full phase is complete on `warzone`.
- All phase-scope items in `docs/ARCHITECTURE.md` are shipped.
- No known design flaws or P0/P1 issues open.
- Release notes drafted.
