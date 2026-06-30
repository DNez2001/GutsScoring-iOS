import Foundation

/// Runtime configuration. Mirrors Android `BuildConfig.PRODUCTION_API_BASE_URL`.
enum AppConfig {
    /// Production Guts-App-V5 API (custom domain, no `/prod` path segment).
    static let productionAPIBaseURL = URL(string: "https://api.usaguts.com")!

    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    /// UserDefaults key namespace — keep separate from Android `guts_*` prefs.
    static let preferencesSuite = "com.nezsports.gutsscoring.ios"
}
