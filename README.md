# Guts Scoring — iOS

Independent native iOS client for Guts Tournament field scoring. Shares the **Guts-App-V5** backend with the Android app (`GutsScoring`); does **not** share code with Android.

| Item | Value |
|------|--------|
| Bundle ID | `com.nezsports.gutsscoring` (same as Android Play listing family) |
| API base | `https://api.usaguts.com` |
| Min iOS | 17.0 |
| UI | SwiftUI |
| Local data | Not started (planned: SwiftData) |

## Status

**Phase iOS-M0 (in progress)** — OTP login, tournament list, scorable matches, **M1 scoring shell** (engine + SwiftData + sync skeleton). Not compile-tested until Mac.

See [docs/STATUS.md](docs/STATUS.md) for detailed checklist.

## Mac required to build

This repo was bootstrapped on **Windows** (source + docs only). You **cannot compile** here. On a Mac:

1. Install **Xcode 16+** from the App Store.
2. Install **XcodeGen**: `brew install xcodegen`
3. Clone/open this folder in **Cursor** or Xcode.
4. Run: `xcodegen generate`
5. Open `GutsScoring.xcodeproj` → set **Signing & Capabilities** → your Team.
6. Run on Simulator or device.

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
