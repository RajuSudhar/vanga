# CLAUDE.md — Vanga

Authoritative instruction set for Claude working in this repository. Be concise, token-efficient, and type-safe. When rules here conflict with anything else, this file wins. Source docs: `README.md`, `INSTRUCTIONS.md`, `docs/ARCHITECTURE.md`, `docs/CODING-STANDARDS.md`, `docs/BRANCH-MANAGEMENT.md`, `docs/SECURITY.md`, `docs/PACKAGE-MANAGERS.md`.

## Project

Browser-first, P2P file sharing. Static site (GitHub Pages) + QR pairing + WebRTC DataChannels + Noise NK handshake. Cross-platform: PC, Mac, Android, iOS. No accounts, no install (initial phase). Native component (Go, future phases) for relay/CLI/mobile libs.

Layout: `src/` (TS — browser UI, signaling, transport, chunking), `types/` at root (all shared types), `scripts/`, `docs/`, `.husky/`. Future: `native/` (Go relay + CLI).

## Phase discipline (hard rule)

Each phase is scoped strictly. Do **NO MORE** and **NO LESS** than what is defined for the current phase. Cross-phase work is forbidden without explicit instruction.

- **Phase 0 (current)**: static site + QR + WebRTC LAN transfer. Modules: `ui`, `signaling`, `transport`, `chunking`. No Noise, no relay, no PWA.
- **Phase 1**: Noise NK + persistent pairing. Adds `handshake`, `crypto`.
- **Phase 2**: Go relay + discovery server.
- **Phase 3**: PWA manifest + `gomobile` shells.

Before any change, confirm it belongs to the current phase. If not, stop and flag.

## Branching & PR flow (hard rule)

- **`endgame`** = main branch. PR-only. Direct commits/pushes blocked by hooks.
- **`warzone`** = integration branch. Feature branches merge here first.
- Feature branches → `warzone` via small, independently-reviewable PRs.
- `warzone` → `endgame` only after the full phase is perfected.
- Branch format: `<type>/<TICKET-ID>-<description>` or `<type>/<>=3-kebab-words>`.
- Types: `feature`, `fix`, `hotfix`, `release`, `chore`, `doc`, `test`, `refactor`. Never `feat`, `bugfix`, `perf`, `docs` (note: commit type is `docs`, branch type is `doc`).
- Commits: Conventional Commits. Imperative, no trailing period, no emojis.

## Non-negotiable rules

1. Types: ALWAYS `type`, NEVER `interface`. Exception: class extension or declaration merging only.
2. All shared types live in `types/` at repo root. Import via `import type { ... } from '@types'` (or `@types/<file>`). Never redefine a type already in `types/`.
3. Centralized logger: `import { log } from './logger'`. No `console.log` / `console.error` in product code. Required at every critical path (connection lifecycle, handshake start/end, every DataChannel open/close/error, backpressure events, cache hit/miss/invalidate, errors, transfer start/complete, slow ops > 1s, large transfers).
4. Never log or surface keys, PSKs, or raw cryptographic material. Never put them in errors, URLs, or UI.
5. No emojis anywhere — code, scripts, logs, commits, docs.
6. Strict TS. No `any` — use `unknown` + narrowing. Validate all external input (QR payloads, DataChannel messages, file metadata) at module boundaries.
7. **Dependency policy is a hard cap**: browser = zero npm deps (vendor anything needed); Go (future) = max 3 external modules. Every new dep must pass: <5 transitive deps, known maintainer, <2000 LOC auditable, no native/C bindings. Run `./scripts/check-package-security.sh <pkg>` BEFORE `pnpm add`. Pin exact versions.
8. Both lockfiles (`pnpm-lock.yaml`, `package-lock.json`) must stay in sync. After dep changes run `pnpm run sync:locks` and commit both.
9. Pre-commit must pass: branch protection, format, markdown lint, ESLint, `pnpm typecheck`, `pnpm build`. Do not bypass hooks.
10. No build step assumption breakage. Browser code ships from GitHub Pages; keep runtime output pure ESM, no bundler-only features. TS is a dev-time type layer.

## TypeScript standards

