# Architecture

## System shape

Vanga is a two-tier system:

1. **Browser UI** (TypeScript, static site on GitHub Pages) — the only component that ships in Phase 0.
2. **Native component** (Go, future Phase 2+) — relay, discovery server, CLI, mobile libs via `gomobile`.

Everything below Phase 0 is tracked here for intent, not implementation.

## Repo layout

```text
.
├── CLAUDE.md              # Authoritative rules for Claude
├── INSTRUCTIONS.md        # Research brief (source of truth for design)
├── README.md
├── LICENSE
├── package.json           # Browser (TypeScript) project
├── tsconfig.json
├── eslint.config.js
├── .prettierrc
├── .markdownlint.json
├── .husky/                # Git hooks
├── scripts/               # Shell scripts (hooks, validation, sync)
├── types/                 # All shared TypeScript types
├── src/                   # Browser TypeScript source
│   ├── index.ts
│   ├── ui/                # (Phase 0) file picker, QR display/scan, progress
│   ├── signaling/         # (Phase 0) QR-based SDP/key exchange
│   ├── transport/         # (Phase 0) WebRTC DataChannel wrapper
│   ├── chunking/          # (Phase 0) 16 KiB segmentation, SHA-256, resume
│   ├── handshake/         # (Phase 1) Noise NK/NKpsk0
│   ├── crypto/            # (Phase 1) Web Crypto wrappers
│   └── vendor/            # Vendored deps (e.g. paulmillr/qr)
├── docs/
└── native/                # (Phase 2) Go relay + discovery server + CLI
```

Do not create new top-level directories without updating this file.

## Module contracts

All modules are independently versioned. Each has a narrow public interface.

### `ui` (Phase 0)

Vanilla DOM + TypeScript. No framework.

- Sender view: file picker (`<input type=file>`), QR display, progress bar.
- Receiver view: QR scanner (getUserMedia + JS decoder), file download (`<a download>`), progress bar.

### `signaling` (Phase 0)

```ts
type SignalPayload = { version: number; sdp: string; fingerprint: Uint8Array };

createOffer(): Promise<{ offer: SignalPayload; accept: (answer: SignalPayload) => Promise<void> }>;
acceptOffer(offer: SignalPayload): Promise<SignalPayload>;
```

Primary transport: QR code. Optional fallback: ephemeral relay (Phase 1+).

### `transport` (Phase 0)

```ts
type Channel = {
  send(bytes: Uint8Array): Promise<void>;
  onReceive(cb: (bytes: Uint8Array) => void): void;
  close(): void;
};

connect(signal: SignalPayload): Promise<Channel>;
```

Wraps `RTCDataChannel`. Critical invariants:

- Chunk size: **16 KiB** (Firefox fragment boundary).
- Ordered + reliable SCTP (default).
- Separate control channel from data channel.
- Backpressure: monitor `bufferedAmount`; pause on threshold (65_536); resume on `bufferedamountlow`. **Never `setTimeout` in the send loop.**
- SDP fix: replace `b=AS:30` with `b=AS:1638400` (Chrome default caps DataChannel at 30 kbps otherwise).
- LAN default: `iceServers: []` (direct host candidates). Cross-network STUN added when needed.

### `chunking` (Phase 0)

```ts
type Chunk = { index: number; data: Uint8Array; hash: Uint8Array };
type FileId = Uint8Array; // SHA-256(first 64 KiB || filename || size)

segment(file: File): AsyncIterable<Chunk>;
assemble(chunk: Chunk): File | { partial: true };
```

Integrity: per-chunk SHA-256 via `crypto.subtle.digest()`. Resume: bitfield of received indices persisted to IndexedDB; exchange on reconnect; retransmit missing only.

### `handshake` (Phase 1)

Noise NKpsk0. Cipher suite: `Noise_NK_25519_AESGCM_SHA256` (AES-GCM because Web Crypto lacks ChaCha20-Poly1305).

```ts
initiate(responderPubkey: Uint8Array, psk: Uint8Array): Promise<Session>;
respond(staticKeypair: KeyPair, psk: Uint8Array): Promise<Session>;
```

### `crypto` (Phase 1)

Thin, misuse-resistant wrapper around `crypto.subtle`. Exposes: `generateKeypair`, `deriveSharedSecret`, `encrypt`, `decrypt`, `hash`, `hkdf`. Never exposes raw key material outside the module.

### `discovery` (Phase 0 browser / Phase 2 native)

Browser: QR generate/parse only. Native (Phase 2): adds mDNS/UDP multicast for LAN.

## Wire protocol (Phase 0)

Three-phase, over WebRTC DataChannel:

1. **`PREPARE`** (control channel) — sender sends `{ files: [{ id, name, size, mimeType }], sessionId }`. Receiver replies `{ accept: true | false }`.
2. **`DATA`** (data channel) — framed: `{ fileId, index, data, hash }`. Chunks are 16 KiB max.
3. **`ACK` / `CANCEL`** (control channel) — receiver acks on completion or cancels mid-transfer.

Separate control channel from data channel to prevent head-of-line blocking.

## Non-functional constraints

- Works from GitHub Pages (no backend).
- iOS Safari compatible (see `CLAUDE.md` constraints list).
- Zero npm runtime deps. Vendor everything (e.g. `paulmillr/qr`).
- Strict TypeScript, no `any`, no `interface` (use `type`).
- All shared types in `types/` at repo root.

## Design decisions recorded

- **Vanilla DOM over framework**: keeps bundle trivial, ships from GitHub Pages with only `tsc` as a build step.
- **TypeScript over plain JS**: stability win outweighs the build step. Original research recommended plain JS; we accept the trade-off for type safety.
- **AES-GCM over ChaCha20-Poly1305**: Web Crypto API doesn't expose ChaCha20-Poly1305.
- **16 KiB chunks**: Firefox fragments at this boundary; cross-browser safe floor.
- **Ordered + reliable DataChannels**: TCP-like guarantees simplify reassembly; throughput impact is negligible for file transfer.
- **QR as trust anchor**: physical proximity is the authentication.

## Phase scope lock

| Phase | In scope                                                                 | Out of scope                              |
| ----- | ------------------------------------------------------------------------ | ----------------------------------------- |
| 0     | `ui`, `signaling`, `transport`, `chunking`, LAN, QR, GitHub Pages deploy | Noise, persistent pairing, relay, PWA, Go |
| 1     | `handshake`, `crypto`, persistent pairing                                | Relay, PWA, Go                            |
| 2     | Go relay + discovery server, cross-network transfers                     | PWA, mobile shells                        |
| 3     | PWA manifest + SW, `gomobile` shells                                     | New features                              |

Cross-phase work is a PR review blocker.
