# Project Instructions

Authoritative research brief and source-of-truth for design decisions. The
`docs/` directory derives from this; `CLAUDE.md` is the agent-facing
shorthand.

## Goal

One paragraph stating what the project does and why it exists.

## Non-goals

- Things that are explicitly out of scope.
- Things deferred to later phases.

## Stack

- **Language(s)**: <e.g. TypeScript, Go, Rust>
- **Frontend**: <framework or "vanilla DOM + TS">
- **Backend**: <framework or "none">
- **Crypto**: <Web Crypto, libsodium, etc.>
- **Tools**: <Claude Code, Claude SDK, Slack bot, etc.>

## Dependency policy (hard limits)

- Runtime deps: <cap, e.g. zero / max N>.
- Dev deps: tooling only.
- Every new dep must pass `./scripts/check-package-security.sh`, <5
  transitive deps, known maintainer, <2000 LOC auditable, no native/C
  bindings.
- Pin exact versions.

## Architecture

Module list with one-line responsibility per module. See
`docs/ARCHITECTURE.md` for module contracts.

| Module      | Responsibility | Lang |
| ----------- | -------------- | ---- |
| `<name>`    | <...>          | <...> |

## Wire / data protocol

If applicable, document the on-the-wire format.

## Security model

- Threat model in scope.
- Threat model out of scope (per phase).

## Roadmap (phases)

1. **Phase 1** — <scope>
2. **Phase 2** — <scope>
3. **Phase 3** — <scope>

## Git workflow

- Main branch = <name>. PR-only.
- Integration branch = <name> (optional).
- Features land via small, independently reviewable PRs.
- Each phase is scoped strictly — do not pull cross-phase work in.

## Conventions

- Every self-implementable primitive is its own module with a narrow
  interface.
- Crypto module never exposes raw key material.
- No new dep without passing the policy above.
