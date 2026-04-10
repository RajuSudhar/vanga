# Vanga

Browser-first, P2P file sharing. Open a static site, scan a QR, transfer files directly between devices over WebRTC. No accounts, no apps, no servers.

## Status

Phase 0 — scaffolding. Target: static site + QR + WebRTC LAN transfer.

## Goals

- Sender opens a static website; receiver joins by scanning a QR.
- Files transfer directly between devices (P2P), end-to-end encrypted.
- No accounts, no app installation (initial phase), no proprietary dependencies.
- Cross-platform: PC ↔ Mobile ↔ Mac ↔ iOS.

## Non-goals

- Cloud storage or file hosting.
- Continuous sync / backup.
- Browsers older than 2022 (WebRTC DataChannel + Web Crypto X25519 are baseline).
- Replacing email attachment workflows.

## Stack

- **Browser UI**: TypeScript (strict), vanilla DOM, no framework, no bundler. Crypto via Web Crypto API. QR via vendored `paulmillr/qr`.
- **Native** (future): Go. Max 3 external modules (`golang.org/x/crypto`, `github.com/coder/websocket`, `github.com/flynn/noise`).
- **Dep policy**: browser = zero npm deps; vendor anything needed.

## Phased roadmap

| Phase | Milestone                      | Modules                                    |
| ----- | ------------------------------ | ------------------------------------------ |
| 0     | Static site + QR + WebRTC LAN  | `ui`, `signaling`, `transport`, `chunking` |
| 1     | Noise NK + persistent pairing  | + `handshake`, `crypto`                    |
| 2     | Go relay + discovery server    | + Go relay binary                          |
| 3     | PWA + `gomobile` native shells | PWA manifest, SW                           |

Each phase is strictly scoped. No more, no less.

## Branching

- `endgame` — main. PR-only. Perfection-gated.
- `warzone` — integration. Receives feature PRs.
- Feature branches → `warzone` → (after phase perfection) `endgame`.

See `docs/BRANCH-MANAGEMENT.md`.

## Dev quickstart

```bash
pnpm install
pnpm run validate # format + lint + typecheck
pnpm run build
pnpm run watch
```

Before adding any dep:

```bash
./scripts/check-package-security.sh <pkg>
```

## Documentation

- `CLAUDE.md` — authoritative rules for Claude working in this repo.
- `INSTRUCTIONS.md` — original research brief (transport, crypto, language choice).
- `docs/ARCHITECTURE.md` — module layout, interfaces, wire protocol.
- `docs/BRANCH-MANAGEMENT.md` — endgame/warzone flow.
- `docs/CODING-STANDARDS.md` — TS style, logging, imports.
- `docs/SECURITY.md` — dep policy, crypto model, threat model.
- `docs/PACKAGE-MANAGERS.md` — dual-lockfile strategy.

## License

GPL-3.0-or-later. See `LICENSE`.
