# Security

## Dependency policy (hard cap)

### Browser

- **Zero npm runtime dependencies.** Vendor anything required.
- Dev dependencies are allowed for tooling only (TypeScript, ESLint, Prettier, markdownlint, Husky).
- Any vendored code lives under `src/vendor/` and is treated as audited source.

### Go (future Phase 2+)

Maximum **3 external modules**:

1. `golang.org/x/crypto` (Go team maintained, FIPS 140-3 validated).
2. `github.com/coder/websocket` (0 transitive deps).
3. `github.com/flynn/noise` (Noise Protocol implementation).

`CGO_ENABLED=0` always. No C bindings.

## Adding a dependency

Every new dep must pass **all** of:

1. `./scripts/check-package-security.sh <pkg>` — not in the Shai Hulud 2.0 compromised list.
2. Fewer than 5 transitive dependencies.
3. Maintained by a known, reputable entity (or team, not a single random account).
4. Source auditable in under ~2,000 lines.
5. No native / C bindings.
6. Pinned to an exact version in `package.json`.
7. Both lock files updated: `pnpm run sync:locks`.

If any check fails, do not add the dep. Prefer vendoring or implementing yourself.

## Crypto model

### Phase 0

Only WebRTC's built-in DTLS secures the wire. This is fine for LAN transfers between trusted devices but is **not** application-layer E2EE. Do not claim otherwise in UI or docs.

### Phase 1 onward

- **Key exchange**: Noise NKpsk0 pattern. QR encodes responder's X25519 static public key (32 B) + PSK (32 B).
- **Cipher suite**: `Noise_NK_25519_AESGCM_SHA256`. AES-GCM is used because Web Crypto API does not expose ChaCha20-Poly1305.
- **Integrity**: per-chunk SHA-256 via `crypto.subtle.digest()`.
- **Authentication**: physical proximity via QR scan is the trust anchor. Optional Short Authentication String (SAS) display for paranoid users.
- **Forward secrecy**: ephemeral keys per session.
- **Relay zero-knowledge** (Phase 2+): future relay forwards Noise-encrypted ciphertext only.

## Secrets

- Never log keys, PSKs, SDP with full ICE candidates, or raw cryptographic material.
- Never embed secrets in URLs, error messages, or responses to the peer.
- `CryptoKey` objects should be `extractable: false` wherever possible.
- Do not persist raw keys to `localStorage` or IndexedDB. If persistence is needed, store `CryptoKey` objects directly (they are structured-clonable into IndexedDB).

## Input validation

Every external input is untrusted:

- QR payload — validate size, version byte, field lengths before decoding.
- DataChannel messages — validate opcode, length, and structure before parsing.
- File metadata from peer — sanitize names (no path traversal, no control chars), cap sizes.

Parse failures are expected and must return an error, never crash the session.

## Threat model (Phase 0)

In scope:

- Passive network observers on the LAN (mitigated by DTLS).
- Accidental file misdelivery to the wrong peer (mitigated by QR physical proximity).

Out of scope for Phase 0 (addressed in later phases):

- Active MITM on the LAN.
- Compromised signaling relay.
- Device compromise.
- Side-channel attacks.

## Reporting

Security issues: open a private report (channel TBD). Do not file public issues for undisclosed vulnerabilities.
