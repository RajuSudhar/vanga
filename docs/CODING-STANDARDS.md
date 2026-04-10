# Coding Standards

## TypeScript

- **Strict mode**, no exceptions. `noUncheckedIndexedAccess` and `exactOptionalPropertyTypes` are on.
- **`type` only**, never `interface`. Exception: class extension or declaration merging.
- **No `any`**. Use `unknown` + narrowing, or a precise type.
- **No `console.*`** in product code. Use the centralized logger (`src/logger.ts`, added in Phase 0 alongside first product code).
- All shared types live in `types/` at repo root. Import as `import type { ... } from '@types'`.
- Validate all external input (QR payloads, DataChannel messages, file metadata) at module boundaries.

## Naming

| Kind                | Convention                 | Example                               |
| ------------------- | -------------------------- | ------------------------------------- |
| Type                | PascalCase                 | `SignalPayload`, `ChunkEntry`         |
| Variable / function | camelCase                  | `signalingClient`, `deriveSessionKey` |
| Constant            | UPPER_SNAKE_CASE           | `MAX_CHUNK_BYTES`                     |
| File                | kebab-case                 | `data-channel-transport.ts`           |
| Boolean             | `is*` / `has*` / `should*` | `isConnected`, `hasBackpressure`      |

No one-word names: `State`, `Entry`, `client` are rejected. Always qualify: `HandshakeState`, `ChunkEntry`, `signalingClient`.

## Imports

ESLint enforces:

- Order: node builtins → external → internal (`@/**`) → parent/sibling → index → `import type`.
- Newlines between groups.
- Alphabetical within each group (case-insensitive).
- No duplicates.
- `import type` for type-only imports (auto-fixable).

## Formatting (Prettier)

- Single quotes, 2-space indent.
- 100-col for code, 100-col proseWrap-preserve for markdown.
- Semicolons.
- `trailingComma: es5`.
- Shell scripts formatted via `prettier-plugin-sh`.

## Logging contract

```ts
log(level: 'debug' | 'info' | 'warn' | 'error', message: string, context?: LogContext): void;
```

`context` is structured. Include `operation`, and any of: `module`, `peerId`, `sessionId`, `chunkIndex`, `bytes`, `durationMs`, `error`.

**Never log**: raw keys, PSKs, SDP with full candidates, full file contents, PII.

Required at:

- Connection lifecycle (open, close, error).
- Handshake start / end (Phase 1+).
- DataChannel open / close / error.
- Backpressure events (throttle if hot).
- Cache hit / miss / invalidate.
- Transfer start / complete.
- Slow ops > 1s.
- Large transfers (log totals, not contents).

## Error handling

- Throw typed errors at module boundaries. Never swallow.
- Log with `error` level + `context` before rethrowing or transforming.
- External input parse failures: return `{ ok: false, error }` rather than throw — they are expected.

## Module boundaries

Every module in `src/` exports a narrow, named public surface. No deep imports across modules. Shared types live in `types/`, not inside modules.

## No emojis

Anywhere. Code, scripts, logs, commits, docs.

## No browser storage misuse

- `localStorage` / `sessionStorage` are fine for non-sensitive UI state.
- Binary / large data → IndexedDB.
- Crypto keys (Phase 1+) → `CryptoKey` with `extractable: false` wherever possible. Never persist raw keys to storage.
