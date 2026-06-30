# Guts Scoring — iOS

Independent native iOS client for Guts Tournament field scoring. Shares the **Guts-App-V5** backend with the Android app (`GutsScoring`); does **not** share code with Android.

| Item | Value |
|------|--------|
| Bundle ID | `com.nezsports.gutsscoring` (same as Android Play listing family) |
| API base | `https://api.usaguts.com` |
| Min iOS | 17.0 |
| UI | SwiftUI |
| Local data | SwiftData (events + sync outbox) |
| Repository | https://github.com/DNez2001/GutsScoring-iOS |

## Status

**Phases 1–4 complete in source** (not yet compile-tested on Mac):

| Phase | Scope |
|-------|--------|
| M0 | OTP login, Keychain session, tournament + match list |
| M1 | Scoring engine, SwiftData persistence, score/event sync outbox |
| M2 | Full throw dialog, stats sheet, roster load |
| M3 | Match log export (text / CSV / JSON), background sync flush |

**Next:** first Mac build (`xcodegen generate`), simulator test, TestFlight.

See [docs/STATUS.md](docs/STATUS.md) for the full checklist.

## Mac required to build

This repo was developed on **Windows** (source + docs only). You **cannot compile** on Windows. On a Mac:

1. Clone: `git clone https://github.com/DNez2001/GutsScoring-iOS.git`
2. Install **Xcode 16+** from the App Store.
3. Install **XcodeGen**: `brew install xcodegen`
4. Open the folder in **Cursor** or Xcode.
5. Run: `xcodegen generate`
6. Open `GutsScoring.xcodeproj` → set **Signing & Capabilities** → your Team.
7. Run on Simulator or device.

Full handoff: **[docs/HANDOFF.md](docs/HANDOFF.md)** — read this first on the Mac.

## Related repos

| Repo | Role |
|------|------|
| `GutsScoring` (Android) | Reference implementation, feature parity target |
| `Guts-App-V5` | Backend + `docs/mobile-api/openapi.yaml` |
| `GutsScoring-iOS` (this repo) | Native iOS app |

## Docs

- [docs/HANDOFF.md](docs/HANDOFF.md) — Mac setup, Cursor context, next tasks
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — layers and offline plan
- [docs/ANDROID_PARITY.md](docs/ANDROID_PARITY.md) — screen/feature mapping
- [docs/STATUS.md](docs/STATUS.md) — what's done / not done
