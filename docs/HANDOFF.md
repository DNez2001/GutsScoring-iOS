# Handoff — Guts Scoring iOS

**Read this document first** when you open this project on a Mac in Cursor or Xcode.

Last updated: 2026-06-30  
Bootstrapped from: Windows (no compile/run yet)

---

## 1. What exists today

### Implemented (source only — not yet run on device)

| Area | Files | Notes |
|------|--------|------|
| App entry | `GutsScoringApp.swift`, `AppState.swift`, SwiftData container | Splash → login → main |
| OTP auth | `AuthService`, `KeychainTokenStore` | Production API |
| M0 API reads | `MobileScoringService` | Tournaments + matches |
| **M1 scoring engine** | `Game/*.swift` | Rules, state machine, log text |
| **Persistence** | `Persistence/*.swift` | SwiftData events + outbox tables |
| **Sync skeleton** | `ScoreSyncOutbox`, `EventSyncOutbox`, `SyncFlushService`, `BackgroundSyncScheduler` | M1/M2 API + BG flush |
| Scoring UI shell | `ScoringView`, `MatchSetupView`, `ThrowDialogView`, `StatsSheetView` | Full throw dialog + stats + export |
| CI | `.github/workflows/ios-build.yml` | macOS build on GitHub push |

### Not started

- TestFlight / App Store

---

## 2. First build on Mac (step by step)

```bash
cd ~/path/to/GutsScoring-iOS   # or D:\... on shared drive

# 1. Generate Xcode project from spec
brew install xcodegen   # once
xcodegen generate

# 2. Open project
open GutsScoring.xcodeproj
# or: cursor .

# 3. In Xcode
#    - Target GutsScoring → Signing & Capabilities → select your Apple Developer Team
#    - Set DEVELOPMENT_TEAM in project.yml or Xcode if needed

# 4. Run
#    - Choose iPhone simulator (iOS 17+)
#    - Product → Run (⌘R)
```

### Expected first-run flow

1. Black splash (~1s)
2. Login — enter phone → Send code → Verify
3. Main shell — tournament list + scorable matches (requires `api.usaguts.com` + valid staff/player account)

### API / DNS

Production API: **`https://api.usaguts.com`** (no `/prod` suffix).  
Ensure DNS CNAME is live (see Android Play Console / Cloudflare notes in main project chat).

Optional override: copy `Config/Secrets.xcconfig.example` → `Config/Secrets.xcconfig` (gitignored).

---

## 3. Cursor on Mac — bring the agent up to speed

Paste or point Cursor at:

1. This file (`docs/HANDOFF.md`)
2. `docs/STATUS.md` — checklist
3. `docs/ANDROID_PARITY.md` — what to mirror from Kotlin
4. Backend contract: `Guts-App-V5/docs/mobile-api/openapi.yaml`
5. Android reference: `GutsScoring` repo on branch `V1.1.0` (or latest)

**Suggested prompt for Cursor:**

> Continue Guts Scoring iOS in `GutsScoring-iOS`. Read `docs/HANDOFF.md` and `docs/STATUS.md`. Next priority: [pick from STATUS]. Match Android behavior in `GutsScoring` where noted in `docs/ANDROID_PARITY.md`. Do not modify the Android repo.

---

## 4. Project layout

```
GutsScoring-iOS/
  project.yml              # XcodeGen — run xcodegen generate on Mac
  Config/                  # Debug/Release xcconfig (API URL)
  GutsScoring/
    App/                   # @main, navigation state
    Config/                # AppConfig.swift
    Models/                # Codable DTOs
    Services/              # API, auth, keychain
    ViewModels/
    Views/
    Resources/             # Assets.xcassets (add real app icon)
  docs/
```

`GutsScoring.xcodeproj` is **generated** — not committed (see `.gitignore`). Always run `xcodegen generate` after pulling `project.yml` changes.

---

## Recommended next tasks (priority order)

1. **Verify build on Simulator** — `xcodegen generate`, fix Swift compile errors.
2. **End-to-end M1 test** — OTP → match → score → confirm web score updates.
3. **Full throw dialog** — port `ThrowDialogFragment` (shot type, zones, players).
4. **StatsCalculator** + stats sheet.
5. **Roster fetch** — wire `getRosters` when match selected.
6. **Background sync** — `BackgroundSyncScheduler` (`com.nezsports.gutsscoring.sync-flush`). On device, simulate with Xcode debugger: `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.nezsports.gutsscoring.sync-flush"]`
7. **Export** — score a few throws → Export → share readable / CSV / JSON.

Track progress in `docs/STATUS.md`.

---

## 6. Independence from Android

- **No shared Gradle/Xcode project** with Android.
- **Do not edit** `GutsScoring` Android repo unless coordinating a cross-platform API change (do that in `Guts-App-V5` first).
- Same **bundle ID family** and API — different implementation language.

---

## 7. Apple Developer

- **Apple Developer Program** ($99/yr) required for device testing and TestFlight.
- Bundle ID: register `com.nezsports.gutsscoring` in App Store Connect (same identifier as Android applicationId).

---

## 8. Troubleshooting

| Issue | Fix |
|-------|-----|
| No `GutsScoring.xcodeproj` | Run `xcodegen generate` |
| Signing errors | Set Team in Xcode; add `DEVELOPMENT_TEAM` to `project.yml` |
| 401 on API | Re-login; check OTP account is staff/captain for tournament |
| Network error on login | Verify `api.usaguts.com` resolves; try Safari on device |
| Keychain errors in Simulator | Reset simulator or sign out/in |

---

## 9. Contact / context

- Android app version at iOS kickoff: **1.1.2** (versionCode 5), package `com.nezsports.gutsscoring`
- iOS bootstrap version: **1.0.0** (1)
