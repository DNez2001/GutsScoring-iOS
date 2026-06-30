# Status checklist

Update this file as work completes.  
**Phase:** iOS-M3 export + background sync (phase 4)

## Legend

- [x] Done (source written)
- [~] Partial
- [ ] Not started / not verified on Mac

---

## Tooling & project

| Item | Status | Notes |
|------|--------|-------|
| Git repo | [x] | Initialized 2026-06-30 |
| XcodeGen `project.yml` | [x] | Run `xcodegen` on Mac |
| GitHub Actions `ios-build.yml` | [x] | Runs on push when on GitHub |
| First successful Mac build | [ ] | Blocked until Mac |
| Signing / Team ID | [ ] | Set on Mac |
| BGTask identifier in Info.plist | [x] | `com.nezsports.gutsscoring.sync-flush` |

---

## M0 — Auth & API reads

| Item | Status |
|------|--------|
| OTP login UI + Keychain | [x] |
| Tournament list | [x] |
| Scorable match list | [x] |
| Open match → scoring flow | [x] |

---

## M1 — Scoring engine & score sync

| Item | Status | Android reference |
|------|--------|-------------------|
| `GameUiState` | [x] | `GameUIState.kt` |
| `MatchRules` / `GameEngine` | [x] | `MatchRules.kt`, `stateAfterEvent` |
| `ThrowEventInput` + log formatting | [x] | `EventEntity.kt` |
| SwiftData `ThrowEventRecord` | [x] | Room `EventEntity` |
| `ThrowEventStore` | [x] | `EventDao` |
| `ScoringViewModel` | [x] | `GameViewModel` |
| `ScoringView` shell | [x] | Throw dialog + stats + export |
| `MatchSetupView` | [x] | `SetupDialogFragment` — subset |
| `ScoreSyncOutbox` | [~] | Wired + BG schedule; needs device test |
| `EventSyncOutbox` | [~] | Wired + BG schedule; needs device test |
| Full throw dialog | [x] | `ThrowDialogFragment` |
| Undo rebuild | [x] | Ported in `ScoringViewModel` |
| Multi-game next game | [x] | Basic |
| Field switch + downwind flip | [x] | `MatchRules.withFieldEndsSwitched` |

---

## M2 — Stats & polish

| Item | Status |
|------|--------|
| `StatsCalculator` port | [x] |
| Stats sheet UI | [x] |
| Match log export | [x] | Readable / CSV / JSON + share sheet |
| Roster load + merge | [x] | `getRosters` on match configure |
| Background flush (BGTask) | [x] | `BackgroundSyncScheduler` + foreground resume |

---

## M3 — Release prep (next)

| Item | Status |
|------|--------|
| First Mac compile + simulator test | [ ] |
| Device OTP + live scoring test | [ ] |
| TestFlight | [ ] |
| App Store listing | [ ] |

---

## Last session summary (2026-06-20, phase 4)

Added on Windows (not compile-tested):

- **Export:** `MatchEventSerializer`, share sheet (`ActivityShareSheet`), Export button on `ScoringView`
- **Sync:** `SyncFlushService`, `BackgroundSyncScheduler` (BGAppRefreshTask)
- **App:** Foreground resume flush; `project.yml` BG task identifier

**Next on Mac:** `xcodegen generate` → build → export share test → offline throw → background sync test.
