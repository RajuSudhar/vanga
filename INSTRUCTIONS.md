# Project Instructions

## Goal

Browser-first, P2P file sharing. Static site (GitHub Pages) → QR-paired → WebRTC DataChannel transfer. Cross-platform (PC ↔ Mobile ↔ Mac ↔ iOS). No accounts, no install (initial phase).

## Non-goals

Cloud storage, sync/backup, pre-2022 browsers, email-style attachments.

## Stack

- **Browser UI**: Vanilla JS. No framework, no bundler, no build step.
- **Native component**: Go (relay, CLI, mobile libs via `gomobile`).
- **Crypto (browser)**: Web Crypto API only — X25519, AES-256-GCM, SHA-256, HKDF.
- **Crypto (Go)**: stdlib + `golang.org/x/crypto`.
- **QR**: vendor `paulmillr/qr` as single file (0 deps, 18 KB).

## Dependency policy (hard limits)

- Browser: **zero** npm deps. Vendor anything needed.
- Go: max 3 external modules — `golang.org/x/crypto`, `github.com/coder/websocket`, `github.com/flynn/noise`.
- `CGO_ENABLED=0` always. No C bindings.
- New dep must pass: <5 transitive deps, known maintainer, <2000 LOC auditable, no native bindings.

## Transport

- **WebRTC DataChannel** (SCTP/DTLS/UDP). Only viable browser P2P transport.
- LAN: `iceServers: []` — direct host candidates.
- Cross-network: public STUN (Google/Cloudflare) + optional self-hosted Coturn.
- **Chunk size: 16 KiB** (Firefox fragment boundary).
- Ordered + reliable channels (default SCTP).
- Separate control channel from data channel.
- **Fix Chrome SDP cap**: replace `b=AS:30` with `b=AS:1638400`.
- **Backpressure**: `bufferedAmount` + `bufferedamountlow` event. Threshold 65536. **Never `setTimeout`**.

## Signaling

- Primary: QR code (QWBP-compressed SDP ~55–100 B, or X25519 pubkey + session ID ~64 B).
- Fallback: Firebase Realtime DB free tier OR self-hosted WS.
- Two-QR flow for fully serverless; one-QR + ephemeral relay for better UX.

## Security

- **Noise NKpsk0** pattern. QR carries responder static X25519 pubkey (32 B) + PSK (32 B).
- Cipher suite: `Noise_NK_25519_AESGCM_SHA256` (browser-compat; no ChaCha20 in Web Crypto).
- Per-chunk SHA-256 integrity.
- Trust anchor: physical proximity (QR scan). Optional SAS for paranoid users.
- Relay is zero-knowledge — forwards ciphertext only.
- Persistent pairing: store peer static pubkeys in IndexedDB after first scan.

## File transfer protocol

- 3 phases (LocalSend-inspired): `PREPARE` (metadata) → `DATA` (chunks) → `ACK`/`CANCEL`.
- File ID: SHA-256(first 64 KiB ‖ filename ‖ size).
- Resume: bitfield of received chunks in IndexedDB; exchange on reconnect; retransmit missing only.

## Modules (7, independently versioned)

| Module      | Responsibility                             | Lang    |
| ----------- | ------------------------------------------ | ------- |
| `ui`        | file picker, QR display/scan, progress     | JS      |
| `signaling` | SDP/key exchange (QR or relay)             | JS + Go |
| `transport` | DataChannel abstraction (future TCP/relay) | JS + Go |
| `handshake` | Noise NK/NKpsk0                            | JS + Go |
| `crypto`    | X25519, AES-GCM, SHA-256, HKDF             | JS + Go |
| `chunking`  | 16 KiB segment, hash, resume, backpressure | JS + Go |
| `discovery` | QR gen/scan; mDNS (native only)            | JS + Go |

## iOS Safari constraints (non-negotiable)

- No background transfer — keep tab active.
- No Web Share Target.
- No File System Access API — use `<input type=file>` + `<a download>`.
- No BarcodeDetector — JS QR decoder mandatory.
- IndexedDB may evict after 7 days unused.
- `getUserMedia` needs HTTPS, user gesture, `playsinline` on video.
- Target in-tab first; PWA later.

## Roadmap

1. **Initial** — static site + QR + WebRTC LAN. Modules: `ui`, `signaling`, `transport`, `chunking`.
2. **Phase 1** — Noise NK + persistent pairing. Add `handshake`, `crypto`.
3. **Phase 2** — Go relay + discovery server (Syncthing-style).
4. **Phase 3** — PWA manifest + SW; `gomobile` native shells.

## Git workflow

- **`endgame`** = main branch. **`warzone`** = integration branch.
- Features land on `warzone` first via small, independently-reviewable PRs.
- PR to `endgame` only after the full phase is perfected.
- Each phase is scoped strictly — do **not** pull work in from other phases.
- Flag design flaws as early as possible.
- Priority: stability + fast to market.

## Conventions

- Every self-implementable primitive is its own module with a narrow interface.
- Crypto module never exposes raw key material.
- No new dep without passing the policy above.
- Validate QR scan on multiple readers before shipping (Reed-Solomon bugs are silent).
