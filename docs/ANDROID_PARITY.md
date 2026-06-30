# Android parity map

Use the **Android app** (`GutsScoring` repo) as the behavioral reference. This document maps screens and modules to iOS targets.

**Do not modify Android** when implementing iOS unless fixing a shared API bug in `Guts-App-V5`.

---

## App flow

| Step | Android | iOS | Status |
|------|---------|-----|--------|
| Launch | `SplashActivity` | `SplashView` | Done (shell) |
| Login | `LoginActivity` | `LoginView` | Done (production OTP only; no mock server UI) |
| Main | `MainActivity` | `MainShellView` → `ScoringView` | Shell + quick scoring |
| Team picker | `TeamDialogFragment` | `MainShellView` match list | Partial |
| Setup | `SetupDialogFragment` | `MatchSetupView` | Subset (start team, downwind) |
| Throw | `ThrowDialogFragment` | `ScoringView` quick buttons | Not full dialog |
| Stats | `StatsDialogBuilder` | TBD | Not started |

---

## Kotlin → Swift module map

| Android | iOS (current / planned) |
|---------|-------------------------|
| `PlayerAuthApi` + `GutsPlayerAuthRepository` | `AuthService` |
| `GutsAuthTokenStore` | `KeychainTokenStore` |
| `GutsTournamentApiClient` / `APIClient` | `APIClient` |
| `MobileScoringApi` | `MobileScoringService` |
| `GutsApiEnvironmentPreferences` | `AppConfig` (+ future `EnvironmentPreferences`) |
| `EventEntity` / `AppDatabase` | `ThrowEventRecord` + SwiftData |
| `GameViewModel` / `GameUiState` | `ScoringViewModel` / `GameUiState` |
| `ScoreSyncOutbox` | `ScoreSyncOutbox.swift` |
| `EventSyncOutbox` | `EventSyncOutbox.swift` |
| `MatchRules` | `MatchRules.swift` |
| `StatsCalculator` | `StatsCalculator.swift` (TBD) |

---

## DTOs

Android: `app/src/main/java/com/example/gutsscoring/api/dto/`

iOS: `GutsScoring/Models/APIModels.swift` (expand as features are ported)

OpenAPI: `Guts-App-V5/docs/mobile-api/openapi.yaml`

---

## Features in Android 1.1.x to port later

- [ ] Wind direction (`throwingDownwind`, setup spinner)
- [ ] Multi-game matches (`gamesToWin`, game checkboxes)
- [ ] Bracket match linking (`linkedMatchRef`)
- [ ] Mandatory throw tags
- [ ] Hide completed matches in picker
- [ ] Excel roster import (optional — lower priority on iOS)

---

## Bundle / identity

| | Android | iOS |
|--|---------|-----|
| Application ID | `com.nezsports.gutsscoring` | `com.nezsports.gutsscoring` |
| Display name | Guts Scoring | Guts Scoring |

---

## Versioning

Track separately from Android. When shipping paired features, note both versions in release notes (e.g. Android 1.2.0 + iOS 1.1.0 = wind stats).
