# Architecture — Guts Scoring iOS

## Principles (same as Android)

1. **Offline-first** — local store is authoritative while scoring; API sync is async with retry.
2. **Pull config, push facts** — tournaments/matches/rosters from server; scores/events from device.
3. **UUID match refs** — use `matchRef`, `playerId`, `teamId` from mobile API (not legacy integer game IDs).
4. **No browser cookies** — OTP → `sessionToken` → `X-Session-Token` header only.

## Layers (target)

```
Views (SwiftUI)
    ↓
ViewModels (@MainActor, ObservableObject)
    ↓
Services (Auth, MobileScoring, SyncOutbox)
    ↓
APIClient (URLSession)  →  https://api.usaguts.com
    ↓
Persistence (SwiftData — planned)
```

## Current implementation

| Layer | Status |
|-------|--------|
| Views | Splash, Login, MainShell (list only) |
| ViewModels | Login, TournamentPicker |
| Services | Auth, MobileScoring, Keychain, APIClient |
| SwiftData | Not started |

## Planned persistence (port from Android Room)

Mirror tables/entities from `GutsScoring`:

| Android (Room) | iOS (planned) |
|----------------|---------------|
| `EventEntity` | `ThrowEvent` model |
| `PendingScoreSyncEntity` | `PendingScoreSync` |
| `PendingEventSyncEntity` | `PendingEventSync` |
| `PendingEventRetractionEntity` | `PendingEventRetraction` |

Use background `Task` or `BGTaskScheduler` for outbox flush (Android uses WorkManager).

## API contract

Canonical spec: **`Guts-App-V5/docs/mobile-api/openapi.yaml`**

Production shims (today, same as Android):

| Operation | HTTP |
|-----------|------|
| Send OTP | `POST /auth/player/send-otp` |
| Verify OTP | `POST /auth/player/verify-otp` |
| Tournaments | `GET /tournaments?mobileScoring=1` |
| Scorable matches | `GET /tournaments/{id}?mobileView=scorable-matches` |
| Rosters | `GET /tournaments/{id}?mobileView=rosters` |
| Score progress | `PUT /tournaments/{id}?mobileView=match-progress` |
| Throw events | `PUT /tournaments/{id}?mobileView=match-events` |

## Configuration

- `AppConfig.productionAPIBaseURL` — default `https://api.usaguts.com`
- Optional: `Config/Secrets.xcconfig` (gitignored) for staging overrides

## Security

- Session token in **Keychain** (`KeychainTokenStore`)
- No secrets in source control

## Testing strategy (on Mac)

1. **Simulator** — OTP login, API list calls (network required)
2. **Physical iPhone** — field UX, keychain, performance
3. **TestFlight** — TD/scorekeeper pilot before App Store

Unit tests (future): port logic from Android `StatsCalculator` tests where they exist.