- `type` for all object shapes, unions, intersections, generics, function signatures.
- PascalCase types; camelCase vars/functions; UPPER_SNAKE_CASE constants; kebab-case filenames (`data-channel-transport.ts`).
- Boolean types/vars: `is*`, `has*`, `should*`.
- Import order (ESLint-enforced): node builtins → external → internal → parent/sibling → `import type` last, alphabetical within groups.
- Prettier: single quotes, 2-space, 100-col code / 120-col markdown, semicolons, ES5 trailing commas.
- Descriptive names only — no `State`, `Entry`, `client`; prefer `HandshakeState`, `ChunkEntry`, `signalingClient`.

## Module contracts (Phase 0)

- **`ui`** — vanilla DOM + TS. File picker, QR display/scan, progress. No framework.
- **`signaling`** — `createOffer() → SignalPayload`, `acceptOffer(SignalPayload) → SignalPayload`. Primary: QR. Optional: ephemeral relay.
- **`transport`** — `connect(signal) → Channel`, `Channel.send(bytes)`, `Channel.onReceive(cb)`. Wraps `RTCDataChannel`. Chunk size 16 KiB. Backpressure via `bufferedAmount` + `bufferedamountlow`. **Never `setTimeout` in the send loop.** Must replace `b=AS:30` with `b=AS:1638400` in SDP (Chrome fix).
- **`chunking`** — `segment(file) → ChunkStream`, `assemble(chunk) → File | Partial`. Per-chunk SHA-256 via Web Crypto. Resume via bitfield in IndexedDB. File ID = SHA-256(first 64 KiB ‖ filename ‖ size).

## Phase-0 wire protocol

`PREPARE` (metadata, session) → `DATA` (16 KiB chunks) → `ACK` / `CANCEL`. Separate control channel from data channel. Ordered + reliable SCTP (default).

## Security model (future phases, tracked but not implemented in Phase 0)

- Phase 1: Noise NKpsk0. QR carries responder X25519 static pubkey (32 B) + PSK (32 B). Cipher suite `Noise_NK_25519_AESGCM_SHA256` (AES-GCM because Web Crypto lacks ChaCha20-Poly1305). Per-chunk SHA-256 integrity. Trust anchor: physical proximity via QR scan. Optional SAS display.
- Phase 2: Relay is zero-knowledge — forwards ciphertext only.

In Phase 0, WebRTC's built-in DTLS is the only transport encryption. Do not claim application-layer E2EE until Phase 1 lands.

## iOS Safari constraints (design constants)

- No background transfer. Keep tab active.
- No Web Share Target on iOS PWAs.
- No File System Access API — use `<input type=file>` + `<a download>`.
- No BarcodeDetector — JS QR decoder mandatory. Use vendored `paulmillr/qr` (0-dep, 18 KB).
- IndexedDB may evict after 7 days unused — resumable state is best-effort.
- `getUserMedia` needs HTTPS, user gesture, `playsinline` on video element.

## Commands

```bash
pnpm install
pnpm run build
pnpm run watch
pnpm run typecheck
pnpm run lint:all
pnpm run format:all
pnpm run validate            # format + lint + typecheck
pnpm run sync:locks
pnpm run validate:branch
./scripts/check-package-security.sh <pkg>
```

## What NOT to do

- Do not introduce `interface`, `any`, `console.*`, emojis, or raw `process.env` reads outside a dedicated config module.
- Do not add deps without the security check AND the dep policy.
- Do not do cross-phase work.
- Do not commit to `endgame` directly. Do not skip hooks (`--no-verify`). Do not force-push to `endgame` or `warzone`.
- Do not log keys, PSKs, SDP with candidates, or full request bodies.
- Do not commit only one lockfile.
- Do not create new top-level directories without updating `docs/ARCHITECTURE.md`.
- Do not add a bundler, framework, or transpiler beyond `tsc`.

## When unsure

Prefer reading `docs/ARCHITECTURE.md` for structure/design, `docs/CODING-STANDARDS.md` for style/logging, `docs/BRANCH-MANAGEMENT.md` for git workflow, `docs/SECURITY.md` for dep hygiene, `docs/PACKAGE-MANAGERS.md` for lockfile ops. The original research brief lives in `INSTRUCTIONS.md`.
